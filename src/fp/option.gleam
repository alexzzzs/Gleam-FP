import gleam/option

/// Transforms the value inside Some, leaving None unchanged.
///
/// ## Examples
///
/// ```gleam
/// map(Some(5), fn(x) { x * 2 }) // Some(10)
/// map(None, fn(x) { x * 2 }) // None
/// ```
pub fn map(o: option.Option(a), f: fn(a) -> b) -> option.Option(b) {
  option.map(o, f)
}

/// Chains operations that return Option, flattening the result.
/// Also known as `bind` or `>>=` in other functional languages.
///
/// ## Examples
///
/// ```gleam
/// and_then(Some(5), fn(x) { Some(x * 2) }) // Some(10)
/// and_then(Some(5), fn(_) { None }) // None
/// and_then(None, fn(x) { Some(x * 2) }) // None
/// ```
pub fn and_then(
  o: option.Option(a),
  f: fn(a) -> option.Option(b),
) -> option.Option(b) {
  option.then(o, f)
}

/// Extracts the value from Some or returns the default for None.
///
/// ## Examples
///
/// ```gleam
/// unwrap_or(Some(5), 0) // 5
/// unwrap_or(None, 0) // 0
/// ```
pub fn unwrap_or(o: option.Option(a), default: a) -> a {
  option.unwrap(o, default)
}

/// Extracts the value from Some or computes a default for None.
/// The function is only called if the option is None.
///
/// ## Examples
///
/// ```gleam
/// unwrap_or_else(Some(5), fn() { 0 }) // 5
/// unwrap_or_else(None, fn() { 0 }) // 0
/// ```
pub fn unwrap_or_else(o: option.Option(a), f: fn() -> a) -> a {
  option.lazy_unwrap(o, f)
}

/// Returns True if the option contains a value.
///
/// ## Examples
///
/// ```gleam
/// is_some(Some(5)) // True
/// is_some(None) // False
/// ```
pub fn is_some(o: option.Option(a)) -> Bool {
  option.is_some(o)
}

/// Returns True if the option is None.
///
/// ## Examples
///
/// ```gleam
/// is_none(Some(5)) // False
/// is_none(None) // True
/// ```
pub fn is_none(o: option.Option(a)) -> Bool {
  option.is_none(o)
}

/// Applies a function to the Some value for side effects, returning the original option.
/// Useful for logging or debugging in a pipeline.
///
/// ## Examples
///
/// ```gleam
/// import gleam/io
///
/// Some(42)
/// |> tap_some(fn(x) { io.println("Value: " <> int.to_string(x)) })
/// |> map(fn(x) { x * 2 })
/// // Prints "Value: 42" and returns Some(84)
/// ```
pub fn tap_some(o: option.Option(a), f: fn(a) -> _) -> option.Option(a) {
  case o {
    option.Some(x) -> {
      f(x)
      option.Some(x)
    }
    option.None -> option.None
  }
}

/// Applies a function for side effects when the option is None, returning the original option.
/// Useful for logging when values are missing.
///
/// ## Examples
///
/// ```gleam
/// import gleam/io
///
/// None
/// |> tap_none(fn() { io.println("No value found") })
/// |> unwrap_or(0)
/// // Prints "No value found" and returns 0
/// ```
pub fn tap_none(o: option.Option(a), f: fn() -> _) -> option.Option(a) {
  case o {
    option.Some(x) -> option.Some(x)
    option.None -> {
      f()
      option.None
    }
  }
}

/// Filters an Option based on a predicate. Returns None if the predicate fails.
///
/// ## Examples
///
/// ```gleam
/// filter(Some(5), fn(x) { x > 3 }) // Some(5)
/// filter(Some(2), fn(x) { x > 3 }) // None
/// filter(None, fn(x) { x > 3 }) // None
/// ```
pub fn filter(o: option.Option(a), predicate: fn(a) -> Bool) -> option.Option(a) {
  case o {
    option.Some(x) ->
      case predicate(x) {
        True -> option.Some(x)
        False -> option.None
      }
    option.None -> option.None
  }
}

