# Template Usage Guide

This is a GitHub template repository for creating Rust-Python hybrid projects using PyO3 and Maturin.

## 🚀 Quick Start

### Step 1: Create Repository from Template

1. Click the **"Use this template"** button at the top of this repository
2. Choose "Create a new repository"
3. Fill in your repository details:
   - Repository name (use kebab-case like `my-awesome-project`)
   - Description
   - Public or Private
4. Click "Create repository"

### Step 2: Initialize Your Project

After creating your repository:

1. Go to the **Actions** tab in your new repository
2. Find the **"Initialize Template"** workflow in the workflow list
3. Click **"Run workflow"** button
4. (Optional) Fill in the form with your project details:
   - **Project name**: Will default to your repository name
   - **Python package name**: Will default to repository name in snake_case
   - **Rust core module name**: Will default to `{package_name}_core`
   - **Author name**: Will default to your GitHub username
   - **Author email**: Will default to your GitHub email
   - **Project description**: Add a custom description
5. Click **"Run workflow"**

The workflow will automatically:
- Replace all `{{placeholder}}` values with your project-specific values
- Rename the Python package directory
- Clean up template-specific files
- Commit the changes to your repository

### Step 3: Clone and Develop

Once initialization is complete:

```bash
# Clone your repository
git clone https://github.com/yourusername/your-project-name.git
cd your-project-name

# Option A: With Nix (Recommended)
direnv allow              # If using direnv
# OR
nix develop               # Enter development shell

just setup                # Set up development environment
just check                # Verify everything works

# Option B: Manual setup
./build.sh               # Build and set up everything
```

## 🎯 What You Get

After initialization, your project will have:

### Core Structure
- **Rust library** (`rust-core/`) - High-performance implementations
- **Python package** (`python/`) - Python API wrapper
- **Nix environment** - Reproducible development setup
- **GitHub Actions** - CI/CD pipeline
- **Just commands** - Convenient development tasks

### Development Tools
- **PyO3** - Rust-Python bindings
- **Maturin** - Python wheel builder
- **UV** - Fast Python package manager
- **Just** - Command runner
- **direnv** - Automatic environment loading

### Documentation
- `README.md` - Your project documentation
- `DEVELOPMENT.md` - Development guide
- `NIX.md` - Nix setup and usage guide

## 📝 Customization

After initialization, you can customize:

1. **Add dependencies**:
   - Python: Edit `python/pyproject.toml`
   - Rust: Edit `rust-core/Cargo.toml`
   - System: Edit `flake.nix`

2. **Add functionality**:
   - Rust functions: `rust-core/src/lib.rs`
   - Python wrappers: `python/src/{your_package}/api.py`
   - Tests: `python/tests/`

3. **Update documentation**:
   - Project README
   - API documentation
   - Examples and tutorials

## 🔧 Development Commands

With the Nix environment and Just:

```bash
just setup      # Initial setup
just dev        # Development build
just test       # Run tests
just fmt        # Format code
just lint       # Lint code
just check      # Quick sanity check
just clean      # Clean artifacts
just --list     # Show all commands
```

## 🆘 Troubleshooting

### Template Not Initialized
- Make sure you ran the "Initialize Template" workflow
- Check the Actions tab for any workflow errors
- The workflow only runs on manual trigger

### Build Issues
- Ensure you're using the Nix environment or have all prerequisites
- Try `just clean && just setup` for a fresh start
- Check `just info` to see your environment status

### Import Errors
- Run `just dev` to rebuild the Rust extension
- Ensure you're in the Python virtual environment
- Check that the package was installed: `just check`

## 🎉 You're Ready!

Your project is now set up and ready for development. The template provides:

✅ Reproducible development environment with Nix  
✅ Rust-Python integration with PyO3  
✅ Modern Python packaging with UV and Maturin  
✅ Automated testing and CI/CD  
✅ Comprehensive documentation  
✅ Convenient development commands  

Happy coding! 🦀🐍

---

*This file will be automatically removed after template initialization.*