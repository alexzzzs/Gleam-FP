# JSON Helpers for fp_utils

This document describes how JSON helpers could be added to the fp_utils library to work seamlessly with the existing functional programming patterns.

## Core Idea

Treat JSON values as a "data pipeline source," just like you do with sequences and strings. Use Result everywhere (so invalid JSON doesn't crash pipelines) and provide small combinators that compose naturally.

## Example API

```gleam
import gleam/json
import fp/result
import fp/option

// Basic JSON operations
pub fn decode(s: String) -> Result(json.Json, String) {
  json.decode(s)
}

pub fn encode(j: json.Json) -> String {
  json.encode(j)
}

// Field accessors
pub fn get(obj: json.Json, key: String) -> Result(json.Json, String) {
  case obj {
    json.Object(fields) ->
      case dict.get(fields, key) {
        Ok(value) -> Ok(value)
        Error(_) -> Error("Missing field: " <> key)
      }
    _ -> Error("Not a JSON object")
  }
}

// Type-specific getters
pub fn get_string(obj: json.Json, key: String) -> Result(String, String) {
  get(obj, key)
  |> result.and_then(string_)
}

pub fn get_int(obj: json.Json, key: String) -> Result(Int, String) {
  get(obj, key)
  |> result.and_then(int_)
}

pub fn get_bool(obj: json.Json, key: String) -> Result(Bool, String) {
  get(obj, key)
  |> result.and_then(bool_)
}

// Type extractors
pub fn string_(j: json.Json) -> Result(String, String) {
  case j {
    json.String(s) -> Ok(s)
    _ -> Error("Not a JSON string")
  }
}

pub fn int_(j: json.Json) -> Result(Int, String) {
  case j {
    json.Number(n) -> Ok(float.to_int(n))
    _ -> Error("Not a JSON number")
  }
}

pub fn bool_(j: json.Json) -> Result(Bool, String) {
  case j {
    json.Bool(b) -> Ok(b)
    _ -> Error("Not a JSON boolean")
  }
}

// Advanced combinators
pub fn opt(obj: json.Json, key: String, decoder: fn(json.Json) -> Result(a, String)) -> Result(Option(a), String) {
  case get(obj, key) {
    Ok(value) -> decoder(value) |> result.map(option.Some)
    Error(_) -> Ok(option.None)
  }
}

pub fn list(obj: json.Json, key: String, decoder: fn(json.Json) -> Result(a, String)) -> Result(List(a), String) {
  get(obj, key)
  |> result.and_then(fn(j) {
    case j {
      json.Array(items) -> 
        // Decode each item and collect results
        items
        |> list.fold(fn(acc, item) {
          case acc {
            Error(e) -> Error(e)
            Ok(decoded_items) -> 
              case decoder(item) {
                Ok(decoded_item) -> Ok(decoded_items ++ [decoded_item])
                Error(e) -> Error(e)
              }
          }
        }, Ok([]))
      _ -> Error("Field is not a JSON array")
    }
  })
}
```

## Usage Examples

```gleam
import fp/result
import fp/func

// Simple field access
decode("{\"name\": \"alex\", \"age\": 20}")
|> result.and_then(fn(obj) { get_string(obj, "name") })
|> result.map(string.uppercase)

// Complex object decoding
decode(user_json)
|> result.and_then(fn(obj) {
  result.map2(
    get_string(obj, "name"),
    get_int(obj, "age"),
    fn(name, age) { #(name, age) }
  )
})

// Optional fields
decode(user_json)
|> result.and_then(fn(obj) {
  opt(obj, "email", string_)
  |> result.map(fn(maybe_email) {
    case maybe_email {
      Some(email) -> "Email: " <> email
      None -> "No email provided"
    }
  })
})

// Array processing
decode("{\"items\": [1, 2, 3, 4, 5]}")
|> result.and_then(fn(obj) { list(obj, "items", int_) })
|> result.map(list.filter(fn(x) { x > 3 }))
```

## Extended Combinators

- `get_string(obj, "key")` → `Result(String, String)`
- `get_int(obj, "key")` → `Result(Int, String)`
- `opt(obj, "maybe_field", decoder)` → optional field
- `list(obj, "items", decoder)` → list field with decoding
- `pipe(obj, [ get("a", int_), get("b", string_) ])` → multi-field extractor

## Benefits

1. **Pipeline-friendly**: Works seamlessly with existing fp_utils patterns
2. **Error handling**: Uses Result throughout to prevent crashes
3. **Composable**: Small functions that compose naturally
4. **Type-safe**: Proper typing for all JSON operations
5. **Ergonomic**: Easy to use with the `|>` operator