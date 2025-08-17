import fp/func
import gleam/int
import gleeunit
import gleeunit/should

// import gleam/list // Removed unused import
import fp/option
import gleam/option as gleam_option

// Import gleam/option with an alias
import fp/list
import fp/predicate
import fp/result

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn compose_test() {
  let add_one = fn(x) { x + 1 }
  let multiply_by_two = fn(x) { x * 2 }
  let add_one_then_multiply_by_two = func.compose(multiply_by_two, add_one)
  add_one_then_multiply_by_two(5)
  |> should.equal(12)
  // (5 + 1) * 2 = 12

  let multiply_by_two_then_add_one = func.compose(add_one, multiply_by_two)
  multiply_by_two_then_add_one(5)
  |> should.equal(11)
  // (5 * 2) + 1 = 11
}

pub fn pipe_test() {
  let add_one = fn(x) { x + 1 }
  let multiply_by_two = fn(x) { x * 2 }
  let subtract_three = fn(x) { x - 3 }

  5
  |> func.pipe([add_one, multiply_by_two, subtract_three])
  |> should.equal(9)
  // (5 + 1) * 2 - 3 = 9

  10
  |> func.pipe([])
  |> should.equal(10)

  // Test new pipe functions
  5
  |> func.pipe2(add_one, multiply_by_two)
  |> should.equal(12)
  // (5 + 1) * 2 = 12

  5
  |> func.pipe3(add_one, multiply_by_two, subtract_three)
  |> should.equal(9)
  // ((5 + 1) * 2) - 3 = 9

  // Test pipe4
  let add_two = fn(x) { x + 2 }
  5
  |> func.pipe4(add_one, multiply_by_two, subtract_three, add_two)
  |> should.equal(11)
  // (((5 + 1) * 2) - 3) + 2 = 11
}

pub fn curry_test() {
  let add = fn(a, b) { a + b }
  let curried_add = func.curry(add)

  curried_add(5)(10)
  |> should.equal(15)
}

pub fn uncurry_test() {
  let curried_add = fn(a) { fn(b) { a + b } }
  let uncurried_add = func.uncurry(curried_add)

  uncurried_add(5, 10)
  |> should.equal(15)
}

pub fn identity_test() {
  func.identity(10)
  |> should.equal(10)

  func.identity("hello")
  |> should.equal("hello")
}

pub fn constant_test() {
  let get_five = func.constant(5)
  get_five(1)
  |> should.equal(5)
  // Removed: get_five("anything") |> should.equal(5) // This caused the type error
}

pub fn utility_functions_test() {
  // tap - should return original value after applying side effect
  let result = func.tap(42, fn(_) { Nil })
  result
  |> should.equal(42)

  // tap in a pipeline
  42
  |> func.tap(fn(_) { Nil })
  |> fn(x) { x * 2 }
  |> should.equal(84)

  // flip - should reverse argument order
  let subtract = fn(a, b) { a - b }
  let flipped_subtract = func.flip(subtract)
  subtract(10, 3)
  |> should.equal(7)
  flipped_subtract(3, 10)
  |> should.equal(7)

  // flip with different operation
  let divide = fn(a, b) { a / b }
  let flipped_divide = func.flip(divide)
  divide(10, 2)
  |> should.equal(5)
  flipped_divide(2, 10)
  |> should.equal(5)

  // apply - should apply function to value
  let double = fn(x) { x * 2 }
  func.apply(5, double)
  |> should.equal(10)

  let to_string = fn(x) { "Value: " <> int.to_string(x) }
  func.apply(42, to_string)
  |> should.equal("Value: 42")
}

