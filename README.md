# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

This is a hybrid Rust-Python project template that allows you to write performance-critical code in Rust while providing a convenient Python API. It uses [PyO3](https://pyo3.rs/) for Python bindings and [Maturin](https://github.com/PyO3/maturin) for building and packaging.

## Features

- 🦀 **Rust Core**: Write performance-critical code in Rust
- 🐍 **Python API**: Expose Rust functions through a clean Python interface
- 📦 **Easy Packaging**: Build Python wheels with Maturin
- 🔧 **Development Tools**: Pre-configured with testing, linting, and development dependencies
- 🚀 **Fast Development**: Hot-reload during development with `maturin develop`

## Project Structure

```
.
├── python/                     # Python package
│   ├── src/
│   │   └── {{PYTHON_PACKAGE_NAME}}/     # Main Python package
│   │       ├── __init__.py
│   │       ├── api.py         # Python wrapper functions
│   │       └── py.typed       # Type hints marker
│   ├── tests/                 # Python tests
│   ├── pyproject.toml         # Python project configuration
│   └── README.md
├── rust-core/                 # Rust library
│   ├── src/
│   │   └── lib.rs            # Rust implementation
│   ├── Cargo.toml            # Rust project configuration
│   └── Cargo.lock
├── notebooks/                # Jupyter notebooks for experimentation
└── build.sh                 # Build script
```

## Prerequisites

### Option 1: Nix (Recommended - Reproducible Environment)

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional but recommended)

See [NIX.md](NIX.md) for detailed Nix setup instructions.

### Option 2: Manual Installation

