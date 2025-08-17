import gleam/result

/// Transforms the Ok value, leaving Error unchanged.
///
/// ## Examples
///
/// ```gleam
/// map(Ok(5), fn(x) { x * 2 }) // Ok(10)
/// map(Error("failed"), fn(x) { x * 2 }) // Error("failed")
/// ```
pub fn map(r: Result(a, e), f: fn(a) -> b) -> Result(b, e) {
  result.map(r, f)
}

/// Transforms the Error value, leaving Ok unchanged.
///
/// ## Examples
///
/// ```gleam
/// map_error(Ok(5), fn(e) { e <> "!" }) // Ok(5)
/// map_error(Error("failed"), fn(e) { e <> "!" }) // Error("failed!")
/// ```
pub fn map_error(r: Result(a, e), f: fn(e) -> f) -> Result(a, f) {
  result.map_error(r, f)
}

/// Chains operations that return Result, flattening the result.
/// Also known as `bind` or `>>=` in other functional languages.
///
/// ## Examples
///
/// ```gleam
/// and_then(Ok(5), fn(x) { Ok(x * 2) }) // Ok(10)
/// and_then(Ok(5), fn(_) { Error("failed") }) // Error("failed")
/// and_then(Error("failed"), fn(x) { Ok(x * 2) }) // Error("failed")
/// ```
pub fn and_then(r: Result(a, e), f: fn(a) -> Result(b, e)) -> Result(b, e) {
  result.try(r, f)
}

/// Extracts the Ok value or returns the default for Error.
///
/// ## Examples
///
/// ```gleam
/// unwrap_or(Ok(5), 0) // 5
/// unwrap_or(Error("failed"), 0) // 0
/// ```
pub fn unwrap_or(r: Result(a, e), default: a) -> a {
  case r {
    Ok(x) -> x
    Error(_) -> default
  }
}

/// Extracts the Ok value or computes a default from the Error.
/// The function is only called if the result is Error.
///
/// ## Examples
///
/// ```gleam
/// unwrap_or_else(Ok(5), fn(_) { 0 }) // 5
/// unwrap_or_else(Error("failed"), fn(e) {
///   case e {
///     "failed" -> -1
///     _ -> 0
///   }
/// }) // -1
/// ```
pub fn unwrap_or_else(r: Result(a, e), f: fn(e) -> a) -> a {
  case r {
    Ok(x) -> x
    Error(e) -> f(e)
  }
}

/// Returns True if the result is Ok.
///
/// ## Examples
///
/// ```gleam
/// is_ok(Ok(5)) // True
/// is_ok(Error("failed")) // False
/// ```
pub fn is_ok(r: Result(a, e)) -> Bool {
  case r {
    Ok(_) -> True
    Error(_) -> False
  }
}

/// Returns True if the result is Error.
///
/// ## Examples
///
/// ```gleam
/// is_error(Ok(5)) // False
/// is_error(Error("failed")) // True
/// ```
pub fn is_error(r: Result(a, e)) -> Bool {
  case r {
    Ok(_) -> False
    Error(_) -> True
  }
}

/// Applies a function to the Ok value for side effects, returning the original result.
/// Useful for logging or debugging in a pipeline.
///
/// ## Examples
///
/// ```gleam
/// import gleam/io
///
/// Ok(42)
/// |> tap_ok(fn(x) { io.println("Success: " <> int.to_string(x)) })
/// |> map(fn(x) { x * 2 })
/// // Prints "Success: 42" and returns Ok(84)
/// ```
pub fn tap_ok(r: Result(a, e), f: fn(a) -> _) -> Result(a, e) {
  case r {
    Ok(x) -> {
      f(x)
      Ok(x)
    }
    Error(e) -> Error(e)
  }
}

/// Applies a function to the Error value for side effects, returning the original result.
/// Useful for logging errors in a pipeline.
///
/// ## Examples
///
/// ```gleam
/// import gleam/io
///
/// Error("failed")
/// |> tap_error(fn(e) { io.println("Error: " <> e) })
/// |> map_error(fn(e) { e <> "!" })
/// // Prints "Error: failed" and returns Error("failed!")
/// ```
pub fn tap_error(r: Result(a, e), f: fn(e) -> _) -> Result(a, e) {
  case r {
    Ok(x) -> Ok(x)
    Error(e) -> {
      f(e)
      Error(e)
    }
  }
}
