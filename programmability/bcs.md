> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

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

```move
/// A struct we will encode and decode in the examples below.
public struct User has drop {
    age: u8,
    is_active: bool,
    name: String,
}
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

```move
use sui::bcs;

// 0x01 - a single byte with value 1 (or 0 for false)
let bool_bytes = bcs::to_bytes(&true);
assert_eq!(bool_bytes, x"01");

// 0x2a - just a single byte
let u8_bytes = bcs::to_bytes(&42u8);
assert_eq!(u8_bytes, x"2A");

// 0x2a00000000000000 - 8 bytes, little-endian
let u64_bytes = bcs::to_bytes(&42u64);
assert_eq!(u64_bytes, x"2A00000000000000");

// address is a fixed sequence of 32 bytes
// 0x0000000000000000000000000000000000000000000000000000000000000002
let addr = bcs::to_bytes(&@sui);
assert_eq!(addr, x"0000000000000000000000000000000000000000000000000000000000000002");
```

### Encoding a Struct

A struct is encoded as nothing more than its fields, one after another. The example below encodes
the `User` value from the [Format](#format) section, checks the exact bytes from the table, and
then demonstrates the "sequence of fields" rule directly - concatenating the individually encoded
fields yields the same result:

```move
let user = User {
    age: 42,
    is_active: true,
    name: "Bob",
};

// A struct is encoded as its fields, one after another, in the
// order they are declared: no names, no types, no separators.
//
// age       | is_active | name
// 2A        | 01        | 03 42 6F 62 (length + "Bob")
let user_bytes = bcs::to_bytes(&user);
assert_eq!(user_bytes, x"2A0103426F62");

// Concatenating individually encoded fields gives the same bytes!
let name: String = "Bob";
let mut field_bytes = vector[];
field_bytes.append(bcs::to_bytes(&42u8));
field_bytes.append(bcs::to_bytes(&true));
field_bytes.append(bcs::to_bytes(&name));

assert_eq!(user_bytes, field_bytes);
```

## Decoding

Because BCS is not a self-describing format, decoding requires prior knowledge of the data type.
This is not just a formality - the same bytes are perfectly valid under different readings, and the
decoder has no way to detect a mismatch. The 6 bytes of the encoded `User` above can just as well be
read as a `u16` followed by a `vector<u8>`:

```move
// The exact same 6 bytes that encoded the `User` above...
let mut bcs = bcs::new(x"2A0103426F62");

// ...can be read as completely different types. The bytes carry
// no type information - the reader decides what they mean.
let num = bcs.peel_u16(); // 0x012A = 298
let vec = bcs.peel_vec_u8(); // [0x42, 0x6F, 0x62]

assert_eq!(num, 298);
assert_eq!(vec, vector[66, 111, 98]);
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

```move
use sui::bcs;

// The decoder wraps the bytes; it must be declared as mutable,
// because every `peel_*` call consumes a part of the input.
let mut bcs = bcs::new(x"012A2823000000000000");

let bool_value = bcs.peel_bool();
assert_eq!(bool_value, true);

let u8_value = bcs.peel_u8();
assert_eq!(u8_value, 42);

// Whatever was not decoded can be taken back out of the wrapper.
let remainder = bcs.into_remainder_bytes();
assert_eq!(remainder.length(), 8);
```

There is a common practice to use multiple variables in a single `let` statement during decoding. It
makes code a little bit more readable and helps to avoid unnecessary copying of the data.

```move
let mut bcs = bcs::new(x"012A2823000000000000");

// mind the order!!!
// handy way to peel multiple values
let (bool_value, u8_value, u64_value) = (
    bcs.peel_bool(),
    bcs.peel_u8(),
    bcs.peel_u64(),
);

assert_eq!(u64_value, 9000);
```

### Decoding Vectors

While most of the primitive types have a dedicated decoding function, vectors need special handling,
which depends on the type of the elements. The underlying structure is always the same: first decode
the length of the vector, then decode each element in a loop.

