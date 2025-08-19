# Performance Characteristics

This document provides performance benchmarks and characteristics for the functions and helpers in the fp_utils library. All benchmarks were run using Erlang as the target runtime.

## How to Run Benchmarks

To run the performance benchmarks, execute the following command from the project root directory:

```bash
cd bench && gleam run --target erlang --module perf_benchmark
```

This will run all benchmarks and display the timing results for each function comparison.

## Benchmark Results

The following benchmarks compare the performance of fp_utils functions against standard library equivalents and alternative implementations.

### Function Composition

- `func.pipe` vs `func.compose`: Both implementations show similar performance characteristics, with differences typically within measurement noise. The choice between them should be based on code readability rather than performance.

### Option Operations

- `option.map` vs `gleam/option.map`: The fp_utils implementation shows comparable performance to the standard library version for both `Some` and `None` cases.

### List Operations

- `list.flat_map` vs `gleam/list.map |> gleam/list.flatten`: The fp_utils `flat_map` implementation is slightly more efficient as it avoids creating intermediate lists.
- `list.uniq`: Performance scales linearly with input size and is optimized for typical use cases.

## Performance Notes

1. **Micro-optimizations**: Most performance differences between fp_utils functions and standard library equivalents are minimal. The primary benefit of fp_utils is API consistency and functional programming patterns rather than raw performance.

2. **Memory Usage**: Functions in fp_utils follow functional programming principles and may create intermediate data structures. For performance-critical code paths, consider the memory allocation patterns of each function.

3. **Iteration Performance**: Functions that operate on lists or collections have performance characteristics that scale with input size. For large datasets, consider lazy evaluation patterns or streaming approaches.

## Optimization Tips

1. **Use appropriate functions**: Choose functions based on your use case rather than performance assumptions. The library is designed to be efficient across all operations.

2. **Batch operations**: When possible, combine multiple operations to reduce intermediate data structure creation.

3. **Consider alternatives**: For performance-critical sections, benchmark specific use cases to determine the most efficient approach.

## Benchmark Methodology

Benchmarks measure the time taken to execute a function a fixed number of times. Results are reported in milliseconds and represent the total execution time for all iterations. The benchmarks use Erlang's monotonic time functions for accurate timing measurements.

Note that benchmark results may vary between systems and runs. Focus on relative performance differences rather than absolute timing values.