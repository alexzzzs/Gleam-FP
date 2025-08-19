import gleeunit
import gleeunit/should
import fp/func
import fp/list
import fp/option
import fp/result
import fp/predicate
import gleam/option as gleam_option

pub fn main() -> Nil {
  gleeunit.main()
}

// Basic functionality tests
pub fn compose_test() {
  let add_one = fn(x) { x + 1 }
  let multiply_by_two = fn(x) { x * 2 }
  let add_then_multiply = func.compose(multiply_by_two, add_one)
  add_then_multiply(5)
  |> should.equal(12)  // (5 + 1) * 2 = 12
}

pub fn pipe_test() {
  let add_one = fn(x) { x + 1 }
  let multiply_by_two = fn(x) { x * 2 }
  let subtract_three = fn(x) { x - 3 }

  5
  |> func.pipe([add_one, multiply_by_two, subtract_three])
  |> should.equal(9)  // (5 + 1) * 2 - 3 = 9
}

pub fn option_map_test() {
  option.map(gleam_option.Some(5), fn(x) { x * 2 })
  |> should.equal(gleam_option.Some(10))

  option.map(gleam_option.None, fn(x) { x * 2 })
  |> should.equal(gleam_option.None)
}

pub fn list_filter_test() {
  [1, 2, 3, 4, 5]
  |> list.filter(fn(x) { x % 2 == 0 })
  |> should.equal([2, 4])
}

pub fn result_map_test() {
  result.map(Ok(5), fn(x) { x * 2 })
  |> should.equal(Ok(10))

  result.map(Error("error"), fn(x) { x * 2 })
  |> should.equal(Error("error"))
}

pub fn predicate_and_test() {
  let is_even = fn(x) { x % 2 == 0 }
  let is_positive = fn(x) { x > 0 }
  let is_even_and_positive = predicate.and(is_even, is_positive)
  
  is_even_and_positive(4)
  |> should.equal(True)
  
  is_even_and_positive(3)
  |> should.equal(False)
  
  is_even_and_positive(-2)
  |> should.equal(False)
}