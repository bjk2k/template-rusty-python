# {{PROJECT_NAME}} - Development Commands
# Just is a command runner similar to make but simpler
# Install with: cargo install just

# Default recipe shows available commands
default:
    @just --list

# Set up development environment
setup:
    #!/usr/bin/env bash
    set -e
    echo "🚀 Setting up {{PROJECT_NAME}} development environment..."

    # Check if we're in a Nix environment
    if [ -n "${IN_NIX_SHELL:-}" ] || command -v nix-shell > /dev/null 2>&1; then
        echo "📦 Detected Nix environment - using system Python"
    fi

    # Create Python virtual environment if it doesn't exist
    if [ ! -d python/.venv ]; then
        echo "📦 Creating Python virtual environment..."
        cd python
        uv venv
        cd ..
    fi

    echo "📥 Installing Python dependencies..."
    cd python
    source .venv/bin/activate
    uv sync

    echo "🦀 Building Rust extension..."
    uv run maturin develop

    echo "🐍 Installing Python package in development mode..."
    uv pip install -e .
    cd ..

    echo "✅ Setup complete!"
    echo ""
    echo "Test the installation:"
    echo "  just check"

# Build the Rust extension in development mode
dev:
    #!/usr/bin/env bash
    set -e
    echo "🔨 Building Rust extension in development mode..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run maturin develop
    echo "✅ Development build complete!"

# Build the Rust extension in release mode
build:
    #!/usr/bin/env bash
    set -e
    echo "🚀 Building Rust extension in release mode..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run maturin build --release
    echo "✅ Release build complete! Wheels are in python/target/wheels/"

# Run all tests
test:
    #!/usr/bin/env bash
    set -e
    echo "🧪 Running Python tests..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run pytest -v
    cd ..

    echo "🦀 Running Rust tests..."
    cd rust-core
    cargo test
    cd ..

    echo "✅ All tests passed!"

# Run tests with coverage
test-coverage:
    #!/usr/bin/env bash
    set -e
    echo "🧪 Running Python tests with coverage..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run pytest --cov={{PYTHON_PACKAGE_NAME}} --cov-report=html --cov-report=term

# Format all code
fmt:
    #!/usr/bin/env bash
    set -e
    echo "🎨 Formatting Rust code..."
    cd rust-core
    cargo fmt
    cd ..

    echo "🎨 Formatting Python code..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run black .
    cd ..

    echo "✅ Code formatting complete!"

# Check code formatting without making changes
fmt-check:
    #!/usr/bin/env bash
    set -e
    echo "🔍 Checking Rust code formatting..."
    cd rust-core
    cargo fmt --check
    cd ..

    echo "🔍 Checking Python code formatting..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run black --check .
    cd ..

    echo "✅ All code is properly formatted!"

# Lint all code
lint:
    #!/usr/bin/env bash
    set -e
    echo "🔍 Linting Rust code..."
    cd rust-core
    cargo clippy -- -D warnings
    cd ..

    echo "🔍 Checking Python code style..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    if uv run python -c "import ruff" 2>/dev/null; then
        uv run ruff check .
    else
        echo "⚠️  Ruff not installed, skipping Python linting"
    fi
    cd ..

    echo "✅ Linting complete!"

# Clean build artifacts
clean:
    #!/usr/bin/env bash
    set -e
    echo "🧹 Cleaning Rust build artifacts..."
    cd rust-core
    cargo clean
    cd ..

    echo "🧹 Cleaning Python build artifacts..."
    cd python
    rm -rf target/ dist/ build/ .pytest_cache/ htmlcov/
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    find . -type f -name "*.pyo" -delete 2>/dev/null || true
    find . -type f -name "*.so" -delete 2>/dev/null || true
    cd ..

    echo "✅ Cleanup complete!"

# Full clean including virtual environment
clean-all: clean
    #!/usr/bin/env bash
    set -e
    echo "🧹 Removing Python virtual environment..."
    rm -rf python/.venv
    echo "✅ Full cleanup complete!"

# Run a quick sanity check
check:
    #!/usr/bin/env bash
    set -e
    echo "🔍 Running sanity checks..."

    # Check if Python venv exists
    if [ ! -d "python/.venv" ]; then
        echo "❌ Python virtual environment not found. Run 'just setup' first."
        exit 1
    fi

    cd python
    source .venv/bin/activate

    echo "  Checking Rust core import..."
    if uv run python -c "import {{RUST_CORE_MODULE_NAME}} as core; print('✅ Rust core loaded successfully')" 2>/dev/null; then
        echo "    ✅ Rust core: OK"
    else
        echo "    ❌ Rust core: FAILED (run 'just dev' to build)"
        exit 1
    fi

    echo "  Checking Python package import..."
    if uv run python -c "from {{PYTHON_PACKAGE_NAME}} import add; print('✅ Python package loaded successfully')" 2>/dev/null; then
        echo "    ✅ Python package: OK"
    else
        echo "    ❌ Python package: FAILED"
        exit 1
    fi

    echo "  Testing functionality..."
    if uv run python -c "from {{PYTHON_PACKAGE_NAME}} import add; result = add(2, 3); assert result == 5; print(f'✅ add(2, 3) = {result}')" 2>/dev/null; then
        echo "    ✅ Functionality: OK"
    else
        echo "    ❌ Functionality: FAILED"
        exit 1
    fi

    cd ..
    echo "🎉 All checks passed!"

