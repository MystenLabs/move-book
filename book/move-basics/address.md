---
description: "The address type in Move: literals, named addresses, conversion functions, and how addresses identify accounts and packages on Sui."
---

# Address Type

Move uses a special type called [address](./../concepts/address) to represent addresses - the
32-byte values that identify accounts, packages, and objects on the blockchain. In an expression,
an address literal starts with the `@` symbol, followed either by a hexadecimal number or by an
identifier:

```move file=packages/samples/sources/move-basics/address.move anchor=address_literal

```

The hexadecimal number is interpreted as a 32-byte value, with the missing leading bytes filled
with zeros - so `@0x2` is a shorthand for the address ending in `...0002`. The identifier is looked
up in the [Move.toml](./../concepts/manifest) file and replaced with the corresponding address by
the compiler; if it is not found there, compilation fails.

> Some addresses are reserved by the system: for example, the [Standard Library](./standard-library)
> lives at `0x1` and the Sui Framework at `0x2`. The full list is in
> [Appendix B: Reserved Addresses](./../appendix/reserved-addresses).

## Conversion

Sui Framework offers a set of helper functions to work with addresses. Given that the address type
is a 32-byte value, it can be converted to a `u256` type and vice versa. It can also be converted to
and from a `vector<u8>` type.

> The examples below use the [vector](./vector) and [String](./string) types, which are covered
> later in this chapter - for now, it is enough to know that a conversion to and from bytes and
> text exists.

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
