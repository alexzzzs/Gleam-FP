import gleam/list

/// Composes two functions, applying g first, then f.
/// This is mathematical function composition: (f ∘ g)(x) = f(g(x))
///
/// ## Examples
///
/// ```gleam
/// let add_one = fn(x) { x + 1 }
/// let double = fn(x) { x * 2 }
/// let add_then_double = compose(double, add_one)
/// add_then_double(5) // 12 ((5 + 1) * 2)
/// ```
pub fn compose(f: fn(b) -> c, g: fn(a) -> b) -> fn(a) -> c {
  fn(x) { f(g(x)) }
}

/// Applies a list of functions sequentially to a value.
/// All functions must have the same input/output type for type safety.
///
/// ## Examples
///
/// ```gleam
/// let add_one = fn(x) { x + 1 }
/// let double = fn(x) { x * 2 }
/// let subtract_three = fn(x) { x - 3 }
///
/// 5
/// |> pipe([add_one, double, subtract_three])
/// // Result: 9 (((5 + 1) * 2) - 3)
/// ```
pub fn pipe(a: a, fs: List(fn(a) -> a)) -> a {
  list.fold(fs, a, fn(acc, f) { f(acc) })
}

/// Applies two functions sequentially with different types.
/// More flexible than pipe for simple two-step transformations.
///
/// ## Examples
///
/// ```gleam
/// 5
/// |> pipe2(fn(x) { x + 1 }, fn(x) { int.to_string(x) })
/// // Result: "6"
/// ```
pub fn pipe2(a: a, f1: fn(a) -> b, f2: fn(b) -> c) -> c {
  f2(f1(a))
}

/// Applies three functions sequentially with different types.
///
/// ## Examples
///
/// ```gleam
/// 5
/// |> pipe3(
///   fn(x) { x + 1 },
///   fn(x) { x * 2 },
///   fn(x) { int.to_string(x) }
/// )
/// // Result: "12"
/// ```
pub fn pipe3(a: a, f1: fn(a) -> b, f2: fn(b) -> c, f3: fn(c) -> d) -> d {
  f3(f2(f1(a)))
}

/// Applies four functions sequentially with different types.
pub fn pipe4(
  a: a,
  f1: fn(a) -> b,
  f2: fn(b) -> c,
  f3: fn(c) -> d,
  f4: fn(d) -> e,
) -> e {
  f4(f3(f2(f1(a))))
}

/// Converts a two-argument function into a curried function.
///
/// ## Examples
///
/// ```gleam
/// let add = fn(a, b) { a + b }
/// let curried_add = curry(add)
/// let add_five = curried_add(5)
/// add_five(10) // 15
/// ```
pub fn curry(f: fn(a, b) -> c) -> fn(a) -> fn(b) -> c {
  fn(a_val) { fn(b_val) { f(a_val, b_val) } }
}

/// Converts a curried function back into a two-argument function.
///
/// ## Examples
///
/// ```gleam
/// let curried_add = fn(a) { fn(b) { a + b } }
/// let add = uncurry(curried_add)
/// add(5, 10) // 15
/// ```
pub fn uncurry(f: fn(a) -> fn(b) -> c) -> fn(a, b) -> c {
  fn(a_val, b_val) { f(a_val)(b_val) }
}

/// The identity function - returns its input unchanged.
/// Useful as a default or placeholder function.
///
/// ## Examples
///
/// ```gleam
/// identity(42) // 42
/// identity("hello") // "hello"
/// [1, 2, 3] |> list.map(identity) // [1, 2, 3]
/// ```
pub fn identity(x: a) -> a {
  x
}

/// Creates a constant function that always returns the same value.
///
/// ## Examples
///
/// ```gleam
/// let get_five = constant(5)
/// get_five(1) // 5
/// get_five("anything") // 5
/// ```
pub fn constant(x: a) -> fn(_) -> a {
  fn(_) { x }
}

/// Applies a function to a value and returns the original value.
/// Useful for side effects in a pipeline without changing the value.
///
/// ## Examples
///
/// ```gleam
/// import gleam/io
///
/// 42
/// |> tap(fn(x) { io.println("Debug: " <> int.to_string(x)) })
/// |> fn(x) { x * 2 }
/// // Prints "Debug: 42" and returns 84
/// ```
pub fn tap(x: a, f: fn(a) -> _) -> a {
  f(x)
  x
}

/// Flips the order of arguments for a two-argument function.
///
/// ## Examples
///
/// ```gleam
/// let subtract = fn(a, b) { a - b }
/// let flipped_subtract = flip(subtract)
/// subtract(10, 3) // 7
/// flipped_subtract(3, 10) // 7 (same as subtract(10, 3))
/// ```
pub fn flip(f: fn(a, b) -> c) -> fn(b, a) -> c {
  fn(b, a) { f(a, b) }
}

/// Applies a function to a value. Useful for point-free style.
///
/// ## Examples
///
/// ```gleam
/// let double = fn(x) { x * 2 }
/// apply(5, double) // 10
///
/// // Useful in higher-order contexts:
/// [1, 2, 3] |> list.map(apply(_, double)) // [2, 4, 6]
/// ```
pub fn apply(x: a, f: fn(a) -> b) -> b {
  f(x)
}
