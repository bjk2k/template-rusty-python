import {{RUST_CORE_MODULE_NAME}} as core


def add(a: int, b: int) -> int:
    """High-level Python wrapper around the Rust implementation."""
    return core.add(a, b)
