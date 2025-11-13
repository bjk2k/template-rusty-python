# shell.nix - For users who prefer traditional Nix shell over flakes
# Usage: nix-shell (in the project directory)

{
  pkgs ? import <nixpkgs> {
    overlays = [
      (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
    ];
  },
}:

let
  # Rust toolchain
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src"
      "clippy"
      "rustfmt"
    ];
  };

  # Python with required packages
  pythonEnv = pkgs.python312.withPackages (
    ps: with ps; [
      pip
      setuptools
      wheel
    ]
  );

  # Native dependencies
  nativeDeps =
    with pkgs;
    [
      pkg-config
      openssl
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
      # macOS specific dependencies
      pkgs.darwin.apple_sdk.frameworks.Security
      pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
      pkgs.libiconv
    ];

  # Development tools
  devTools = with pkgs; [
    # Python tools
    uv

    # Rust tools
    rustToolchain
    cargo-watch
    cargo-edit

    # Build tools
    maturin

    # Development utilities
    git
    just
    direnv

    # Optional: debugging tools
    gdb
    lldb
  ];

in
pkgs.mkShell {
  name = "{{PROJECT_NAME}}-dev-shell";

  buildInputs = nativeDeps ++ devTools ++ [ pythonEnv ];

  # Environment variables
  RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
  PYTHON_PATH = "${pythonEnv}/bin/python";

  # Rust compilation flags for better performance during development
  CARGO_BUILD_RUSTFLAGS = "-C target-cpu=native";

  # Python compilation flags
  PYTHONDONTWRITEBYTECODE = "1";
  PYTHONUNBUFFERED = "1";

  # UV configuration
  UV_PYTHON_PREFERENCE = "system";

  shellHook = ''
        echo "🦀🐍 Welcome to {{PROJECT_NAME}} development environment!"
        echo ""
        echo "Available tools:"
        echo "  - Python: $(python --version)"
        echo "  - Rust: $(rustc --version)"
        echo "  - UV: $(uv --version)"
        echo "  - Maturin: $(maturin --version)"
        echo ""
        echo "Quick start:"
        echo "  1. cd python"
        echo "  2. uv venv"
        echo "  3. source .venv/bin/activate"
        echo "  4. uv sync"
        echo "  5. uv run maturin develop"
        echo ""
        echo "Or use the convenience commands:"
        echo "  just setup    - Set up development environment"
        echo "  just dev      - Build Rust extension"
        echo "  just test     - Run tests"
        echo "  just --list   - Show all available commands"
        echo ""

        # Set up aliases for convenience
        alias build="just dev"
        alias test="just test"
        alias fmt="just fmt"
        alias lint="just lint"
        alias setup="just setup"

        # Export useful environment variables
        export RUST_BACKTRACE=1

        # Create justfile if it doesn't exist
        if [ ! -f justfile ] && command -v just > /dev/null; then
          echo "📝 Creating justfile with common commands..."
          cat > justfile << 'EOF'
    # {{PROJECT_NAME}} - Development Commands

    # Default recipe shows available commands
    default:
        @just --list

    # Set up development environment
    setup:
        #!/usr/bin/env bash
        set -e
        cd python && uv venv && uv sync && uv run maturin develop && uv pip install -e .

    # Build the Rust extension in development mode
    dev:
        cd python && uv run maturin develop

    # Run tests
    test:
        cd python && uv run pytest
        cd rust-core && cargo test

    # Format code
    fmt:
        cd rust-core && cargo fmt
        cd python && uv run black .

    # Lint code
    lint:
        cd rust-core && cargo clippy -- -D warnings
        cd python && uv run black --check .

    # Clean build artifacts
    clean:
        cd rust-core && cargo clean
        cd python && rm -rf target/ dist/ build/
    EOF
        fi
  '';
}