```move
// vector[1u64, 2u64]: length prefix `02`, then the two elements
let mut bcs = bcs::new(x"0201000000000000000200000000000000");

// first, peel the length of the vector...
let mut len = bcs.peel_vec_length();
let mut vec = vector[];

// ...then peel each element in a loop
while (len > 0) {
    vec.push_back(bcs.peel_u64()); // or any other type
    len = len - 1;
};

assert_eq!(vec, vector[1, 2]);
```

For everyday use, the library offers the `peel_vec!` macro, which performs the loop internally and
calls the given function once per element, as well as ready-made `peel_vec_*` functions for vectors
of primitive types:

```move
let mut bcs = bcs::new(x"0201000000000000000200000000000000");

// The `peel_vec!` macro does the same in a single call.
let vec = bcs.peel_vec!(|bcs| bcs.peel_u64());
assert_eq!(vec, vector[1, 2]);

// For vectors of primitive types, there are ready-made functions.
let mut bcs = bcs::new(x"0201000000000000000200000000000000");
let vec = bcs.peel_vec_u64();
assert_eq!(vec, vector[1, 2]);
```

### Decoding Option

[Option](./../move-basics/option) is encoded as a single byte - `0` for _none_ and `1` for _some_ -
followed by the value, if present. The `peel_option!` macro reads the byte and evaluates the given
function only if the value is there; primitive types also have ready-made `peel_option_*` functions.

```move
// `option::none<u8>()` is a single `00` byte...
let mut bcs = bcs::new(x"00");
let none = bcs.peel_option!(|bcs| bcs.peel_u8());
assert!(none.is_none());

// ...and `option::some(42u8)` is `01` followed by the value.
let mut bcs = bcs::new(x"012A");
let some = bcs.peel_option!(|bcs| bcs.peel_u8());
assert_eq!(some, option::some(42));

// For primitive types, there are ready-made `peel_option_*` functions.
let mut bcs = bcs::new(x"012A");
let some = bcs.peel_option_u8();
assert_eq!(some, option::some(42));
```

### Decoding Structs

There is no way to automatically decode bytes into a Move struct - the [struct](../move-basics/struct)
can only be packed by its module, and the bytes carry no information about what they represent. To
parse bytes into a struct, peel each field and pack the type. The example below makes the full round
trip: it encodes a `User` value, decodes it back from the bytes, and checks that the result is
identical to the original.

```move
let user = User {
    age: 42,
    is_active: true,
    name: "Bob",
};

// Encode the value...
let mut bcs = bcs::new(bcs::to_bytes(&user));

// ...and decode it back, peeling the fields in exactly the order
// they are declared in the struct definition.
let decoded = User {
    age: bcs.peel_u8(),
    is_active: bcs.peel_bool(),
    name: bcs.peel_vec_u8().to_string(),
};

assert_eq!(user, decoded);
```

> The bytes contain no field names and no type tags, so the only thing that makes decoding correct
> is peeling the exact same types in the exact same order as they were encoded. Getting the order
> wrong does not necessarily abort - it may silently produce wrong values, as the
> [example above](#decoding) shows.

### Decoding Enums

An [enum](./../move-basics/enum-and-match) value is encoded as the index of its variant, followed by
the fields of that variant. Decoding mirrors this: the `peel_enum_tag` function reads the variant
index, and a `match` expression on it decodes the corresponding fields:

```move
let status = Status::Shipped { tracking: 12345 };

// An enum value is encoded as the variant index, followed by the
// fields of that variant.
let mut bcs = bcs::new(bcs::to_bytes(&status));

let decoded = match (bcs.peel_enum_tag()) {
    0 => Status::Pending,
    1 => Status::Shipped { tracking: bcs.peel_u64() },
    _ => abort,
};

assert_eq!(status, decoded);
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
