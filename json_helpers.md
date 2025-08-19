# JSON Helpers for fp_utils

This document describes how JSON helpers could be added to the fp_utils library to work seamlessly with the existing functional programming patterns, leveraging the official gleam_json package.

## Core Idea

Treat JSON values as a "data pipeline source," just like you do with sequences and strings. Use Result everywhere (so invalid JSON doesn't crash pipelines) and provide small combinators that compose naturally with your existing fp_utils functions.

## Complete API Implementation

Based on the gleam_json package (version 3.x), here's how the JSON module should be implemented:

### Basic Encoding Functions

```gleam
import gleam/json
import gleam/dynamic/decode.{Decoder}
import gleam/string_tree.{StringTree}

// Type alias for JSON decode errors
pub type DecodeError = json.DecodeError

// Basic JSON operations
pub fn decode(from: String, using: Decoder(a)) -> Result(a, DecodeError) {
  json.parse(from: from, using: using)
}

pub fn encode(j: json.Json) -> String {
  json.to_string(j)
}

pub fn to_string_tree(j: json.Json) -> StringTree {
  json.to_string_tree(j)
}

// JSON value constructors
pub fn object(entries: List(#(String, json.Json))) -> json.Json {
  json.object(entries)
}

pub fn array(values: List(json.Json)) -> json.Json {
  json.array(values)
}

pub fn string(input: String) -> json.Json {
  json.string(input)
}

pub fn int(input: Int) -> json.Json {
  json.int(input)
}

pub fn float(input: Float) -> json.Json {
  json.float(input)
}

pub fn bool(input: Bool) -> json.Json {
  json.bool(input)
}

pub fn null() -> json.Json {
  json.null()
}

pub fn nullable(value: Option(a), of: fn(a) -> json.Json) -> json.Json {
  json.nullable(value, of: of)
}
```

### Dynamic Decoding Functions

```gleam
import gleam/dynamic
import gleam/dynamic/decode.{Decoder}
import gleam/option.{Option}

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

## Complete Usage Examples

### Basic Encoding

```gleam
import fp/json

// Create and encode a simple object
let user_json = json.object([
  #("name", json.string("Alex")),
  #("age", json.int(30)),
  #("active", json.bool(True)),
])
let json_string = json.encode(user_json)
// Returns: "{\"name\":\"Alex\",\"age\":30,\"active\":true}"

// Create and encode an array
let numbers_json = json.array([
  json.int(1),
  json.int(2),
  json.int(3),
])
let array_string = json.encode(numbers_json)
// Returns: "[1,2,3]"

// Use to_string_tree for better BEAM I/O performance
let string_tree = json.to_string_tree(user_json)
let optimized_string = string_tree.to_string(string_tree)
```

### Basic Decoding

```gleam
import fp/json
import gleam/dynamic/decode.{string, int, bool}

// Decode a simple string
case json.decode("\"Hello World\"", string) {
  Ok(value) -> value // "Hello World"
  Error(e) -> panic("Failed to decode string")
}

// Decode a complex object
let user_decoder = {
  use name <- decode.field("name", decode.string)
  use age <- decode.field("age", decode.int)
  use active <- decode.field("active", decode.bool)
  decode.success(#(name, age, active))
}

case json.decode("{\"name\":\"Alex\",\"age\":30,\"active\":true}", user_decoder) {
  Ok(#(name, age, active)) -> // Process the decoded values
  Error(e) -> panic("Failed to decode user")
}
```

### Advanced Pipeline Usage

```gleam
import fp/json
import fp/result
import fp/option
import fp/func
import gleam/dynamic/decode.{string, int, list}

// Simple field access with pipeline
json.decode("{\"name\": \"alex\", \"age\": 20}", decode.anything)
|> result.then(fn(dyn) { json.get_string(dyn, "name") })
|> result.map(string.uppercase)

// Complex object decoding with proper error handling
let user_decoder = {
  use name <- decode.field("name", decode.string)
  use age <- decode.field("age", decode.int)
  decode.success(#(name, age))
}

json.decode(user_json, user_decoder)
|> result.map(fn(#(name, age)) { 
  #(string.uppercase(name), age + 1) 
})

// Optional fields with fp_utils integration
json.decode(user_json, decode.anything)
|> result.then(fn(dyn) { 
  json.opt(dyn, "email", dynamic.string) 
})
|> result.map(option.map(string.uppercase))
|> result.map(fn(maybe_email) {
  case maybe_email {
    Some(email) -> "Email: " <> email
    None -> "No email provided"
  }
})

// Array processing with decoders
json.decode("{\"items\": [1, 2, 3, 4, 5]}", decode.anything)
|> result.then(fn(dyn) { json.list(dyn, "items", dynamic.int) })
|> result.map(list.filter(fn(x) { x > 3 }))
|> result.map(list.map(fn(x) { x * 2 }))
```

## Integration with Existing fp_utils

The JSON helpers integrate seamlessly with existing fp_utils patterns:

```gleam
import fp/result
import fp/option
import fp/list
import fp/func

// Chain JSON operations with your existing helpers
json.decode(json_string, decode.anything)
|> result.then(fn(dyn) { json.get_string(dyn, "name") })
|> result.map(string.uppercase)
|> result.map(fn(name) { "Hello, " <> name <> "!" })
|> result.map(io.println)

// Use with option helpers
json.decode(json_string, decode.anything)
|> result.then(fn(dyn) { json.opt(dyn, "email", dynamic.string) })
|> result.map(option.map(fn(email) { "Email: " <> email }))
|> result.map(option.unwrap_or("No email"))

// Use with list helpers
json.decode(array_json, decode.anything)
|> result.then(fn(dyn) { json.list(dyn, "items", dynamic.int) })
|> result.map(list.filter(fn(x) { x > 0 }))
|> result.map(list.map(fn(x) { x * 2 }))
|> result.map(list.any(fn(x) { x > 10 }))
```

## Extended Combinators

- `json.get_string(dyn, "key")` → `Result(String, DecodeError)`
- `json.get_int(dyn, "key")` → `Result(Int, DecodeError)`
- `json.opt(dyn, "maybe_field", decoder)` → `Result(Option(a), DecodeError)`
- `json.list(dyn, "items", decoder)` → `Result(List(a), DecodeError)`
- `json.get_field(dyn, "field", decoder)` → `Result(a, DecodeError)`

## Benefits

1. **Pipeline-friendly**: Works seamlessly with existing fp_utils patterns using `|>` and `result.then`
2. **Error handling**: Uses Result throughout to prevent crashes with proper error propagation
3. **Composable**: Small functions that compose naturally with your existing helpers
4. **Type-safe**: Proper typing for all JSON operations with compile-time guarantees
5. **Ergonomic**: Easy to use with familiar fp_utils patterns
6. **Integration**: Leverages the battle-tested gleam_json package with dynamic decoders
7. **Performance**: Supports `to_string_tree` for better BEAM I/O performance
8. **Consistent API**: Follows the same patterns as other fp_utils modules

## Implementation Notes

To use this functionality, you would need to add the gleam_json dependency:

```sh
gleam add gleam_json@3
```

The implementation would integrate with the existing fp_utils patterns while leveraging the robust decoding capabilities of gleam_json, providing a consistent API that feels like a natural extension of your existing library.

### Example Integration with Custom Types

```gleam
import gleam/json
import gleam/dynamic/decode.{Decoder}

pub type User {
  User(name: String, age: Int, email: Option(String))
}

pub fn user_decoder() -> Decoder(User) {
  {
    use name <- decode.field("name", decode.string)
    use age <- decode.field("age", decode.int)
    use email <- decode.optional(decode.field("email", decode.string))
    decode.success(User(name:, age:, email:))
  }
}

pub fn user_to_json(user: User) -> json.Json {
  json.object([
    #("name", json.string(user.name)),
    #("age", json.int(user.age)),
    #("email", json.nullable(user.email, json.string)),
  ])
}
```

This approach provides a complete, type-safe, and pipeline-friendly JSON handling solution that integrates seamlessly with the existing fp_utils library.