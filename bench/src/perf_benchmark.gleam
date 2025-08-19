import fp/func
import fp/list
import fp/option
import gleam/list as std_list
import gleam/option as std_option
import gleam/io
import gleam/int

// External function to get current time in native units from Erlang
@external(erlang, "erlang", "monotonic_time")
fn erlang_monotonic_time() -> Int

// External function to convert time units in Erlang
// Using Int parameters for time units (1 = seconds, 1000 = milliseconds, etc.)
@external(erlang, "erlang", "convert_time_unit")
fn erlang_convert_time_unit(time: Int, from: Int, to: Int) -> Int

/// Get current time in milliseconds
/// Using integer time units: 1000000000 = native (approx), 1000 = millisecond
fn current_time_ms() -> Int {
  let time = erlang_monotonic_time()
  // Convert from native time unit to milliseconds
  // This is a simplified approach - the actual native time unit varies by system
  erlang_convert_time_unit(time, 1000000000, 1000)
}

/// A simple benchmarking function that runs a function a fixed number of times
/// and returns the time taken in milliseconds
pub fn benchmark(f: fn() -> a, iterations: Int) -> Int {
  let start_time = current_time_ms()
  run_iterations(f, iterations)
  let end_time = current_time_ms()
  end_time - start_time
}

/// A simple function that runs a function a fixed number of times
fn run_iterations(f: fn() -> a, iterations: Int) {
  case iterations {
    0 -> Nil
    _ -> {
      let _ = f()
      run_iterations(f, iterations - 1)
    }
  }
}

/// Benchmark for func.pipe vs regular function composition
pub fn pipe_vs_compose_benchmark() {
  let add_one = fn(x) { x + 1 }
  let multiply_by_two = fn(x) { x * 2 }
  let subtract_three = fn(x) { x - 3 }
  
  // Using pipe
  io.println("Running pipe benchmark...")
  let pipe_time = benchmark(fn() {
    100
    |> func.pipe([add_one, multiply_by_two, subtract_three])
  }, 100000)
  
  // Using compose
  let composed_func = func.compose(subtract_three, func.compose(multiply_by_two, add_one))
  io.println("Running compose benchmark...")
  let compose_time = benchmark(fn() {
    composed_func(100)
  }, 100000)
  
  io.println("pipe vs compose benchmark results:")
  io.println("  pipe: " <> int.to_string(pipe_time) <> " ms")
  io.println("  compose: " <> int.to_string(compose_time) <> " ms")
  io.println("")
}

/// Benchmark for option.map vs stdlib option.map
pub fn option_map_benchmark() {
  let some_value = std_option.Some(42)
  let none_value = std_option.None
  
  // Our option.map
  io.println("Running our option.map (Some) benchmark...")
  let our_map_some_time = benchmark(fn() {
    option.map(some_value, fn(x) { x * 2 })
  }, 100000)
  
  io.println("Running our option.map (None) benchmark...")
  let our_map_none_time = benchmark(fn() {
    option.map(none_value, fn(x) { x * 2 })
  }, 100000)
  
  // Standard library option.map
  io.println("Running std option.map (Some) benchmark...")
  let std_map_some_time = benchmark(fn() {
    std_option.map(some_value, fn(x) { x * 2 })
  }, 100000)
  
  io.println("Running std option.map (None) benchmark...")
  let std_map_none_time = benchmark(fn() {
    std_option.map(none_value, fn(x) { x * 2 })
  }, 100000)
  
  io.println("option.map benchmark results:")
  io.println("  Our map (Some): " <> int.to_string(our_map_some_time) <> " ms")
  io.println("  Our map (None): " <> int.to_string(our_map_none_time) <> " ms")
  io.println("  Std map (Some): " <> int.to_string(std_map_some_time) <> " ms")
  io.println("  Std map (None): " <> int.to_string(std_map_none_time) <> " ms")
  io.println("")
}

/// Benchmark for list operations
pub fn list_operations_benchmark() {
  let test_list = std_list.range(0, 100)
  
  // Our flat_map vs stdlib flatten + map
  io.println("Running our flat_map benchmark...")
  let our_flat_map_time = benchmark(fn() {
    list.flat_map(test_list, fn(x) { [x, x * 2] })
  }, 10000)
  
  io.println("Running std flatten+map benchmark...")
  let std_flat_map_time = benchmark(fn() {
    std_list.map(test_list, fn(x) { [x, x * 2] })
    |> std_list.flatten
  }, 10000)
  
  // Our uniq
  let list_with_dups = std_list.range(0, 50) 
    |> std_list.map(fn(x) { x % 10 }) // Creates duplicates
  
  io.println("Running our uniq benchmark...")
  let our_uniq_time = benchmark(fn() {
    list.uniq(list_with_dups)
  }, 10000)
  
  io.println("list operations benchmark results:")
  io.println("  Our flat_map: " <> int.to_string(our_flat_map_time) <> " ms")
  io.println("  Std flatten+map: " <> int.to_string(std_flat_map_time) <> " ms")
  io.println("  Our uniq: " <> int.to_string(our_uniq_time) <> " ms")
  io.println("")
}

pub fn main() {
  io.println("Running performance benchmarks...")
  io.println("")
  
  pipe_vs_compose_benchmark()
  option_map_benchmark()
  list_operations_benchmark()
  
  io.println("Benchmarks completed!")
}