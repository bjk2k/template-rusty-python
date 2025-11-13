use pyo3::prelude::*;
use pyo3::types::PyModule;

#[pyfunction]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

// Now the module name is `{{RUST_CORE_MODULE_NAME}}`
// → Rust exports `PyInit_{{RUST_CORE_MODULE_NAME}}`
#[pymodule]
fn {{RUST_CORE_MODULE_NAME}}(_py: Python<'_>, m: &Bound<PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(add, m)?)?;
    Ok(())
}
