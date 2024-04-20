# Binary Canonical Serialization

Binary Canonical Serialization (BCS) is a binary encoding format for structured data. It was
originally designed in Diem, and became the standard serialization format for Move. BCS is simple,
efficient, deterministic, and easy to implement in any programming language.

> The full format specification is available in the
> [BCS repository](https://github.com/zefchain/bcs).

## Format

BCS is a binary format that supports unsigned integers up to 256 bits, options, booleans, unit
(empty value), fixed and variable-length sequences, and maps. The format is designed to be
deterministic, meaning that the same data will always be serialized to the same bytes.

> "BCS is not a self-describing format. As such, in order to deserialize a message, one must know
> the message type and layout ahead of time" from the [README](https://github.com/zefchain/bcs)

Integers are stored in little-endian format, and variable-length integers are encoded using a
variable-length encoding scheme. Sequences are prefixed with their length as ULEB128, enumerations
are stored as the index of the variant followed by the data, and maps are stored as an ordered
sequence of key-value pairs.

Structs are treated as a sequence of fields, and the fields are serialized in the order they are
defined in the struct. The fields are serialized using the same rules as the top-level data.

## Using BCS

The [Sui Framework](./sui-framework.md) includes the sui::bcs module for encoding and decoding data. Encoding functions are native to the VM, and decoding functions are implemented in Move.

## Encoding

To encode data, use the `bcs::to_bytes` function, which converts data references into byte vectors. This function supports encoding any types, including structs.

```move
// File: move-stdlib/sources/bcs.move
public native fun to_bytes<T>(t: &T): vector<u8>;
```

The following example shows how to encode a struct using BCS. The `to_bytes` function can take any
value and encode it as a vector of bytes.

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:encode}}
```

### Encoding a Struct

Structs encode similarly to simple types. Here is how to encode a struct using BCS:

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:encode_struct}}
```

## Decoding

Because BCS does not self-describe and Move is statically typed, decoding requires prior knowledge of the data type. The `sui::bcs` module provides various functions to assist with this process.

### Wrapper API

BCS is implemented as a wrapper in Move. The decoder takes the bytes by value, and then allows the
caller to _peel off_ the data by calling different decoding functions, prefixed with `peel_*`. The
data is split off the bytes, and the remainder bytes are kept in the wrapper until the
`into_remainder_bytes` function is called.

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:decode}}
```

There is a common practice to use multiple variables in a single `let` statement during decoding. It
makes code a little bit more readable and helps to avoid unnecessary copying of the data.

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:chain_decode}}
```

### Decoding Vectors

While most of the primitive types have a dedicated decoding function, vectors need special handling,
which depends on the type of the elements. For vectors, first you need to decode the length of the
vector, and then decode each element in a loop.

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:decode_vector}}
```

For most common scenarios, `bcs` module provides a basic set of functions for decoding vectors:

- `peel_vec_address(): vector<address>`
- `peel_vec_bool(): vector<bool>`
- `peel_vec_u8(): vector<u8>`
- `peel_vec_u64(): vector<u64>`
- `peel_vec_u128(): vector<u128>`
- `peel_vec_vec_u8(): vector<vector<u8>>` - vector of byte vectors

### Decoding Option

<!--
> Coincidentally, Option, being a vector in Move, overlaps with the representation of an enum with a
> single variant in BCS, and makes Option in Rust fully compatible with the one in Move.
-->

[Option](./../move-basics/option.md) is represented as a vector of either 0 or 1 element. To read an
option, you would treat it like a vector and check its length (first byte - either 1 or 0).

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:decode_option}}
```

> If you need to decode an option of a custom type, use the method in the code snippet above.

The most common scenarios, `bcs` module provides a basic set of functions for decoding Option's:

- `peel_option_address(): Option<address>`
- `peel_option_bool(): Option<bool>`
- `peel_option_u8(): Option<u8>`
- `peel_option_u64(): Option<u64>`
- `peel_option_u128(): Option<u128>`

### Decoding Structs

Structs are decoded field by field, and there is no standard function to automatically decode bytes
into a Move struct, and it would have been a violation of the Move's type system. Instead, you need
to decode each field manually.

```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:decode_struct}}
```

## Summary

Binary Canonical Serialization is an efficient binary format for structured data, ensuring consistent serialization across platforms. The Sui Framework provides comprehensive tools for working with BCS, allowing extensive functionality through built-in functions.
