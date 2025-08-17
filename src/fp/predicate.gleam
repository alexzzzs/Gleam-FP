/// Negates a predicate function.
///
/// ## Examples
///
/// ```gleam
/// let is_even = fn(x) { x % 2 == 0 }
/// let is_odd = not(is_even)
/// is_odd(3) // True
/// is_odd(4) // False
/// ```
pub fn not(p: fn(a) -> Bool) -> fn(a) -> Bool {
  fn(x) {
    case p(x) {
      True -> False
      False -> True
    }
  }
}

/// Combines two predicates with logical AND.
/// Returns True only if both predicates return True.
///
/// ## Examples
///
/// ```gleam
/// let is_even = fn(x) { x % 2 == 0 }
/// let is_positive = fn(x) { x > 0 }
/// let is_even_and_positive = and(is_even, is_positive)
/// is_even_and_positive(4) // True
/// is_even_and_positive(3) // False
/// is_even_and_positive(-2) // False
/// ```
pub fn and(p1: fn(a) -> Bool, p2: fn(a) -> Bool) -> fn(a) -> Bool {
  fn(x) { p1(x) && p2(x) }
}

/// Combines two predicates with logical OR.
/// Returns True if either predicate returns True.
///
/// ## Examples
///
/// ```gleam
/// let is_even = fn(x) { x % 2 == 0 }
/// let is_positive = fn(x) { x > 0 }
/// let is_even_or_positive = or(is_even, is_positive)
/// is_even_or_positive(3) // True (positive)
/// is_even_or_positive(4) // True (both)
/// is_even_or_positive(-1) // False (neither)
/// ```
pub fn or(p1: fn(a) -> Bool, p2: fn(a) -> Bool) -> fn(a) -> Bool {
  fn(x) { p1(x) || p2(x) }
}
