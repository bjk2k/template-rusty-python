{
  description = "{{PROJECT_NAME}} - A Rust-Python hybrid project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

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
          ++ lib.optionals stdenv.isDarwin [
            # macOS specific dependencies - using new SDK pattern
            pkgs.apple-sdk
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
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          name = "{{PROJECT_NAME}}-dev";

          buildInputs = nativeDeps ++ devTools ++ [ pythonEnv ];

          # Environment variables
          env = {
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
            PYTHON_PATH = "${pythonEnv}/bin/python";

            # Rust compilation flags for better performance during development
            CARGO_BUILD_RUSTFLAGS = "-C target-cpu=native";

            # Python compilation flags
            PYTHONDONTWRITEBYTECODE = "1";
            PYTHONUNBUFFERED = "1";

            # UV configuration
            UV_PYTHON_PREFERENCE = "system";
          };

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

                        # Set up git hooks if in a git repository
                        if [ -d .git ]; then
                          echo "Setting up git hooks..."
                          mkdir -p .git/hooks

                          # Pre-commit hook for formatting
                          cat > .git/hooks/pre-commit << 'EOF'
            #!/usr/bin/env bash
            set -e

            echo "Running pre-commit checks..."

            # Check Rust formatting
            if [ -d rust-core ]; then
              cd rust-core
              cargo fmt --check || {
                echo "❌ Rust code is not formatted. Run 'cargo fmt' to fix."
                exit 1
              }
              cd ..
            fi

            # Check Python formatting
            if [ -d python ] && [ -f python/.venv/bin/activate ]; then
              cd python
              if [ -f .venv/bin/activate ]; then
                source .venv/bin/activate
                if command -v black > /dev/null; then
                  black --check . || {
                    echo "❌ Python code is not formatted. Run 'black .' to fix."
                    exit 1
                  }
                fi
              fi
              cd ..
            fi

            echo "✅ Pre-commit checks passed!"
            EOF
                          chmod +x .git/hooks/pre-commit
                        fi

                        # Create a justfile if it doesn't exist
                        if [ ! -f justfile ] && command -v just > /dev/null; then
                          cat > justfile << 'EOF'
            # Default recipe
            default:
                @just --list

            # Set up development environment
            setup:
                cd python && uv venv && uv sync

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
                cd python && rm -rf target/ dist/ build/ .pytest_cache/

            # Build release wheels
            build:
                cd python && uv run maturin build --release

            # Full development setup
            full-setup: setup dev
                @echo "✅ Development environment ready!"
            EOF
                          echo "📝 Created justfile with common commands"
                        fi
          '';
        };

        # Package for the Rust core
        packages.rust-core = pkgs.rustPlatform.buildRustPackage {
          pname = "{{PROJECT_NAME}}-rust-core";
          version = "0.1.0";

          src = ./rust-core;

          cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will be updated by template init

          buildInputs = nativeDeps;

          # Skip tests during build (they require Python integration)
          doCheck = false;

          meta = with pkgs.lib; {
            description = "Rust core library for {{PROJECT_NAME}}";
            license = licenses.mit;
            maintainers = [ "{{AUTHOR_NAME}}" ];
          };
        };

        # Python package
        packages.python-package = pkgs.python312Packages.buildPythonPackage {
          pname = "{{PROJECT_NAME}}";
          version = "0.1.0";
          format = "pyproject";

          src = ./python;

          # Build dependencies
          nativeBuildInputs =
            with pkgs;
            [
              rustToolchain
              maturin
              pkg-config
            ]
            ++ nativeDeps;

          buildInputs = nativeDeps;

          # Python dependencies
          propagatedBuildInputs = with pkgs.python312Packages; [
            numpy
            plotly
          ];

          # Build with maturin
          buildPhase = ''
            export CARGO_HOME=$(mktemp -d cargo-home.XXXXXX)
            maturin build --release --out dist
          '';

          installPhase = ''
            pip install dist/*.whl --prefix $out --no-index --no-deps
          '';

          # Skip tests during build (requires proper test setup)
          doCheck = false;

          meta = with pkgs.lib; {
            description = "{{PROJECT_DESCRIPTION}}";
            license = licenses.mit;
            maintainers = [ "{{AUTHOR_NAME}}" ];
          };
        };

        # Default package
        packages.default = self.packages.${system}.python-package;

        # Applications
        apps = {
          # Quick development setup
          setup = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "setup" ''
                set -e
                echo "🚀 Setting up {{PROJECT_NAME}} development environment..."

                if [ ! -d python/.venv ]; then
                  echo "Creating Python virtual environment..."
                  cd python
                  uv venv
                  cd ..
                fi

                echo "Installing Python dependencies..."
                cd python
                source .venv/bin/activate
                uv sync

                echo "Building Rust extension..."
                uv run maturin develop

                echo "Installing package in development mode..."
                uv pip install -e .

                echo "✅ Setup complete! You can now:"
                echo "  cd python"
                echo "  source .venv/bin/activate"
                echo "  uv run python -c \"from {{PYTHON_PACKAGE_NAME}} import add; print(add(2, 3))\""
                cd ..
              ''
            );
          };
        };

        # Formatter
        formatter = pkgs.nixpkgs-fmt;

        # Checks
        checks = {
          # Rust formatting check
          rust-fmt =
            pkgs.runCommand "rust-fmt-check"
              {
                buildInputs = [ rustToolchain ];
              }
              ''
                cd ${./rust-core}
                cargo fmt --check
                touch $out
              '';

          # Rust clippy check
          rust-clippy =
            pkgs.runCommand "rust-clippy-check"
              {
                buildInputs = [ rustToolchain ] ++ nativeDeps;
              }
              ''
                cd ${./rust-core}
                cargo clippy -- -D warnings
                touch $out
              '';
        };
      }
    );
}
