# Gleam Functional Utils Library

[![Package Version](https://img.shields.io/hexpm/v/fp_utils)](https://hex.pm/packages/fp_utils)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/fp_utils/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Small, composable functional helpers for Gleam.

**✨ Now available on Hex!** - Published v1.0.0

## Installation

Add this package to your Gleam project:

```sh
gleam add fp_utils
```

## Quick Start

```gleam
import fp_utils/func
import fp_utils/option
import fp_utils/result
import fp_utils/list
import fp_utils/predicate

// Pipeline-friendly functional programming
pub fn example() {
  [1, 2, 3, 4]
  |> list.filter(fn(x) { x > 2 })
  |> list.map(fn(x) { x * 2 })
  |> list.any(fn(x) { x > 5 })  // True
}

// Ergonomic Option handling
pub fn safe_divide(a: Int, b: Int) -> option.Option(Int) {
  option.when(b != 0, a / b)
  |> option.filter(fn(result) { result > 0 })
}
```

## Features

🚀 **54 functions** across 5 modules for comprehensive functional programming
🔧 **Pipeline-friendly** - designed to work seamlessly with Gleam's `|>` operator
📚 **Comprehensive docs** - every function documented with practical examples
✅ **100% test coverage** - thoroughly tested and reliable
🎯 **Ergonomic API** - focused on ease of use and developer experience
🔒 **Type-safe** - leverages Gleam's powerful type system

## Philosophy

This library provides focused, small, and reusable helpers for Gleam's functional programming style. It works with core types like `Result`, `Option`, `List`, and functions rather than introducing new abstractions. The emphasis is on clarity and composability, aiming to feel like "missing pieces" from the Gleam standard library.

## Core Modules & Ideas

### `fp/result`
Helpers for `Result(a, e)`:
- `map`: Transforms the `Ok` value.
- `map_error`: Transforms the `Error` value.
- `and_then`: Chains operations that return `Result`.
- `unwrap_or`: Extracts the `Ok` value or provides a default.
- `unwrap_or_else`: Extracts the `Ok` value or computes a default from the `Error` value.

### `fp/option`
Helpers for `Option(a)`:
- `map`: Transforms the `Some` value.
- `and_then`: Chains operations that return `Option`.
- `unwrap_or`: Extracts the `Some` value or provides a default.
- `unwrap_or_else`: Extracts the `Some` value or computes a default.
- `is_some`: Checks if the option is `Some`.
- `is_none`: Checks if the option is `None`.
- `filter`: Filters an Option based on a predicate.
- `or`: Returns the first Option if Some, otherwise the second.
- `or_else`: Like `or`, but the second Option is computed lazily.
- `to_result`: Converts an Option to a Result.
- `from_result`: Converts a Result to an Option.
- `zip_with`: Combines two Options using a function.
- `zip`: Combines two Options into a tuple.
- `flatten`: Flattens nested Options.
- `when_some`: Applies a function only if the Option is Some.
- `when`: Creates an Option based on a condition.
- `tap_some`: Side effects for Some values.
- `tap_none`: Side effects for None values.

### `fp/list`
Higher-order list helpers:
- `flat_map`: Maps and flattens a list.
- `chunk`: Splits a list into chunks of a specified size.
- `uniq`: Removes duplicate elements from a list (requires `Eq` trait).
- `any`: Checks if any element satisfies a predicate.
- `all`: Checks if all elements satisfy a predicate.
- `filter`: Keeps elements that satisfy a predicate.

### `fp/func`
Function-level helpers:
- `compose`: Composes two functions.
- `pipe`: Applies a list of functions sequentially to a value.
- `curry`: Curries a two-argument function.
- `uncurry`: Uncurries a curried function.
- `identity`: Returns its input unchanged.
- `constant`: Returns a function that always returns a constant value.

### `fp/predicate`
Helpers for working with boolean functions:
- `not`: Negates a predicate.
- `and`: Combines two predicates with logical AND.
- `or`: Combines two predicates with logical OR.

## Example Usage

```gleam
import fp_utils/result
import fp_utils/list
import fp_utils/func
import fp_utils/option
import gleam/option as gleam_option

pub fn example() -> Bool {
  [1, 2, 3, 4]
  |> list.flat_map(fn(x) { [x, x * 2] })
  |> list.filter(fn(x) { x > 2 })
  |> list.uniq()
  |> list.any(fn(x) { x == 6 }) // true
}

pub fn safe_divide(a: Int, b: Int) -> Result(Int, String) {
  case b == 0 {
    True -> Error("division by zero")
    False -> Ok(a / b)
  }
}

pub fn demo() -> Int {
  safe_divide(10, 2)
  |> result.map(fn(x) { x * 2 })
  |> result.unwrap_or(0) // 10
}

// New Option utilities in action
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

// Combining Options ergonomically
pub fn combine_options_demo() -> gleam_option.Option(Int) {
  let first = gleam_option.Some(10)
  let second = gleam_option.Some(5)

  option.zip_with(first, second, fn(a, b) { a + b })
  |> option.filter(fn(sum) { sum > 10 })
  // Some(15)
}
```

## Naming & Packaging

The package name is `fp_utils`.
Modules are organized under `fp_utils/`, e.g., `fp_utils/result`, `fp_utils/option`.

## Future Extensions

- `fp_utils/dict` helpers (map, filter, merge, etc.).
- `fp_utils/validation` for multi-error accumulation.
- `fp_utils/maybe_async` for async combinators.

## Links

- **Package**: [hex.pm/packages/fp_utils](https://hex.pm/packages/fp_utils)
- **Documentation**: [hexdocs.pm/fp_utils](https://hexdocs.pm/fp_utils/)
- **Repository**: [github.com/alexzzzs/Gleam-FP](https://github.com/alexzzzs/Gleam-FP)