# Nix Development Environment

This project provides comprehensive Nix support for reproducible development environments with automatic dependency management. You can use either Nix flakes (recommended) or traditional Nix shell.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled (recommended)
- [direnv](https://direnv.net/) (optional but highly recommended)

### Enabling Nix Flakes

If you haven't enabled flakes yet, add this to your `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

Or run Nix commands with `--extra-experimental-features 'nix-command flakes'`.

## Quick Start

### Option 1: Flakes + direnv (Recommended)

1. **Install direnv** (if not already installed):
   ```bash
   # macOS
   brew install direnv
   
   # Ubuntu/Debian
   sudo apt install direnv
   
   # Or via Nix
   nix profile install nixpkgs#direnv
   ```

2. **Set up direnv** in your shell:
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, etc.
   eval "$(direnv hook bash)"  # For bash
   eval "$(direnv hook zsh)"   # For zsh
   ```

3. **Enter the project directory**:
   ```bash
   cd {{PROJECT_NAME}}
   direnv allow  # First time only
   ```

   The environment will automatically load with all dependencies!

4. **Set up the development environment**:
   ```bash
   just setup
   ```

### Option 2: Manual Nix Flake

```bash
# Enter development environment
nix develop

# Set up the project
just setup
```

### Option 3: Traditional Nix Shell (for users without flakes)

```bash
nix-shell
just setup
```

## Available Nix Commands

### Flake Commands

- `nix develop` - Enter the development environment
- `nix run .#setup` - Automated setup script (sets up Python environment and builds extension)
- `nix build` - Build the Python package
- `nix build .#rust-core` - Build only the Rust core
- `nix flake check` - Run all checks (formatting, linting, etc.)

### Package Building

```bash
# Build the Python package
nix build .#python-package

# Build the Rust core library
nix build .#rust-core

# Build both (default)
nix build
```

## What's Included

The Nix environment provides:

### Core Tools
- **Python 3.12** with pip, setuptools, wheel
- **Rust** (stable) with clippy, rustfmt, rust-src
- **UV** - Fast Python package manager
- **Maturin** - Build tool for Rust-Python packages

### Development Tools
- **Just** - Command runner (like make)
- **Cargo-watch** - Watch Rust files for changes
- **Cargo-edit** - Easy dependency management
- **Git** - Version control
- **Direnv** - Environment management

### Platform-specific Dependencies
- **Linux**: pkg-config, openssl
- **macOS**: Security framework, SystemConfiguration, libiconv
- **All platforms**: GDB/LLDB for debugging

## Environment Variables

The Nix environment sets up several helpful environment variables:

```bash
RUST_SRC_PATH           # Path to Rust source code
PYTHON_PATH             # Path to Python interpreter
CARGO_BUILD_RUSTFLAGS   # Optimized build flags (-C target-cpu=native)
PYTHONDONTWRITEBYTECODE # Prevent .pyc files (set to "1")
PYTHONUNBUFFERED        # Real-time output (set to "1")
UV_PYTHON_PREFERENCE    # Use system Python from Nix (set to "system")
RUST_BACKTRACE          # Better error messages (set to "1")
```

## Development Workflow with Nix

### First Time Setup

1. **Clone and enter the project**:
   ```bash
   git clone <repo>
   cd {{PROJECT_NAME}}
   ```

2. **Allow direnv** (if using):
   ```bash
   direnv allow
   ```

3. **Set up development environment**:
   ```bash
   just setup
   ```

### Daily Development

With direnv, the environment loads automatically when you `cd` into the project:

```bash
cd {{PROJECT_NAME}}  # Environment loads automatically

# Make changes to Rust code
just dev              # Rebuild extension

# Make changes to Python code  
just test             # Run tests

# Format code
just fmt              # Format both Rust and Python

# Check everything
just ci               # Run CI-like checks
```

### Manual Environment Management

If not using direnv:

```bash
nix develop           # Enter environment
just setup            # Set up project
# ... do development work ...
exit                  # Leave environment
```

## Just Commands

The Nix environment includes [Just](https://just.systems) with pre-configured commands:

| Command | Description |
|---------|-------------|
| `just setup` | Set up development environment |
| `just dev` | Build Rust extension in development mode |
| `just build` | Build in release mode |
| `just test` | Run all tests |
| `just fmt` | Format all code |
| `just lint` | Lint all code |
| `just clean` | Clean build artifacts |
| `just check` | Quick sanity check |
| `just watch` | Watch and rebuild on changes |
| `just ci` | Run CI-like checks |

Run `just --list` to see all available commands.

## Customizing the Environment

### Adding New Dependencies

#### Rust Dependencies
Add to `rust-core/Cargo.toml` as usual:
```toml
[dependencies]
serde = "1.0"
```

#### Python Dependencies
Add to `python/pyproject.toml`:
```toml
dependencies = [
    "numpy>=2.3.4",
    "requests>=2.31.0",  # New dependency
]
```

#### System Dependencies
Edit `flake.nix` to add system packages:
```nix
devTools = with pkgs; [
  # ... existing tools ...
  postgresql  # Add new system dependency
];
```

### Modifying Environment Variables

Edit the `env` section in `flake.nix`:
```nix
env = {
  # ... existing vars ...
  MY_CUSTOM_VAR = "value";
};
```

## Troubleshooting

### Common Issues

1. **"command not found" errors**
   - Make sure you're in the Nix environment: `nix develop`
   - Or that direnv is working: `direnv reload`

2. **Build failures**
   - Clean the environment: `just clean`
   - Try a fresh shell: `exit` then `nix develop`

3. **Python import errors**
   - Rebuild the extension: `just dev`
   - Reinstall the package: `cd python && uv pip install -e .`

4. **Direnv not working**
   - Check if direnv is hooked: `direnv status`
   - Allow the directory: `direnv allow`

### Debugging

Enable verbose output:
```bash
# Nix debugging
nix develop --verbose

# Rust debugging  
export RUST_BACKTRACE=full
just dev

# Python debugging
export PYTHONDEVMODE=1
just test
```

### Clean Reinstall

```bash
# Clean everything
just clean-all

# Restart Nix environment
exit  # If in nix develop
nix develop --reload

# Set up again
just setup
```

## Integration with IDEs

### VS Code

Create `.vscode/settings.json`:
```json
{
    "python.defaultInterpreterPath": "./python/.venv/bin/python",
    "rust-analyzer.linkedProjects": ["./rust-core/Cargo.toml"],
    "nix.enableLanguageServer": true,
    "nix.serverPath": "nixd"
}
```

Recommended extensions:
- Nix IDE
- Python
- Rust Analyzer
- direnv

### Other IDEs

Most IDEs can use the Nix environment by:
1. Starting the IDE from within `nix develop`
2. Or setting the IDE to use tools from the Nix store paths

## CI Integration

The flake includes checks that can be run in CI:

```bash
# Local testing
nix flake check

# In CI (GitHub Actions example)
- uses: DeterminateSystems/nix-installer-action@main
- uses: DeterminateSystems/magic-nix-cache-action@main
- run: nix flake check
```

## Performance Tips

1. **Use binary caches**:
   ```bash
   # Add to ~/.config/nix/nix.conf
   substituters = https://cache.nixos.org https://nix-community.cachix.org
   trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
   ```

2. **Enable parallel building**:
   ```bash
   # Add to ~/.config/nix/nix.conf  
   max-jobs = auto
   ```

3. **Use `cargo-watch` for fast rebuilds**:
   ```bash
   just watch  # Watches for changes and rebuilds automatically
   ```

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [direnv Documentation](https://direnv.net/man/direnv.1.html)
- [Just Manual](https://just.systems/man/en/)
- [PyO3 Guide](https://pyo3.rs/)
- [Maturin Documentation](https://github.com/PyO3/maturin)