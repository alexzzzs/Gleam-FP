import gleam/list

/// Maps a function over a list and flattens the result.
/// Also known as `bind` or `>>=` in other functional languages.
///
/// ## Examples
///
/// ```gleam
/// flat_map([1, 2, 3], fn(x) { [x, x * 2] })
/// // Result: [1, 2, 2, 4, 3, 6]
///
/// flat_map([], fn(x) { [x, x * 2] })
/// // Result: []
/// ```
pub fn flat_map(xs: List(a), f: fn(a) -> List(b)) -> List(b) {
  list.flat_map(xs, f)
}

/// Splits a list into chunks of the specified size.
/// Returns empty list for invalid sizes (≤ 0) to maintain ergonomics.
/// The last chunk may be smaller than the specified size.
///
/// ## Examples
///
/// ```gleam
/// chunk([1, 2, 3, 4, 5], 2) // [[1, 2], [3, 4], [5]]
/// chunk([1, 2, 3], 1) // [[1], [2], [3]]
/// chunk([1, 2, 3], 5) // [[1, 2, 3]]
/// chunk([], 2) // []
/// chunk([1, 2, 3], 0) // [] (gracefully handles invalid size)
/// ```
pub fn chunk(xs: List(a), size: Int) -> List(List(a)) {
  case size {
    _ if size <= 0 -> []
    _ -> chunk_helper(xs, size)
  }
}

fn chunk_helper(xs: List(a), size: Int) -> List(List(a)) {
  case xs {
    [] -> []
    _ -> {
      let #(head, tail) = list.split(xs, size)
      [head, ..chunk_helper(tail, size)]
    }
  }
}

/// Removes duplicate elements from a list, keeping the first occurrence.
///
/// ## Examples
///
/// ```gleam
/// uniq([1, 2, 2, 3, 1, 4]) // [1, 2, 3, 4]
/// uniq([]) // []
/// uniq(["a", "b", "a"]) // ["a", "b"]
/// ```
pub fn uniq(xs: List(a)) -> List(a) {
  list.unique(xs)
}

/// Returns True if any element in the list satisfies the predicate.
/// Returns False for empty lists.
///
/// ## Examples
///
/// ```gleam
/// any([1, 2, 3, 4], fn(x) { x == 3 }) // True
/// any([1, 2, 4], fn(x) { x == 3 }) // False
/// any([], fn(x) { x == 3 }) // False
/// ```
pub fn any(xs: List(a), f: fn(a) -> Bool) -> Bool {
  list.any(xs, f)
}

/// Returns True if all elements in the list satisfy the predicate.
/// Returns True for empty lists (vacuous truth).
///
/// ## Examples
///
/// ```gleam
/// all([1, 2, 3, 4], fn(x) { x > 0 }) // True
/// all([1, 2, -3, 4], fn(x) { x > 0 }) // False
/// all([], fn(x) { x > 0 }) // True
/// ```
pub fn all(xs: List(a), f: fn(a) -> Bool) -> Bool {
  list.all(xs, f)
}

/// Keeps only elements that satisfy the predicate.
///
/// ## Examples
///
/// ```gleam
/// filter([1, 2, 3, 4, 5], fn(x) { x % 2 == 0 }) // [2, 4]
/// filter([], fn(x) { x % 2 == 0 }) // []
/// filter(["apple", "banana", "cherry"], fn(s) { string.length(s) > 5 })
/// // ["banana", "cherry"]
/// ```
pub fn filter(xs: List(a), f: fn(a) -> Bool) -> List(a) {
  list.filter(xs, f)
}
