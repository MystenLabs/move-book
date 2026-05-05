> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

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

```move
use sui::bcs;

// 0x01 - a single byte with value 1 (or 0 for false)
let bool_bytes = bcs::to_bytes(&true);
assert_eq!(bool_bytes, x"01");

// 0x2a - just a single byte
let u8_bytes = bcs::to_bytes(&42u8);
assert_eq!(u8_bytes, x"2A");

// 0x2a00000000000000 - 8 bytes
let u64_bytes = bcs::to_bytes(&42u64);
assert_eq!(u64_bytes, x"2A00000000000000");

// address is a fixed sequence of 32 bytes
// 0x0000000000000000000000000000000000000000000000000000000000000002
let addr = bcs::to_bytes(&@sui);
assert_eq!(addr, x"0000000000000000000000000000000000000000000000000000000000000002");
```

### Encoding a Struct

Structs encode similarly to simple types. Here is how to encode a struct using BCS:

```move
let data = CustomData {
    num: 42,
    string: b"hello, world!".to_string(),
    value: true
};

let struct_bytes = bcs::to_bytes(&data);

let mut custom_bytes = vector[];
custom_bytes.append(bcs::to_bytes(&42u8));
custom_bytes.append(bcs::to_bytes(&b"hello, world!".to_string()));
custom_bytes.append(bcs::to_bytes(&true));

// struct is just a sequence of fields, so the bytes should be the same!
assert_eq!(struct_bytes, custom_bytes);
```

## Decoding

Because BCS is not a self-describing format, decoding requires prior knowledge of the data type. The
[`sui::bcs`][sui-bcs] module provides various functions to assist with this process.

### Wrapper API

BCS is implemented as a wrapper in Move. The decoder takes the bytes by value, and then allows the
caller to _peel off_ the data by calling different decoding functions, prefixed with `peel_*`. The
data is extracted from the bytes, and the remaining bytes are kept in the wrapper until the
`into_remainder_bytes` function is called.

```move
use sui::bcs;

// BCS instance should always be declared as mutable
let mut bcs = bcs::new(x"010000000000000000");

// Same bytes can be read differently, for example: Option<u64>
let value: Option<u64> = bcs.peel_option_u64();

assert_eq!(value.is_some(), true);
assert_eq!(*value.borrow(), 0);

let remainder = bcs.into_remainder_bytes();

assert_eq!(remainder.length(), 0);
```

There is a common practice to use multiple variables in a single `let` statement during decoding. It
makes code a little bit more readable and helps to avoid unnecessary copying of the data.

```move
let mut bcs = bcs::new(x"0101010F0000000000F00000000000");

// mind the order!!!
// handy way to peel multiple values
let (bool_value, u8_value, u64_value) = (
    bcs.peel_bool(),
    bcs.peel_u8(),
    bcs.peel_u64()
);
```

### Decoding Vectors

While most of the primitive types have a dedicated decoding function, vectors need special handling,
which depends on the type of the elements. For vectors, first you need to decode the length of the
vector, and then decode each element in a loop.

```move
let mut bcs = bcs::new(x"0101010F0000000000F00000000000");

// bcs.peel_vec_length() peels the length of the vector :)
let mut len = bcs.peel_vec_length();
let mut vec = vector[];

// then iterate depending on the data type
while (len > 0) {
    vec.push_back(bcs.peel_u64()); // or any other type
    len = len - 1;
};

assert_eq!(vec.length(), 1);

// The above `while` can be simplified and made more readable using a `macro`.
// bcs.peel_vec!(|bcs| bcs.peel_u64()) is equivalent to the above `while` loop.
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

[Option](./../move-basics/option) in Move is represented as a vector of either 0 or 1 element. To
read an option, you would treat it like a vector and check its length (first byte - either 1 or 0).

```move
let mut bcs = bcs::new(x"00");
let is_some = bcs.peel_bool();

assert_eq!(is_some, false);

let mut bcs = bcs::new(x"0101");
let is_some = bcs.peel_bool();
let value = bcs.peel_u8();

assert_eq!(is_some, true);
assert_eq!(value, 1);
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

```move
let mut bcs = bcs::new(x"0101010F0000000000F00000000000");

// Note: order matters!
let user = User {
    age: bcs.peel_u8(),
    is_active: bcs.peel_bool(),
    name: bcs.peel_vec_u8().to_string()
};
```

## Summary

Binary Canonical Serialization is an efficient binary format for structured data, ensuring
consistent serialization across platforms. The Sui Framework provides comprehensive tools for
working with BCS, allowing extensive functionality through built-in functions.

[sui-bcs]: https://docs.sui.io/references/framework/sui_sui/bcs
