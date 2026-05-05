> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Address Type

Move uses a special type called [address](./../concepts/address) to represent addresses. It is a
32-byte value that can represent any address on the blockchain. Addresses can be written in two
forms: hexadecimal addresses prefixed with 0x and named addresses.

```move
// address literal
let value: address = @0x1;

// named address registered in Move.toml
let value = @std;
let other = @sui;
```

An address literal starts with the `@` symbol followed by a hexadecimal number or an identifier. The
hexadecimal number is interpreted as a 32-byte value. The identifier is looked up in the
[Move.toml](./../concepts/manifest) file and replaced with the corresponding address by the
compiler. If the identifier is not found in the Move.toml file, the compiler will throw an error.

## Conversion

Sui Framework offers a set of helper functions to work with addresses. Given that the address type
is a 32-byte value, it can be converted to a `u256` type and vice versa. It can also be converted to
and from a `vector<u8>` type.

Example: Convert an address to a `u256` type and back.

```move
use sui::address;

let addr_as_u256: u256 = address::to_u256(@0x1);
let addr = address::from_u256(addr_as_u256);
```

Example: Convert an address to a `vector<u8>` type and back.

```move
use sui::address;

let addr_as_u8: vector<u8> = address::to_bytes(@0x1);
let addr = address::from_bytes(addr_as_u8);
```

Example: Convert an address into a string.

```move
use sui::address;
use std::string::String;

let addr_as_string: String = address::to_string(@0x1);
```

## Further Reading

- [Address](./../../reference/primitive-types/address) in the Move Reference.
- [sui::address](https://docs.sui.io/references/framework/sui/address) module documentation.
