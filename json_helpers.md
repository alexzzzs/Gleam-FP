# JSON Helpers for fp_utils

This document describes how JSON helpers could be added to the fp_utils library to work seamlessly with the existing functional programming patterns, leveraging the official gleam_json package.

## Core Idea

Treat JSON values as a "data pipeline source," just like you do with sequences and strings. Use Result everywhere (so invalid JSON doesn't crash pipelines) and provide small combinators that compose naturally with your existing fp_utils functions.

## Correct API Implementation

Based on the gleam_json package (version 3.x), here's how the JSON module should be implemented:

```gleam
import gleam/json
import gleam/dynamic/decode.{Decoder}
import gleam/dynamic
import gleam/result
import gleam/option.{Option}

// Type alias for JSON decode errors
pub type DecodeError = json.DecodeError

// Basic JSON operations
pub fn decode(str: String) -> Result(dynamic.Dynamic, DecodeError) {
  json.parse(from: str, using: dynamic.decode)
}

pub fn encode(j: json.Json) -> String {
  json.to_string(j)
}

pub fn to_string_tree(j: json.Json) -> StringTree {
  json.to_string_tree(j)
}

// Field accessors using dynamic decoders
pub fn get_field(
  dyn: dynamic.Dynamic,
  key: String,
  decoder_fn: Decoder(a)
) -> Result(a, DecodeError) {
  dynamic.decode(dyn, dynamic.field(key, decoder_fn))
}

pub fn get_string(dyn: dynamic.Dynamic, key: String) -> Result(String, DecodeError) {
  get_field(dyn, key, dynamic.string)
}

pub fn get_int(dyn: dynamic.Dynamic, key: String) -> Result(Int, DecodeError) {
  get_field(dyn, key, dynamic.int)
}

pub fn get_bool(dyn: dynamic.Dynamic, key: String) -> Result(Bool, DecodeError) {
  get_field(dyn, key, dynamic.bool)
}

// Optional field access
pub fn opt(
  dyn: dynamic.Dynamic,
  key: String,
  decoder_fn: Decoder(a)
) -> Result(Option(a), DecodeError) {
  dynamic.decode(dyn, dynamic.optional(dynamic.field(key, decoder_fn)))
}

// Array field access
pub fn list(
  dyn: dynamic.Dynamic,
  key: String,
  decoder_fn: Decoder(a)
) -> Result(List(a), DecodeError) {
  get_field(dyn, key, dynamic.list(decoder_fn))
}
```

## Usage Examples

```gleam
import fp/result
import fp/func

// Simple field access
decode("{\"name\": \"alex\", \"age\": 20}")
|> result.then(fn(dyn) { get_string(dyn, "name") })
|> result.map(string.uppercase)

// Complex object decoding with proper error handling
decode(user_json)
|> result.then(fn(dyn) {
  result.map2(
    get_string(dyn, "name"),
    get_int(dyn, "age"),
    fn(name, age) { #(name, age) }
  )
})

// Optional fields
decode(user_json)
|> result.then(fn(dyn) {
  opt(dyn, "email", dynamic.string)
  |> result.map(fn(maybe_email) {
    case maybe_email {
      Some(email) -> "Email: " <> email
      None -> "No email provided"
    }
  })
})

// Array processing with decoders
decode("{\"items\": [1, 2, 3, 4, 5]}")
|> result.then(fn(dyn) { list(dyn, "items", dynamic.int) })
|> result.map(list.filter(fn(x) { x > 3 }))
```

## Integration with fp_utils

The JSON helpers integrate seamlessly with existing fp_utils patterns:

```gleam
import fp/result
import fp/option

// Chain JSON operations with your existing helpers
decode(json_string)
|> result.then(fn(dyn) { get_string(dyn, "name") })
|> result.map(string.uppercase)
|> result.map(fn(name) { "Hello, " <> name <> "!" })

// Use with option helpers
decode(json_string)
|> result.then(fn(dyn) { opt(dyn, "email", dynamic.string) })
|> result.map(option.map(fn(email) { "Email: " <> email }))
```

## Extended Combinators

- `get_string(dyn, "key")` → `Result(String, DecodeError)`
- `get_int(dyn, "key")` → `Result(Int, DecodeError)`
- `opt(dyn, "maybe_field", decoder)` → optional field with decoder
- `list(dyn, "items", decoder)` → list field with decoder
- `get_field(dyn, "field", decoder)` → generic field accessor

## Benefits

1. **Pipeline-friendly**: Works seamlessly with existing fp_utils patterns using `|>` and `result.then`
2. **Error handling**: Uses Result throughout to prevent crashes with proper error propagation
3. **Composable**: Small functions that compose naturally with your existing helpers
4. **Type-safe**: Proper typing for all JSON operations with compile-time guarantees
5. **Ergonomic**: Easy to use with familiar fp_utils patterns
6. **Integration**: Leverages the battle-tested gleam_json package with dynamic decoders
7. **Performance**: Supports `to_string_tree` for better BEAM I/O performance

## Implementation Notes

To use this functionality, you would need to add the gleam_json dependency:

```sh
gleam add gleam_json@3
```

The implementation would integrate with the existing fp_utils patterns while leveraging the robust decoding capabilities of gleam_json, providing a consistent API that feels like a natural extension of your existing library.