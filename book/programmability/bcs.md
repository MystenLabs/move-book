---
description: "BCS (Binary Canonical Serialization) in Move: encode and decode structured data for onchain storage and cross-platform communication."
---

# Binary Canonical Serialization

Binary Canonical Serialization (BCS) is a binary encoding format for structured data. It was
originally designed in Diem, and became the standard serialization format for Move. BCS is simple,
efficient, deterministic, and easy to implement in any programming language.

While serialization may sound like an advanced topic, BCS is everywhere on Sui: arguments of a
transaction are BCS-encoded, objects and events are stored as - and read offchain as - BCS bytes,
and messages signed and verified in smart contracts are usually BCS-serialized structs. Most of the
time the encoding is handled for you, but sooner or later an application needs to do it by hand:
decode a signed payload, parse raw bytes passed as a `vector<u8>` argument, or produce bytes that
match what an offchain client built.

> The full format specification is available in the
> [BCS repository](https://github.com/zefchain/bcs).

## Format

BCS is a binary format that supports unsigned integers up to 256 bits, options, booleans, unit
(empty value), fixed and variable-length sequences, and maps. The format is designed to be
deterministic, meaning that the same data will always be serialized to the same bytes.

> "BCS is not a self-describing format. As such, in order to deserialize a message, one must know
> the message type and layout ahead of time" from the [README](https://github.com/zefchain/bcs)

The core rules are:

- integers are stored in little-endian byte order;
- sequences (like [vectors](./../move-basics/vector)) are prefixed with their length, encoded as
  ULEB128 - a compact, variable-length integer encoding;
- [enums](./../move-basics/enum-and-match) are stored as the index of the variant, followed by the
  fields of that variant;
- maps are stored as ordered sequences of key-value pairs;
- structs are treated as a sequence of fields: the fields are serialized one after another, in the
  order they are defined in the struct, with no names, types, or separators in between.

To make this concrete, here is how a `User` value is laid out byte by byte:

```move file=packages/samples/sources/programmability/bcs.move anchor=user_def

```

| Field                    | Value | Encoded bytes                     |
| ------------------------ | ----- | --------------------------------- |
| `age: u8`                | `42`  | `2A`                              |
| `is_active: bool`        | `true`| `01`                              |
| `name: String`           | `"Bob"` | `03 42 6F 62` (length + bytes)  |
| `User` (all of the above)|       | `2A 01 03 42 6F 62`               |

## Using BCS

Two modules implement BCS in Move: the [Standard Library](./../move-basics/standard-library)
provides `std::bcs` with a single native encoding function `to_bytes`, and the
[Sui Framework](./sui-framework) builds on top of it with the [`sui::bcs`][sui-bcs] module, which
re-exports `to_bytes` and adds decoding functions implemented in Move. In Sui code, importing
`sui::bcs` alone is enough for both encoding and decoding.

## Encoding

To encode data, use the `bcs::to_bytes` function, which converts a data reference into a byte
vector. This function supports encoding any type, including structs and enums.

```move
module std::bcs;

/// Return the binary representation of `v` in BCS (Binary Canonical
/// Serialization) format.
public native fun to_bytes<MoveValue>(v: &MoveValue): vector<u8>;
```

The following example shows the encoding of primitive values:

```move file=packages/samples/sources/programmability/bcs.move anchor=encode

```

### Encoding a Struct

A struct is encoded as nothing more than its fields, one after another. The example below encodes
the `User` value from the [Format](#format) section, checks the exact bytes from the table, and
then demonstrates the "sequence of fields" rule directly - concatenating the individually encoded
fields yields the same result:

```move file=packages/samples/sources/programmability/bcs.move anchor=encode_struct

```

## Decoding

Because BCS is not a self-describing format, decoding requires prior knowledge of the data type.
This is not just a formality - the same bytes are perfectly valid under different readings, and the
decoder has no way to detect a mismatch. The 6 bytes of the encoded `User` above can just as well be
read as a `u16` followed by a `vector<u8>`:

```move file=packages/samples/sources/programmability/bcs.move anchor=not_self_describing

```

The [`sui::bcs`][sui-bcs] module provides functions to assist with decoding: `peel_bool`,
`peel_u8` through `peel_u256`, and `peel_address` for primitive values, a `peel_vec_*` family and a
`peel_option_*` family for common containers, and macros for everything else. If the decoder runs
out of bytes - or the bytes do not form a valid value, such as a boolean byte other than `0` or `1` -
the call aborts.

### Wrapper API

The decoder is a wrapper around the bytes: the `bcs::new` function takes the bytes by value, and
then the caller _peels off_ values one by one, front to back, by calling the `peel_*` functions.
Whatever has not been decoded stays inside the wrapper, and can be taken back out with the
`into_remainder_bytes` function.

```move file=packages/samples/sources/programmability/bcs.move anchor=decode

```

There is a common practice to use multiple variables in a single `let` statement during decoding. It
makes code a little bit more readable and helps to avoid unnecessary copying of the data.

```move file=packages/samples/sources/programmability/bcs.move anchor=chain_decode

```

### Decoding Vectors

While most of the primitive types have a dedicated decoding function, vectors need special handling,
which depends on the type of the elements. The underlying structure is always the same: first decode
the length of the vector, then decode each element in a loop.

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_vector

```

For everyday use, the library offers the `peel_vec!` macro, which performs the loop internally and
calls the given function once per element, as well as ready-made `peel_vec_*` functions for vectors
of primitive types:

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_vector_macro

```

### Decoding Option

[Option](./../move-basics/option) is encoded as a single byte - `0` for _none_ and `1` for _some_ -
followed by the value, if present. The `peel_option!` macro reads the byte and evaluates the given
function only if the value is there; primitive types also have ready-made `peel_option_*` functions.

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_option

```

### Decoding Structs

There is no way to automatically decode bytes into a Move struct - the [struct](../move-basics/struct)
can only be packed by its module, and the bytes carry no information about what they represent. To
parse bytes into a struct, peel each field and pack the type. The example below makes the full round
trip: it encodes a `User` value, decodes it back from the bytes, and checks that the result is
identical to the original.

```move file=packages/samples/sources/programmability/bcs.move anchor=round_trip

```

> The bytes contain no field names and no type tags, so the only thing that makes decoding correct
> is peeling the exact same types in the exact same order as they were encoded. Getting the order
> wrong does not necessarily abort - it may silently produce wrong values, as the
> [example above](#decoding) shows.

### Decoding Enums

An [enum](./../move-basics/enum-and-match) value is encoded as the index of its variant, followed by
the fields of that variant. Decoding mirrors this: the `peel_enum_tag` function reads the variant
index, and a `match` expression on it decodes the corresponding fields:

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_enum

```

## Summary

- BCS is the standard binary serialization format of Move: deterministic - the same value always
  produces the same bytes.
- The format is not self-describing: the bytes carry no names or types, and the reader must know the
  layout ahead of time.
- Structs and enums encode as their fields in declaration order; decoding must peel the same types
  in the same order.
- Encoding is done with `bcs::to_bytes`; decoding with the `bcs::new` wrapper and the `peel_*`
  family of functions and macros, which abort on malformed or truncated input.

## Further Reading

- [BCS specification](https://github.com/zefchain/bcs) - the full format description.
- [std::bcs](https://docs.sui.io/references/framework/std/bcs) and [sui::bcs][sui-bcs] module
  documentation.

[sui-bcs]: https://docs.sui.io/references/framework/sui/bcs