/// Returns the first Option if it's Some, otherwise returns the second Option.
/// Useful for providing fallback values.
///
/// ## Examples
///
/// ```gleam
/// or(Some(5), Some(10)) // Some(5)
/// or(None, Some(10)) // Some(10)
/// or(Some(5), None) // Some(5)
/// or(None, None) // None
/// ```
pub fn or(first: option.Option(a), second: option.Option(a)) -> option.Option(a) {
  case first {
    option.Some(_) -> first
    option.None -> second
  }
}

/// Like `or`, but the second Option is computed lazily.
/// Only evaluates the function if the first Option is None.
///
/// ## Examples
///
/// ```gleam
/// or_else(Some(5), fn() { Some(10) }) // Some(5)
/// or_else(None, fn() { Some(10) }) // Some(10)
/// ```
pub fn or_else(
  first: option.Option(a),
  f: fn() -> option.Option(a),
) -> option.Option(a) {
  case first {
    option.Some(_) -> first
    option.None -> f()
  }
}

/// Converts an Option to a Result, using the provided error for None.
///
/// ## Examples
///
/// ```gleam
/// to_result(Some(5), "missing") // Ok(5)
/// to_result(None, "missing") // Error("missing")
/// ```
pub fn to_result(o: option.Option(a), error: e) -> Result(a, e) {
  case o {
    option.Some(x) -> Ok(x)
    option.None -> Error(error)
  }
}

/// Converts a Result to an Option, discarding any error information.
///
/// ## Examples
///
/// ```gleam
/// from_result(Ok(5)) // Some(5)
/// from_result(Error("failed")) // None
/// ```
pub fn from_result(r: Result(a, _)) -> option.Option(a) {
  case r {
    Ok(x) -> option.Some(x)
    Error(_) -> option.None
  }
}

/// Combines two Options using a function. Returns None if either Option is None.
///
/// ## Examples
///
/// ```gleam
/// zip_with(Some(5), Some(3), fn(a, b) { a + b }) // Some(8)
/// zip_with(Some(5), None, fn(a, b) { a + b }) // None
/// zip_with(None, Some(3), fn(a, b) { a + b }) // None
/// ```
pub fn zip_with(
  first: option.Option(a),
  second: option.Option(b),
  f: fn(a, b) -> c,
) -> option.Option(c) {
  case first, second {
    option.Some(a), option.Some(b) -> option.Some(f(a, b))
    _, _ -> option.None
  }
}

/// Combines two Options into a tuple. Returns None if either Option is None.
///
/// ## Examples
///
/// ```gleam
/// zip(Some(5), Some("hello")) // Some(#(5, "hello"))
/// zip(Some(5), None) // None
/// zip(None, Some("hello")) // None
/// ```
pub fn zip(
  first: option.Option(a),
  second: option.Option(b),
) -> option.Option(#(a, b)) {
  zip_with(first, second, fn(a, b) { #(a, b) })
}

/// Flattens a nested Option. Converts Option(Option(a)) to Option(a).
///
/// ## Examples
///
/// ```gleam
/// flatten(Some(Some(5))) // Some(5)
/// flatten(Some(None)) // None
/// flatten(None) // None
/// ```
pub fn flatten(o: option.Option(option.Option(a))) -> option.Option(a) {
  case o {
    option.Some(inner) -> inner
    option.None -> option.None
  }
}

/// Applies a function that returns an Option, but only if the input Option is Some.
/// This is like `and_then` but the function doesn't need to return an Option.
///
/// ## Examples
///
/// ```gleam
/// when_some(Some(5), fn(x) { x > 3 }) // Some(True)
/// when_some(Some(2), fn(x) { x > 3 }) // Some(False)
/// when_some(None, fn(x) { x > 3 }) // None
/// ```
pub fn when_some(o: option.Option(a), f: fn(a) -> b) -> option.Option(b) {
  map(o, f)
}

/// Returns Some(value) if the condition is true, otherwise None.
/// Useful for conditional Option creation.
///
/// ## Examples
///
/// ```gleam
/// when(True, 42) // Some(42)
/// when(False, 42) // None
/// ```
pub fn when(condition: Bool, value: a) -> option.Option(a) {
  case condition {
    True -> option.Some(value)
    False -> option.None
  }
}
