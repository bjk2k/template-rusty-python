import template_project_core as core


def add(a: int, b: int) -> int:
    """High-level Python wrapper around the Rust implementation."""
    return core.add(a, b)
