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

The [Sui Framework](./sui-framework) includes the [`sui::bcs`][sui-bcs] module for encoding and
decoding data. Encoding functions are native to the VM, and decoding functions are implemented in
Move.

## Encoding

To encode data, use the `bcs::to_bytes` function, which converts data references into byte vectors.
This function supports encoding any types, including structs.

```move
module std::bcs;

public native fun to_bytes<T>(t: &T): vector<u8>;
```

The following example shows how to encode a struct using BCS. The `to_bytes` function can take any
value and encode it as a vector of bytes.

```move file=packages/samples/sources/programmability/bcs.move anchor=encode

```

### Encoding a Struct

Structs encode similarly to simple types. Here is how to encode a struct using BCS:

```move file=packages/samples/sources/programmability/bcs.move anchor=encode_struct

```

## Decoding

Because BCS is not a self-describing format, decoding requires prior knowledge of the data type. The
[`sui::bcs`][sui-bcs] module provides various functions to assist with this process.

### Wrapper API

BCS is implemented as a wrapper in Move. The decoder takes the bytes by value, and then allows the
caller to _peel off_ the data by calling different decoding functions, prefixed with `peel_*`. The
data is extracted from the bytes, and the remaining bytes are kept in the wrapper until the
`into_remainder_bytes` function is called.

```move file=packages/samples/sources/programmability/bcs.move anchor=decode

```

There is a common practice to use multiple variables in a single `let` statement during decoding. It
makes code a little bit more readable and helps to avoid unnecessary copying of the data.

```move file=packages/samples/sources/programmability/bcs.move anchor=chain_decode

```

### Decoding Vectors

While most of the primitive types have a dedicated decoding function, vectors need special handling,
which depends on the type of the elements. For vectors, first you need to decode the length of the
vector, and then decode each element in a loop.

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_vector

```

This functionality is provided by the library as a macro `peel_vec!`. It calls the inner expression
as many times as the vector length and aggregates the result into a single vector.

```move
let u64_vec = bcs.peel_vec!(|bcs| bcs.peel_u64());
let address_vec = bcs.peel_vec!(|bcs| bcs.peel_address());

// Caution: this is only possible if `MyStruct` is defined in the current module!
let my_struct = bcs.peel_vec!(|bcs| MyStruct {
    user_addr: bcs.peel_address(),
    age: bcs.peel_u8(),
});
```

### Decoding Option

<!--
> Coincidentally, Option, being a vector in Move, overlaps with the representation of an enum with a
> single variant in BCS, and makes Option in Rust fully compatible with the one in Move.
-->

[Option](./../move-basics/option) in Move is represented as a vector of either 0 or 1 element. To
read an `Option`, you would treat it like a vector and check its length (first byte - either 1 or
0).

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_option

```

Like with [vector](#decoding-vectors), there is a wrapper macro `peel_option!` which checks the
variant index and evaluates the expression if the underlying value is _some_.

```move
let u8_opt = bcs.peel_option!(|bcs| bcs.peel_u8());
let bool_opt = bcs.peel_option!(|bcs| bcs.peel_bool());
```

### Decoding Structs

Structs are decoded field by field, and there is no way to automatically decode bytes into a Move
struct. To parse bytes into a struct, you need to decode each field and instantiate the type.

```move file=packages/samples/sources/programmability/bcs.move anchor=decode_struct

```

## Summary

Binary Canonical Serialization is an efficient binary format for structured data, ensuring
consistent serialization across platforms. The Sui Framework provides comprehensive tools for
working with BCS, allowing extensive functionality through built-in functions.

[sui-bcs]: https://docs.sui.io/references/framework/sui_sui/bcs
