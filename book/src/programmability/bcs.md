# Binary Canonical Serialization

Binary Canonical Serialization (BCS) is a binary encoding format for structured data. It is designed to be simple, efficient, and deterministic. BCS is used in Sui and Move to serialize and deserialize data structures.

The format specification is available in the [BCS repository](https://github.com/zefchain/bcs).

## Using BCS

[Standard Library](./../basic-syntax/standard-library.md) provides the `std::bcs` module that contains functions for encoding and decoding data using BCS. The module has one function for getting data bytes for any type:

File: move-stdlib/sources/bcs.move
```move
public native fun to_bytes<T>(t: &T): vector<u8>;
```

[Sui Framework](./../sui-framework.md) offers its own module `sui::bcs` which allows both encoding and decoding data. Decoding is implemented in Move, without the need for a native function.


```move
{{#include ../../../packages/samples/sources/programmability/bcs.move:using_bcs}}
```
