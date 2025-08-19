# JSON Helpers for fp_utils

This document describes how JSON helpers could be added to the fp_utils library to work seamlessly with the existing functional programming patterns.

## Core Idea

Treat JSON values as a "data pipeline source," just like you do with sequences and strings. Use Result everywhere (so invalid JSON doesn't crash pipelines) and provide small combinators that compose naturally.

## Example API

```gleam
import gleam/json
import gleam/dynamic/decode.{Decoder}
import fp/result
import fp/option

// Basic JSON operations using gleam_json package
pub fn decode(s: String) -> Result(json.Json, json.DecodeError) {
  json.parse(from: s, using: decode.anything)
}

pub fn encode(j: json.Json) -> String {
  json.to_string(j)
}

// Field accessors
pub fn get(obj: json.Json, key: String) -> Result(json.Json, String) {
  case obj {
    json.object(fields) ->
      case dict.get(fields, key) {
        Ok(value) -> Ok(value)
        Error(_) -> Error("Missing field: " <> key)
      }
    _ -> Error("Not a JSON object")
  }
}

// Type-specific getters using dynamic decoders
pub fn get_string(obj: json.Json, key: String) -> Result(String, dynamic.DecodeError) {
  get(obj, key)
  |> result.then(fn(value) { decode.decode(value, decode.string) })
}

pub fn get_int(obj: json.Json, key: String) -> Result(Int, dynamic.DecodeError) {
  get(obj, key)
  |> result.then(fn(value) { decode.decode(value, decode.int) })
}

pub fn get_bool(obj: json.Json, key: String) -> Result(Bool, dynamic.DecodeError) {
  get(obj, key)
  |> result.then(fn(value) { decode.decode(value, decode.bool) })
}

// Optional field access
pub fn opt(obj: json.Json, key: String, decoder: Decoder(a)) -> Result(Option(a), dynamic.DecodeError) {
  case get(obj, key) {
    Ok(value) -> decode.decode(value, decoder) |> result.map(option.Some)
    Error(_) -> Ok(option.None)
  }
}

// Array field access
pub fn list(obj: json.Json, key: String, decoder: Decoder(a)) -> Result(List(a), dynamic.DecodeError) {
  get(obj, key)
  |> result.then(fn(value) { decode.decode(value, decode.list(decoder)) })
}
```

## Usage Examples

```gleam
import fp/result
import fp/func
import gleam/dynamic/decode.{string, int, list}

// Simple field access
decode("{\"name\": \"alex\", \"age\": 20}")
|> result.then(fn(obj) { get_string(obj, "name") })
|> result.map(string.uppercase)

// Complex object decoding with proper error handling
decode(user_json)
|> result.then(fn(obj) {
  result.map2(
    get_string(obj, "name"),
    get_int(obj, "age"),
    fn(name, age) { #(name, age) }
  )
})

// Optional fields
decode(user_json)
|> result.then(fn(obj) {
  opt(obj, "email", string)
  |> result.map(fn(maybe_email) {
    case maybe_email {
      Some(email) -> "Email: " <> email
      None -> "No email provided"
    }
  })
})

// Array processing with decoders
decode("{\"items\": [1, 2, 3, 4, 5]}")
|> result.then(fn(obj) { list(obj, "items", int) })
|> result.map(list.filter(fn(x) { x > 3 }))
```

## Extended Combinators

- `get_string(obj, "key")` → `Result(String, dynamic.DecodeError)`
- `get_int(obj, "key")` → `Result(Int, dynamic.DecodeError)`
- `opt(obj, "maybe_field", decoder)` → optional field with decoder
- `list(obj, "items", decoder)` → list field with decoder
- `pipe(obj, [ get("a", int), get("b", string) ])` → multi-field extractor

## Benefits

1. **Pipeline-friendly**: Works seamlessly with existing fp_utils patterns
2. **Error handling**: Uses Result throughout to prevent crashes
3. **Composable**: Small functions that compose naturally
4. **Type-safe**: Proper typing for all JSON operations
5. **Ergonomic**: Easy to use with the `|>` operator
6. **Integration**: Leverages the powerful gleam_json package with dynamic decoders

## Implementation Notes

To use this functionality, you would need to add the gleam_json dependency:

```sh
gleam add gleam_json@3
```

The implementation would integrate with the existing fp_utils patterns while leveraging the robust decoding capabilities of gleam_json.