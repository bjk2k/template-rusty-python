#!/bin/bash
set -e

# 1) Clean Rust
cd rust-core
cargo clean
cd ..

# 2) Clean Python venv
cd python
rm -rf .venv

# 3) Recreate env & install deps
uv venv
source .venv/bin/activate
uv sync

# 4) Build + install Rust extension
uv run maturin develop

# 5) Install the Python package in editable mode
uv pip install -e .

# 6) Sanity checks
uv run python -c "import template_project_core as m; print('EXT:', m.__file__)"
uv run python -c 'from template_project import add; print("ADD:", add(2, 3))'

# 7) Run tests
uv run pytest



