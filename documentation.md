# Gleam Functional Utils Library - Complete Documentation

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Core Modules](#core-modules)
   - [gleam_fp/func - Function Utilities](#gleam_fpfunc---function-utilities)
   - [gleam_fp/option - Option Utilities](#gleam_fpoption---option-utilities)
   - [gleam_fp/result - Result Utilities](#gleam_fpresult---result-utilities)
   - [gleam_fp/list - List Utilities](#gleam_fplist---list-utilities)
   - [gleam_fp/predicate - Predicate Utilities](#gleam_fppredicate---predicate-utilities)
4. [Common Patterns](#common-patterns)
5. [Best Practices](#best-practices)

## Overview

The Gleam Functional Utils Library provides focused, small, and reusable helpers for Gleam's functional programming style. It works with core types like `Result`, `Option`, `List`, and functions rather than introducing new abstractions. The emphasis is on clarity and composability, aiming to feel like "missing pieces" from the Gleam standard library.

### Philosophy

- **Small & Composable**: Each function does one thing well and can be easily combined
- **Ergonomic**: Designed for ease of use in real-world applications
- **Type Safe**: Leverages Gleam's powerful type system
- **Pipeline Friendly**: All functions work naturally with Gleam's pipe operator

## Installation

```sh
gleam add gleam_fp
```

Then import the modules you need:

```gleam
import gleam_fp/func
import gleam_fp/option
import gleam_fp/result
import gleam_fp/list
import gleam_fp/predicate
```

## Core Modules

### gleam_fp/func - Function Utilities

Higher-order functions for function composition, transformation, and utility operations.

#### Function Composition

##### `compose(f, g)`
Composes two functions, applying g first, then f.

```gleam
import gleam_fp/func

let add_one = fn(x) { x + 1 }
let double = fn(x) { x * 2 }
let add_then_double = func.compose(double, add_one)

add_then_double(5) // 12 ((5 + 1) * 2)
```

#### Pipeline Functions

##### `pipe(value, functions)`
Applies a list of functions sequentially (same input/output type).

```gleam
let add_one = fn(x) { x + 1 }
let double = fn(x) { x * 2 }
let subtract_three = fn(x) { x - 3 }

5
|> func.pipe([add_one, double, subtract_three])
// Result: 9 (((5 + 1) * 2) - 3)
```

##### `pipe2(value, f1, f2)`, `pipe3(value, f1, f2, f3)`, `pipe4(value, f1, f2, f3, f4)`
Flexible pipeline functions for different types.

```gleam
import gleam/int

5
|> func.pipe3(
  fn(x) { x + 1 },           // Int -> Int
  fn(x) { x * 2 },           // Int -> Int  
  fn(x) { int.to_string(x) } // Int -> String
)
// Result: "12"
```

#### Function Transformation

##### `curry(f)` and `uncurry(f)`
Convert between curried and uncurried functions.

```gleam
let add = fn(a, b) { a + b }
let curried_add = func.curry(add)
let add_five = curried_add(5)

add_five(10) // 15

// Reverse operation
let uncurried_add = func.uncurry(curried_add)
uncurried_add(5, 10) // 15
```

#### Utility Functions

##### `identity(x)`
Returns its input unchanged.

```gleam
func.identity(42) // 42
[1, 2, 3] |> list.map(func.identity) // [1, 2, 3]
```

##### `constant(x)`
Creates a function that always returns the same value.

```gleam
let get_five = func.constant(5)
get_five(1) // 5
get_five("anything") // 5
```

##### `tap(x, f)`
Applies a function for side effects, returning the original value.

```gleam
import gleam/io

42
|> func.tap(fn(x) { io.println("Debug: " <> int.to_string(x)) })
|> fn(x) { x * 2 }
// Prints "Debug: 42" and returns 84
```

##### `flip(f)`
Reverses the argument order of a two-argument function.

```gleam
let subtract = fn(a, b) { a - b }
let flipped_subtract = func.flip(subtract)

subtract(10, 3) // 7
flipped_subtract(3, 10) // 7 (same as subtract(10, 3))
```

##### `apply(x, f)`
Applies a function to a value.

```gleam
let double = fn(x) { x * 2 }
func.apply(5, double) // 10
```

### gleam_fp/option - Option Utilities

Comprehensive utilities for working with `Option(a)` types, including transformations, combinations, and conversions.

#### Basic Operations

##### `map(option, function)`
Transforms the value inside Some, leaving None unchanged.

```gleam
import gleam/option
import gleam_fp/option

option.map(option.Some(5), fn(x) { x * 2 }) // Some(10)
option.map(option.None, fn(x) { x * 2 }) // None
```

##### `and_then(option, function)`
Chains operations that return Option (monadic bind).

```gleam
option.and_then(option.Some(5), fn(x) { option.Some(x * 2) }) // Some(10)
option.and_then(option.Some(5), fn(_) { option.None }) // None
```

#### Value Extraction

##### `unwrap_or(option, default)`
Extracts the value or returns a default.

```gleam
option.unwrap_or(option.Some(5), 0) // 5
option.unwrap_or(option.None, 0) // 0
```

##### `unwrap_or_else(option, function)`
Extracts the value or computes a default.

```gleam
option.unwrap_or_else(option.Some(5), fn() { 0 }) // 5
option.unwrap_or_else(option.None, fn() { 0 }) // 0
```

#### Filtering and Conditions

##### `filter(option, predicate)`
Filters an Option based on a predicate.

```gleam
option.filter(option.Some(5), fn(x) { x > 3 }) // Some(5)
option.filter(option.Some(2), fn(x) { x > 3 }) // None
```

##### `when(condition, value)`
Creates an Option based on a condition.

```gleam
option.when(True, 42) // Some(42)
option.when(False, 42) // None
```

#### Fallback Operations

##### `or(first, second)`
Returns the first Option if Some, otherwise the second.

```gleam
option.or(option.Some(5), option.Some(10)) // Some(5)
option.or(option.None, option.Some(10)) // Some(10)
```

##### `or_else(first, lazy_function)`
Like `or`, but the second Option is computed lazily.

```gleam
option.or_else(option.Some(5), fn() { option.Some(10) }) // Some(5)
option.or_else(option.None, fn() { option.Some(10) }) // Some(10)
```

#### Combining Options

##### `zip_with(opt1, opt2, function)`
Combines two Options using a function.

```gleam
option.zip_with(option.Some(5), option.Some(3), fn(a, b) { a + b }) // Some(8)
option.zip_with(option.Some(5), option.None, fn(a, b) { a + b }) // None
```

##### `zip(opt1, opt2)`
Combines two Options into a tuple.

```gleam
option.zip(option.Some(5), option.Some("hello")) // Some(#(5, "hello"))
```

#### Type Conversions

##### `to_result(option, error)`
Converts an Option to a Result.

```gleam
option.to_result(option.Some(5), "missing") // Ok(5)
option.to_result(option.None, "missing") // Error("missing")
```

##### `from_result(result)`
Converts a Result to an Option.

```gleam
option.from_result(Ok(5)) // Some(5)
option.from_result(Error("failed")) // None
```

#### Structure Manipulation

##### `flatten(nested_option)`
Flattens nested Options.

```gleam
option.flatten(option.Some(option.Some(5))) // Some(5)
option.flatten(option.Some(option.None)) // None
```

#### Side Effects

##### `tap_some(option, function)` and `tap_none(option, function)`
Apply side effects without changing the Option.

```gleam
import gleam/io

option.Some(42)
|> option.tap_some(fn(x) { io.println("Value: " <> int.to_string(x)) })
|> option.map(fn(x) { x * 2 })
// Prints "Value: 42" and returns Some(84)
```

#### Checking State

##### `is_some(option)` and `is_none(option)`
Check if an Option contains a value or is empty.

```gleam
option.is_some(option.Some(5)) // True
option.is_none(option.None) // True
```

### gleam_fp/result - Result Utilities

Comprehensive utilities for working with `Result(a, e)` types, including transformations, error handling, and conversions.

#### Basic Operations

##### `map(result, function)`
Transforms the Ok value, leaving Error unchanged.

```gleam
import gleam_fp/result

result.map(Ok(5), fn(x) { x * 2 }) // Ok(10)
result.map(Error("failed"), fn(x) { x * 2 }) // Error("failed")
```

##### `map_error(result, function)`
Transforms the Error value, leaving Ok unchanged.

```gleam
result.map_error(Ok(5), fn(e) { e <> "!" }) // Ok(5)
result.map_error(Error("failed"), fn(e) { e <> "!" }) // Error("failed!")
```

##### `and_then(result, function)`
Chains operations that return Result (monadic bind).

```gleam
result.and_then(Ok(5), fn(x) { Ok(x * 2) }) // Ok(10)
result.and_then(Ok(5), fn(_) { Error("failed") }) // Error("failed")
```

#### Value Extraction

##### `unwrap_or(result, default)`
Extracts the Ok value or returns a default.

```gleam
result.unwrap_or(Ok(5), 0) // 5
result.unwrap_or(Error("failed"), 0) // 0
```

##### `unwrap_or_else(result, function)`
Extracts the Ok value or computes a default from the Error.

```gleam
result.unwrap_or_else(Ok(5), fn(_) { 0 }) // 5
result.unwrap_or_else(Error("failed"), fn(e) {
  case e {
    "failed" -> -1
    _ -> 0
  }
}) // -1
```

#### Checking State

##### `is_ok(result)` and `is_error(result)`
Check if a Result is Ok or Error.

```gleam
result.is_ok(Ok(5)) // True
result.is_error(Error("failed")) // True
```

#### Side Effects

##### `tap_ok(result, function)` and `tap_error(result, function)`
Apply side effects without changing the Result.

```gleam
import gleam/io

Ok(42)
|> result.tap_ok(fn(x) { io.println("Success: " <> int.to_string(x)) })
|> result.map(fn(x) { x * 2 })
// Prints "Success: 42" and returns Ok(84)

Error("failed")
|> result.tap_error(fn(e) { io.println("Error: " <> e) })
|> result.map_error(fn(e) { e <> "!" })
// Prints "Error: failed" and returns Error("failed!")
```

### gleam_fp/list - List Utilities

Higher-order functions for list manipulation and querying.

#### Transformation

##### `flat_map(list, function)`
Maps a function over a list and flattens the result.

```gleam
import gleam_fp/list

list.flat_map([1, 2, 3], fn(x) { [x, x * 2] })
// Result: [1, 2, 2, 4, 3, 6]
```

##### `chunk(list, size)`
Splits a list into chunks of the specified size.

```gleam
list.chunk([1, 2, 3, 4, 5], 2) // [[1, 2], [3, 4], [5]]
list.chunk([1, 2, 3], 5) // [[1, 2, 3]]
list.chunk([], 2) // []
list.chunk([1, 2, 3], 0) // [] (gracefully handles invalid size)
```

##### `uniq(list)`
Removes duplicate elements, keeping the first occurrence.

```gleam
list.uniq([1, 2, 2, 3, 1, 4]) // [1, 2, 3, 4]
```

##### `filter(list, predicate)`
Keeps only elements that satisfy the predicate.

```gleam
list.filter([1, 2, 3, 4, 5], fn(x) { x % 2 == 0 }) // [2, 4]
```

#### Querying

##### `any(list, predicate)`
Returns True if any element satisfies the predicate.

```gleam
list.any([1, 2, 3, 4], fn(x) { x == 3 }) // True
list.any([1, 2, 4], fn(x) { x == 3 }) // False
list.any([], fn(x) { x == 3 }) // False
```

##### `all(list, predicate)`
Returns True if all elements satisfy the predicate.

```gleam
list.all([1, 2, 3, 4], fn(x) { x > 0 }) // True
list.all([1, 2, -3, 4], fn(x) { x > 0 }) // False
list.all([], fn(x) { x > 0 }) // True (vacuous truth)
```

### gleam_fp/predicate - Predicate Utilities

Boolean function combinators for creating complex predicates.

##### `not(predicate)`
Negates a predicate function.

```gleam
import gleam_fp/predicate

let is_even = fn(x) { x % 2 == 0 }
let is_odd = predicate.not(is_even)

is_odd(3) // True
is_odd(4) // False
```

##### `and(predicate1, predicate2)`
Combines two predicates with logical AND.

```gleam
let is_even = fn(x) { x % 2 == 0 }
let is_positive = fn(x) { x > 0 }
let is_even_and_positive = predicate.and(is_even, is_positive)

is_even_and_positive(4) // True
is_even_and_positive(3) // False
is_even_and_positive(-2) // False
```

##### `or(predicate1, predicate2)`
Combines two predicates with logical OR.

```gleam
let is_even = fn(x) { x % 2 == 0 }
let is_positive = fn(x) { x > 0 }
let is_even_or_positive = predicate.or(is_even, is_positive)

is_even_or_positive(3) // True (positive)
is_even_or_positive(4) // True (both)
is_even_or_positive(-1) // False (neither)
```

## Common Patterns

### Pipeline Composition

Combine multiple modules for powerful data processing pipelines:

```gleam
import gleam_fp/func
import gleam_fp/option
import gleam_fp/result
import gleam_fp/list
import gleam/option as gleam_option

// Processing user input with validation and fallbacks
pub fn process_user_score(input: String) -> String {
  input
  |> int.parse()
  |> option.from_result()
  |> option.filter(fn(score) { score >= 0 && score <= 100 })
  |> option.map(fn(score) {
    score
    |> func.pipe3(
      fn(s) { s * 2 },           // Double the score
      fn(s) { s + 10 },          // Add bonus points
      fn(s) { "Final: " <> int.to_string(s) }
    )
  })
  |> option.unwrap_or("Invalid score")
}
```

### Error Handling with Fallbacks

```gleam
pub fn safe_divide_with_logging(a: Int, b: Int) -> Result(Int, String) {
  case b == 0 {
    True -> Error("division by zero")
    False -> Ok(a / b)
  }
  |> result.tap_error(fn(e) { io.println("Math error: " <> e) })
  |> result.map_error(fn(e) { "Calculation failed: " <> e })
}

pub fn calculate_with_fallback(a: Int, b: Int) -> Int {
  safe_divide_with_logging(a, b)
  |> result.unwrap_or_else(fn(_) {
    // Fallback calculation
    a / 1
  })
}
```

### Option Chaining and Combination

```gleam
pub fn format_user_name(first: gleam_option.Option(String), last: gleam_option.Option(String)) -> String {
  option.zip_with(first, last, fn(f, l) { f <> " " <> l })
  |> option.filter(fn(name) { name != " " })
  |> option.or_else(fn() {
    first
    |> option.or(last)
    |> option.filter(fn(name) { name != "" })
  })
  |> option.unwrap_or("Anonymous")
}
```

### List Processing with Predicates

```gleam
import gleam_fp/predicate

pub fn process_numbers(numbers: List(Int)) -> List(String) {
  let is_positive = fn(x) { x > 0 }
  let is_even = fn(x) { x % 2 == 0 }
  let is_positive_even = predicate.and(is_positive, is_even)

  numbers
  |> list.filter(is_positive_even)
  |> list.chunk(3)
  |> list.flat_map(fn(chunk) {
    chunk
    |> list.map(fn(x) { "Num: " <> int.to_string(x) })
  })
  |> list.uniq()
}
```

### Function Composition Patterns

```gleam
pub fn create_text_processor() -> fn(String) -> String {
  let trim = string.trim
  let uppercase = string.uppercase
  let add_prefix = fn(s) { "PROCESSED: " <> s }

  func.compose(add_prefix, func.compose(uppercase, trim))
}

// Usage
pub fn process_text(input: String) -> String {
  input
  |> func.apply(create_text_processor())
}
```

## Best Practices

### 1. Use Pipelines for Readability

**Good:**
```gleam
user_input
|> option.filter(fn(x) { x > 0 })
|> option.map(fn(x) { x * 2 })
|> option.unwrap_or(0)
```

**Avoid:**
```gleam
option.unwrap_or(option.map(option.filter(user_input, fn(x) { x > 0 }), fn(x) { x * 2 }), 0)
```

### 2. Prefer Specific Pipe Functions

**Good:**
```gleam
value
|> func.pipe3(transform1, transform2, transform3)
```

**Less Ideal:**
```gleam
value
|> func.pipe([transform1, transform2, transform3])  // Requires same types
```

### 3. Use Tap for Debugging

```gleam
complex_calculation(input)
|> result.tap_ok(fn(x) { io.println("Intermediate result: " <> debug_format(x)) })
|> result.map(final_transform)
|> result.tap_error(fn(e) { io.println("Error occurred: " <> e) })
```

### 4. Combine Predicates for Complex Logic

```gleam
let is_valid_user = predicate.and(
  fn(user) { user.age >= 18 },
  predicate.and(
    fn(user) { user.email != "" },
    fn(user) { user.verified }
  )
)
```

### 5. Use Lazy Evaluation When Appropriate

**Good (lazy):**
```gleam
primary_option
|> option.or_else(fn() { expensive_computation() })
```

**Avoid (eager):**
```gleam
primary_option
|> option.or(expensive_computation())  // Always computed
```

### 6. Leverage Type Conversions

```gleam
// Convert between Option and Result as needed
database_lookup(id)
|> option.from_result()
|> option.filter(is_valid)
|> option.to_result("Invalid or missing record")
|> result.map(process_record)
```

### 7. Use Meaningful Function Names

```gleam
let is_adult = fn(age) { age >= 18 }
let is_valid_email = fn(email) { string.contains(email, "@") }

users
|> list.filter(fn(user) { is_adult(user.age) })
|> list.filter(fn(user) { is_valid_email(user.email) })
```

### 8. Compose Small Functions

```gleam
let validate_age = fn(age) { option.when(age >= 0 && age <= 150, age) }
let validate_email = fn(email) { option.when(string.contains(email, "@"), email) }

pub fn validate_user(age: Int, email: String) -> gleam_option.Option(#(Int, String)) {
  option.zip(validate_age(age), validate_email(email))
}
```

This library provides a comprehensive set of tools for functional programming in Gleam. By following these patterns and practices, you can write more expressive, maintainable, and robust code.
