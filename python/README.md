# {{PYTHON_PACKAGE_NAME}}

The Python package component of {{PROJECT_NAME}}.

This package provides a Python interface to high-performance Rust implementations using PyO3 and Maturin.

## Installation

### From Source

```bash
# Clone the repository and navigate to the python directory
cd python

# Create and activate virtual environment
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
uv sync

# Build and install the Rust extension
uv run maturin develop

# Install the package in editable mode
uv pip install -e .
```

### Development Installation

For development with hot-reload:

```bash
cd python
uv run maturin develop
```

## Usage

```python
from {{PYTHON_PACKAGE_NAME}} import add

result = add(2, 3)
print(result)  # Output: 5
```

## Testing

Run the test suite:

```bash
uv run pytest
```

## Building Wheels

To build distribution wheels:

```bash
# Development build
uv run maturin develop

# Release build
uv run maturin build --release

# Publish to PyPI
uv run maturin publish
```

## API Reference

### Functions

#### `add(a: int, b: int) -> int`

Adds two integers using a high-performance Rust implementation.

**Parameters:**
- `a`: First integer
- `b`: Second integer

**Returns:**
- The sum of `a` and `b`

**Example:**
```python
from {{PYTHON_PACKAGE_NAME}} import add
result = add(10, 20)  # Returns 30
```

## Development

The Python package serves as a wrapper around the Rust core library. The actual implementations are written in Rust for performance, while this package provides a convenient Python interface.

### Adding New Functions

1. Implement the function in the Rust core (`../rust-core/src/lib.rs`)
2. Add the Python wrapper in `src/{{PYTHON_PACKAGE_NAME}}/api.py`
3. Export it in `src/{{PYTHON_PACKAGE_NAME}}/__init__.py`
4. Rebuild with `uv run maturin develop`

## Dependencies

- **Runtime**: numpy, plotly
- **Development**: pytest, maturin, black, jupyter, ipykernel

For the complete list, see `pyproject.toml`.