- [Rust](https://rustup.rs/) (latest stable)
- [Python](https://www.python.org/) 3.11+
- [uv](https://docs.astral.sh/uv/) (Python package manager)

## Quick Start

### With Nix (Recommended)

1. **Create repository from template:**
   - Click "Use this template" on GitHub
   - Create your new repository

2. **Initialize the template:**
   ```bash
   # Go to your new repository on GitHub
   # Navigate to Actions tab
   # Run "Initialize Template" workflow manually
   # (This replaces all {{placeholders}} with your project values)
   ```

3. **Clone and setup:**
   ```bash
   git clone <your-repo-url>
   cd <your-project-name>
   ```

4. **Enter the development environment:**
   ```bash
   # If using direnv (recommended)
   direnv allow

   # Or manually
   nix develop
   ```

5. **Set up and build:**
   ```bash
   just setup  # Sets up environment and builds everything
   ```

6. **Test the installation:**
   ```bash
   just check  # Runs sanity checks
   ```

That's it! The Nix environment provides all dependencies automatically.

### Without Nix (Manual Setup)

1. **Create and initialize repository:**
   - Click "Use this template" on GitHub
   - Run the "Initialize Template" workflow in the Actions tab
   - This will replace all template placeholders with your project values

2. **Clone and setup:**
   ```bash
   git clone <your-repo-url>
   cd <your-project-name>
   ```

3. **Build and install:**
   ```bash
   ./build.sh
   ```

4. **Test the installation:**
   ```bash
   cd python
   uv run python -c "from <your_package_name> import add; print(add(2, 3))"
   ```

## Development Workflow

### With Nix (Recommended)

The Nix environment provides all dependencies and includes [Just](https://just.systems) for convenient command running:

```bash
# Enter environment (if not using direnv)
nix develop

# Common development commands
just setup          # Initial setup
just dev            # Development build
just test           # Run all tests
just check          # Quick sanity check
just fmt            # Format code
just lint           # Lint code
just watch          # Watch for changes and rebuild
just clean          # Clean build artifacts
just info           # Show project and environment info
just --list         # Show all available commands
```

**Pro tip:** Use `direnv` for automatic environment loading when entering the project directory!

See [NIX.md](NIX.md) for detailed Nix setup and usage.

### Manual Setup

#### Initial Setup

```bash
cd python
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
uv sync
```

#### Development Build

For development with hot-reload:

```bash
cd python
uv run maturin develop
```

This compiles the Rust code and installs it in development mode, allowing you to test changes immediately.

#### Running Tests

```bash
cd python
uv run pytest
```

#### Building Release Wheels

```bash
cd python
uv run maturin build --release
```

The wheel will be created in `python/target/wheels/`.

## Adding New Rust Functions

1. **Add the function to `rust-core/src/lib.rs`:**

```rust
#[pyfunction]
fn multiply(a: i64, b: i64) -> i64 {
    a * b
}

#[pymodule]
fn {{RUST_CORE_MODULE_NAME}}(_py: Python<'_>, m: &Bound<PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(add, m)?)?;
    m.add_function(wrap_pyfunction!(multiply, m)?)?;  // Add this line
    Ok(())
}
```

2. **Expose it in the Python API (`python/src/{{PYTHON_PACKAGE_NAME}}/api.py`):**

```python
import {{RUST_CORE_MODULE_NAME}} as core

def multiply(a: int, b: int) -> int:
    """Multiply two integers using Rust implementation."""
    return core.multiply(a, b)
```

3. **Update `__init__.py`:**

```python
from .api import add, multiply

__all__ = ["add", "multiply"]
```

4. **Rebuild:**

```bash
cd python
uv run maturin develop
```

## Configuration

### Python Configuration (`python/pyproject.toml`)

- **Dependencies**: Add Python dependencies under `dependencies`
- **Dev Dependencies**: Add development tools under `dependency-groups.dev`
- **Maturin Settings**: Configure under `tool.maturin`

### Rust Configuration (`rust-core/Cargo.toml`)

- **Dependencies**: Add Rust dependencies under `dependencies`
- **Library Name**: The `lib.name` should match your Python import

## Publishing

### To PyPI

```bash
cd python
uv run maturin publish
```

### To Test PyPI

```bash
cd python
uv run maturin publish --repository testpypi
```

## Troubleshooting

### Common Issues

1. **Import Error**: Make sure you've run `maturin develop` (or `just dev`) after making changes to Rust code
2. **Build Fails**: Check that you have the correct Rust toolchain installed
3. **Python Can't Find Module**: Ensure you're in the correct virtual environment

### Clean Build

#### With Nix
```bash
just clean-all  # Full cleanup including virtual environment
just setup      # Fresh setup
```

#### Without Nix
If you encounter issues, try a clean build:

```bash
./build.sh
```

### Environment Issues

**With Nix:**
- Try `direnv reload` if using direnv
- Exit and re-enter with `nix develop --reload`
- Check tool availability: `just info`
- See [NIX.md](NIX.md) for detailed troubleshooting

**Without Nix:**
- Ensure all prerequisites are installed
- Try recreating the virtual environment

## Template Initialization

This repository is a GitHub template. When you create a new repository from this template:

1. **Create the repository** using GitHub's "Use this template" button
2. **Run the initialization workflow**:
   - Go to the "Actions" tab in your new repository
   - Find the "Initialize Template" workflow
   - Click "Run workflow" and provide your project details (optional)
   - The workflow will automatically replace all `{{placeholders}}` with your values

### Template Parameters

The initialization workflow accepts these optional parameters:

- **project_name**: Project name (kebab-case, used in `pyproject.toml`)
- **python_package_name**: Python package name (snake_case, used for imports)
- **rust_core_module_name**: Rust core module name (snake_case)
- **author_name**: Your name
- **author_email**: Your email
- **project_description**: Brief project description

If you don't provide these, the workflow will derive sensible defaults from your repository name and GitHub profile.

### Troubleshooting Template Initialization

**Template Detection Issues**: The workflow automatically detects if it's running on the template vs. a created repository. If detection fails, it will exit safely.

**Workflow Failures**: If the initialization workflow fails, you can re-run it from the Actions tab. The workflow is designed to be idempotent and won't cause issues if run multiple times.

### Manual Template Development

If you're working on the template itself (not using it), you can make changes without triggering the initialization workflow since it only runs on manual dispatch.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- [PyO3 Documentation](https://pyo3.rs/)
- [Maturin Documentation](https://github.com/PyO3/maturin)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Python Packaging Guide](https://packaging.python.org/)
- [Nix Manual](https://nixos.org/manual/nix/stable/) - For Nix users
- [Just Manual](https://just.systems/man/en/) - Command runner documentation