pub fn option_test() {
  // map
  option.map(gleam_option.Some(5), fn(x) { x * 2 })
  |> should.equal(gleam_option.Some(10))

  option.map(gleam_option.None, fn(x) { x * 2 })
  |> should.equal(gleam_option.None)

  // and_then
  option.and_then(gleam_option.Some(5), fn(x) { gleam_option.Some(x * 2) })
  |> should.equal(gleam_option.Some(10))

  option.and_then(gleam_option.Some(5), fn(_) { gleam_option.None })
  |> should.equal(gleam_option.None)

  option.and_then(gleam_option.None, fn(x) { gleam_option.Some(x * 2) })
  |> should.equal(gleam_option.None)

  // unwrap_or
  option.unwrap_or(gleam_option.Some(5), 0)
  |> should.equal(5)

  option.unwrap_or(gleam_option.None, 0)
  |> should.equal(0)

  // unwrap_or_else
  option.unwrap_or_else(gleam_option.Some(5), fn() { 0 })
  |> should.equal(5)

  option.unwrap_or_else(gleam_option.None, fn() { 0 })
  |> should.equal(0)

  // tap_some and tap_none
  option.tap_some(gleam_option.Some(5), fn(_) { Nil })
  |> should.equal(gleam_option.Some(5))

  option.tap_some(gleam_option.None, fn(_) { Nil })
  |> should.equal(gleam_option.None)

  option.tap_none(gleam_option.Some(5), fn() { Nil })
  |> should.equal(gleam_option.Some(5))

  option.tap_none(gleam_option.None, fn() { Nil })
  |> should.equal(gleam_option.None)

  // Test tap functions in pipelines
  gleam_option.Some(10)
  |> option.tap_some(fn(_) { Nil })
  |> option.map(fn(x) { x * 2 })
  |> should.equal(gleam_option.Some(20))

  gleam_option.None
  |> option.tap_none(fn() { Nil })
  |> option.unwrap_or(42)
  |> should.equal(42)
}

