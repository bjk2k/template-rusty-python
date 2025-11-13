use pyo3::prelude::*;
use pyo3::types::PyModule;

#[pyfunction]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

// Now the module name is `template_project_core`
// → Rust exports `PyInit_template_project_core`
#[pymodule]
fn template_project_core(_py: Python<'_>, m: &Bound<PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(add, m)?)?;
    Ok(())
}