# Watch for changes and rebuild automatically
watch:
    #!/usr/bin/env bash
    echo "👀 Watching for changes (Ctrl+C to stop)..."
    if command -v cargo-watch > /dev/null; then
        cd rust-core
        cargo watch -x check -s 'echo "🔄 Rebuilding..." && cd ../python && uv run maturin develop && echo "✅ Rebuild complete!"'
    else
        echo "❌ cargo-watch not found."
        if command -v nix > /dev/null; then
            echo "   In Nix environment, it should be available. Try: nix develop --reload"
        else
            echo "   Install with: cargo install cargo-watch"
        fi
        exit 1
    fi

# Build wheels for distribution
wheel:
    #!/usr/bin/env bash
    set -e
    echo "📦 Building distribution wheels..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    rm -rf dist/
    uv run maturin build --release --out dist/
    echo "✅ Wheels built in python/dist/"

# Publish to PyPI (use with caution!)
publish:
    #!/usr/bin/env bash
    set -e
    echo "🚀 Publishing to PyPI..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run maturin publish

# Publish to Test PyPI
publish-test:
    #!/usr/bin/env bash
    set -e
    echo "🚀 Publishing to Test PyPI..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv run maturin publish --repository testpypi

# Run benchmarks (if available)
bench:
    #!/usr/bin/env bash
    set -e
    echo "🏃 Running Rust benchmarks..."
    cd rust-core
    if grep -q "criterion" Cargo.toml; then
        cargo bench
    else
        echo "⚠️  No benchmarks configured. Add criterion to Cargo.toml to enable benchmarks."
    fi
    cd ..

# Generate documentation
docs:
    #!/usr/bin/env bash
    set -e
    echo "📚 Generating Rust documentation..."
    cd rust-core
    cargo doc --no-deps --open
    cd ..

# Update dependencies
update:
    #!/usr/bin/env bash
    set -e
    echo "📦 Updating Rust dependencies..."
    cd rust-core
    cargo update
    cd ..

    echo "📦 Updating Python dependencies..."
    cd python
    if [ -f .venv/bin/activate ]; then
        source .venv/bin/activate
    fi
    uv sync --upgrade
    cd ..

    echo "✅ Dependencies updated!"

# Full development setup and verification
full-setup: setup check
    @echo "🎉 Full setup complete and verified!"

# CI-like check (format, lint, test)
ci: fmt-check lint test
    @echo "✅ CI checks passed!"

# Show project information
info:
    #!/usr/bin/env bash
    echo "📊 {{PROJECT_NAME}} - Project Information"
    echo "========================================="
    echo "Description: {{PROJECT_DESCRIPTION}}"
    echo "Author: {{AUTHOR_NAME}}"
    echo ""

    # Environment info
    if [ -n "${IN_NIX_SHELL:-}" ]; then
        echo "🏠 Environment: Nix Shell"
    elif command -v nix > /dev/null; then
        echo "🏠 Environment: Nix available"
    else
        echo "🏠 Environment: Manual setup"
    fi
    echo ""

    # Tool versions
    echo "🔧 Tool Versions:"
    if command -v python > /dev/null; then
        echo "  Python: $(python --version)"
    else
        echo "  Python: ❌ not found"
    fi

    if command -v rustc > /dev/null; then
        echo "  Rust: $(rustc --version | cut -d' ' -f1-2)"
    else
        echo "  Rust: ❌ not found"
    fi

    if command -v uv > /dev/null; then
        echo "  UV: $(uv --version)"
    else
        echo "  UV: ❌ not found"
    fi

    if command -v maturin > /dev/null; then
        echo "  Maturin: $(maturin --version)"
    else
        echo "  Maturin: ❌ not found"
    fi

    if command -v just > /dev/null; then
        echo "  Just: $(just --version)"
    else
        echo "  Just: ❌ not found"
    fi

    echo ""
    echo "📁 Project Status:"
    if [ -d python/.venv ]; then
        echo "  ✅ Python virtual environment: present"
    else
        echo "  ❌ Python virtual environment: missing (run 'just setup')"
    fi

    if [ -d rust-core/target ]; then
        echo "  ✅ Rust build artifacts: present"
    else
        echo "  ❌ Rust build artifacts: missing (run 'just dev')"
    fi

    if [ -f python/.venv/bin/activate ]; then
        cd python
        source .venv/bin/activate
        if python -c "import {{RUST_CORE_MODULE_NAME}}" 2>/dev/null; then
            echo "  ✅ Rust extension: installed and importable"
        else
            echo "  ❌ Rust extension: not importable (run 'just dev')"
        fi
        cd ..
    fi
