import fp/func
import fp/list
import fp/option
import fp/result
import gleam/int
import gleam/option as gleam_option

/// Example showcasing list operations
pub fn example() -> Bool {
  [1, 2, 3, 4]
  |> list.flat_map(fn(x) { [x, x * 2] })
  |> list.filter(fn(x) { x > 2 })
  |> list.uniq()
  |> list.any(fn(x) { x == 6 })
  // true
}

/// Safe division function
pub fn safe_divide(a: Int, b: Int) -> Result(Int, String) {
  case b == 0 {
    True -> Error("division by zero")
    False -> Ok(a / b)
  }
}

/// Example showcasing result operations with new ergonomic functions
pub fn demo() -> Int {
  safe_divide(10, 2)
  |> result.tap_ok(fn(_) {
    // Could log success here
    Nil
  })
  |> result.map(fn(x) { x * 2 })
  |> result.unwrap_or(0)
  // 10
}

/// Example showcasing new pipe functions for better ergonomics
pub fn pipeline_demo() -> String {
  42
  |> func.pipe3(
    fn(x) { x + 8 },
    // 50
    fn(x) { x * 2 },
    // 100
    fn(x) { "Result: " <> int.to_string(x) },
    // "Result: 100"
  )
}

/// Example showcasing function composition and utilities
pub fn composition_demo() -> Int {
  let add_ten = fn(x) { x + 10 }
  let double = fn(x) { x * 2 }
  let composed = func.compose(double, add_ten)

  5
  |> func.tap(fn(_x) {
    // Could log the input value
    Nil
  })
  |> func.apply(composed)
  // (5 + 10) * 2 = 30
}

/// Example showcasing new Option utilities for ergonomic data handling
pub fn option_pipeline_demo() -> String {
  gleam_option.Some(42)
  |> option.filter(fn(x) { x > 0 })
  |> option.map(fn(x) { x * 2 })
  |> option.or(gleam_option.Some(0))
  |> option.to_result("missing value")
  |> result.map(fn(x) { "Result: " <> int.to_string(x) })
  |> result.unwrap_or("No result")
  // "Result: 84"
}

/// Example showcasing Option combination and fallback patterns
pub fn option_fallback_demo() -> gleam_option.Option(Int) {
  let primary = gleam_option.None
  let fallback = gleam_option.Some(42)

  primary
  |> option.or_else(fn() { fallback })
  |> option.filter(fn(x) { x > 0 })
  // Some(42)
}

/// Example showcasing Option zipping for combining multiple values
pub fn combine_options_demo() -> gleam_option.Option(String) {
  let first_name = gleam_option.Some("John")
  let last_name = gleam_option.Some("Doe")

  option.zip_with(first_name, last_name, fn(first, last) {
    first <> " " <> last
  })
  |> option.filter(fn(name) { name != "" })
  // Some("John Doe")
}

/// Example showcasing conditional Option creation
pub fn conditional_option_demo(score: Int) -> gleam_option.Option(String) {
  option.when(score >= 90, "Excellent!")
  |> option.or_else(fn() { option.when(score >= 70, "Good!") })
  |> option.or_else(fn() { option.when(score >= 50, "Pass") })
  // Returns appropriate message based on score, or None if below 50
}
