# Address Type

<!--

Chapter: Basic Syntax
Goal: Introduce the address type
Notes:
    - a special type
    - named addresses via the Move.toml
    - address literals
    - 0x2 is 0x0000000...02

Links:
    - address concept
    - transaction context
    - Move.toml
    - your first move

 -->

Move uses a special type called [address](./../concepts/address.md) to represent addresses. It is a
32-byte value that can represent any address on the blockchain. Addresses can be written in two
forms: hexadecimal addresses prefixed with 0x and named addresses.

```move file=packages/samples/sources/move-basics/address.move anchor=address_literal

```

An address literal starts with the `@` symbol followed by a hexadecimal number or an identifier. The
hexadecimal number is interpreted as a 32 byte value. The identifier is looked up in the
[Move.toml](./../concepts/manifest.md) file and replaced with the corresponding address by the
compiler. If the identifier is not found in the Move.toml file, the compiler will throw an error.

## Conversion

Sui Framework offers a set of helper functions to work with addresses. Given that the address type
is a 32 byte value, it can be converted to a `u256` type and vice versa. It can also be converted to
and from a `vector<u8>` type.

Example: Convert an address to a `u256` type and back.

```move file=packages/samples/sources/move-basics/address.move anchor=to_u256

```

Example: Convert an address to a `vector<u8>` type and back.

```move file=packages/samples/sources/move-basics/address.move anchor=to_bytes

```

Example: Convert an address into a string.

```move file=packages/samples/sources/move-basics/address.move anchor=to_string

```

## Further Reading

- [Address](./../../reference/primitive-types/address) in the Move Reference.
- [sui::address](https://docs.sui.io/references/framework/sui/address) module documentation.