pub fn option_advanced_test() {
  // filter
  option.filter(gleam_option.Some(5), fn(x) { x > 3 })
  |> should.equal(gleam_option.Some(5))

  option.filter(gleam_option.Some(2), fn(x) { x > 3 })
  |> should.equal(gleam_option.None)

  option.filter(gleam_option.None, fn(x) { x > 3 })
  |> should.equal(gleam_option.None)

  // or
  option.or(gleam_option.Some(5), gleam_option.Some(10))
  |> should.equal(gleam_option.Some(5))

  option.or(gleam_option.None, gleam_option.Some(10))
  |> should.equal(gleam_option.Some(10))

  option.or(gleam_option.Some(5), gleam_option.None)
  |> should.equal(gleam_option.Some(5))

  option.or(gleam_option.None, gleam_option.None)
  |> should.equal(gleam_option.None)

  // or_else
  option.or_else(gleam_option.Some(5), fn() { gleam_option.Some(10) })
  |> should.equal(gleam_option.Some(5))

  option.or_else(gleam_option.None, fn() { gleam_option.Some(10) })
  |> should.equal(gleam_option.Some(10))

  // to_result and from_result
  option.to_result(gleam_option.Some(5), "missing")
  |> should.equal(Ok(5))

  option.to_result(gleam_option.None, "missing")
  |> should.equal(Error("missing"))

  option.from_result(Ok(5))
  |> should.equal(gleam_option.Some(5))

  option.from_result(Error("failed"))
  |> should.equal(gleam_option.None)

  // zip_with and zip
  option.zip_with(gleam_option.Some(5), gleam_option.Some(3), fn(a, b) { a + b })
  |> should.equal(gleam_option.Some(8))

  option.zip_with(gleam_option.Some(5), gleam_option.None, fn(a, b) { a + b })
  |> should.equal(gleam_option.None)

  option.zip(gleam_option.Some(5), gleam_option.Some("hello"))
  |> should.equal(gleam_option.Some(#(5, "hello")))

  option.zip(gleam_option.Some(5), gleam_option.None)
  |> should.equal(gleam_option.None)

  // flatten
  option.flatten(gleam_option.Some(gleam_option.Some(5)))
  |> should.equal(gleam_option.Some(5))

  option.flatten(gleam_option.Some(gleam_option.None))
  |> should.equal(gleam_option.None)

  option.flatten(gleam_option.None)
  |> should.equal(gleam_option.None)

  // when_some (alias for map)
  option.when_some(gleam_option.Some(5), fn(x) { x * 2 })
  |> should.equal(gleam_option.Some(10))

  option.when_some(gleam_option.None, fn(x) { x * 2 })
  |> should.equal(gleam_option.None)

  // when
  option.when(True, 42)
  |> should.equal(gleam_option.Some(42))

  option.when(False, 42)
  |> should.equal(gleam_option.None)
}

pub fn predicate_test() {
  let is_even = fn(x) { x % 2 == 0 }
  let is_positive = fn(x) { x > 0 }

  // not
  predicate.not(is_even)(3)
  |> should.equal(True)

  predicate.not(is_even)(4)
  |> should.equal(False)

  // and
  let is_even_and_positive = predicate.and(is_even, is_positive)
  is_even_and_positive(4)
  |> should.equal(True)

  is_even_and_positive(3)
  |> should.equal(False)

  is_even_and_positive(-2)
  |> should.equal(False)

  // or
  let is_even_or_positive = predicate.or(is_even, is_positive)
  is_even_or_positive(3)
  |> should.equal(True)

  is_even_or_positive(4)
  |> should.equal(True)

  is_even_or_positive(-1)
  |> should.equal(False)
}

pub fn list_test() {
  // flat_map
  list.flat_map([1, 2, 3], fn(x) { [x, x * 2] })
  |> should.equal([1, 2, 2, 4, 3, 6])

  list.flat_map([], fn(x) { [x, x * 2] })
  |> should.equal([])

  // chunk
  list.chunk([1, 2, 3, 4, 5], 2)
  |> should.equal([[1, 2], [3, 4], [5]])

  list.chunk([1, 2, 3], 1)
  |> should.equal([[1], [2], [3]])

  list.chunk([1, 2, 3], 5)
  |> should.equal([[1, 2, 3]])

  list.chunk([], 2)
  |> should.equal([])

  list.chunk([1, 2, 3], 0)
  |> should.equal([])

  // uniq
  list.uniq([1, 2, 2, 3, 1, 4])
  |> should.equal([1, 2, 3, 4])

  list.uniq([])
  |> should.equal([])

  // any
  list.any([1, 2, 3, 4], fn(x) { x == 3 })
  |> should.equal(True)

  list.any([1, 2, 4], fn(x) { x == 3 })
  |> should.equal(False)

  list.any([], fn(x) { x == 3 })
  |> should.equal(False)
  // No elements satisfy the predicate in an empty list

  // all
  list.all([1, 2, 3, 4], fn(x) { x > 0 })
  |> should.equal(True)

  list.all([1, 2, -3, 4], fn(x) { x > 0 })
  |> should.equal(False)

  list.all([], fn(x) { x > 0 })
  |> should.equal(True)
  // All elements satisfy the predicate in an empty list

  // filter
  list.filter([1, 2, 3, 4, 5], fn(x) { x % 2 == 0 })
  |> should.equal([2, 4])

  list.filter([], fn(x) { x % 2 == 0 })
  |> should.equal([])
}

pub fn result_test() {
  // map
  result.map(Ok(5), fn(x) { x * 2 })
  |> should.equal(Ok(10))

  result.map(Error("error"), fn(x) { x * 2 })
  |> should.equal(Error("error"))

  // map_error
  result.map_error(Ok(5), fn(e) { e <> "!" })
  |> should.equal(Ok(5))

  result.map_error(Error("error"), fn(e) { e <> "!" })
  |> should.equal(Error("error!"))

  // and_then
  result.and_then(Ok(5), fn(x) { Ok(x * 2) })
  |> should.equal(Ok(10))

  result.and_then(Ok(5), fn(_) { Error("error") })
  |> should.equal(Error("error"))

  result.and_then(Error("error"), fn(x) { Ok(x * 2) })
  |> should.equal(Error("error"))

  // unwrap_or
  result.unwrap_or(Ok(5), 0)
  |> should.equal(5)

  result.unwrap_or(Error("error"), 0)
  |> should.equal(0)

  // unwrap_or_else
  result.unwrap_or_else(Ok(5), fn(_e) { 0 })
  |> should.equal(5)

  result.unwrap_or_else(Error("error"), fn(_e) { 0 })
  |> should.equal(0)

  // is_ok and is_error
  result.is_ok(Ok(5))
  |> should.equal(True)

  result.is_ok(Error("error"))
  |> should.equal(False)

  result.is_error(Ok(5))
  |> should.equal(False)

  result.is_error(Error("error"))
  |> should.equal(True)

  // tap_ok and tap_error
  result.tap_ok(Ok(5), fn(_) { Nil })
  |> should.equal(Ok(5))

  result.tap_ok(Error("error"), fn(_) { Nil })
  |> should.equal(Error("error"))

  result.tap_error(Ok(5), fn(_) { Nil })
  |> should.equal(Ok(5))

  result.tap_error(Error("error"), fn(_) { Nil })
  |> should.equal(Error("error"))

  // Test tap functions in pipelines
  Ok(10)
  |> result.tap_ok(fn(_) { Nil })
  |> result.map(fn(x) { x * 2 })
  |> should.equal(Ok(20))

  Error("failed")
  |> result.tap_error(fn(_) { Nil })
  |> result.map_error(fn(e) { e <> "!" })
  |> should.equal(Error("failed!"))
}
