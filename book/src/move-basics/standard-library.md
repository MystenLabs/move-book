# Standard Library

<!-- The Move standard library provides a set of modules  -->

The Move Standard Library provides functionality for native types and operations. It is a standard
collection of modules that do not interact with storage, but provide basic tools for working with
and manipulating data. It is the only dependency of the
[Sui Framework](../programmability/sui-framework.md), and is imported together with it.

## Most Common Modules

In this book we go into detail about most of the modules in the Standard Library, however, it is
also helpful to give an overview of the features, so that you can get a sense of what is available
and which module implements it.

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                                                                           | Description                                                                | Chapter                                                                    |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| [std::string](https://docs.sui.io/references/framework/std/string)       | Provides basic string operations                                           | [String](./string.md)                                                      |
| [std::ascii](https://docs.sui.io/references/framework/std/ascii)         | Provides basic ASCII operations                                            | -                                                      |
| [std::option](https://docs.sui.io/references/framework/std/option)       | Implements `Option<T>`                                                  | [Option](./option.md)                                                      |
| [std::vector](https://docs.sui.io/references/framework/std/vector)       | Native operations on the vector type                                       | [Vector](./vector.md)                                                      |
| [std::bcs](https://docs.sui.io/references/framework/std/bcs)             | Contains the `bcs::to_bytes()` function                                    | [BCS](../programmability/bcs.md)                                               |
| [std::address](https://docs.sui.io/references/framework/std/address)     | Contains a single `address::length` function                               | [Address](./address.md)                                                    |
| [std::type_name](https://docs.sui.io/references/framework/std/type_name) | Allows runtime _type reflection_                                           | [Type Reflection](./type-reflection.md)                                    |
| [std::hash](https://docs.sui.io/references/framework/std/hash)                                                                        | Hashing functions: `sha2_256` and `sha3_256`                               | - |
| [std::debug](https://docs.sui.io/references/framework/std/debug)                                                                       | Contains debugging functions, which are available in only in **test** mode | -                                                |
| [std::bit_vector](https://docs.sui.io/references/framework/std/bit_vector)                                                                  | Provides operations on bit vectors                                         | -                                                                      |
| [std::fixed_point32](https://docs.sui.io/references/framework/std/fixed_point32)                                                               | Provides the `FixedPoint32` type                                           | -                                                    |

</div>

## Integer Modules

The Move Standard Library provides a set of functions associated with integer types. These functions
are split into multiple modules, each associated with a specific integer type. The modules should
not be imported directly, as their functions are available on every integer value.

> All of the modules provide the same set of functions. Namely, `max`, `diff`,
> `divide_and_round_up`, `sqrt` and `pow`.

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                                                                 | Description                   |
| ---------------------------------------------------------------------- | ----------------------------- |
| [std::u8](https://docs.sui.io/references/framework/std/u8)     | Functions for the `u8` type   |
| [std::u16](https://docs.sui.io/references/framework/std/u16)   | Functions for the `u16` type  |
| [std::u32](https://docs.sui.io/references/framework/std/u32)   | Functions for the `u32` type  |
| [std::u64](https://docs.sui.io/references/framework/std/u64)   | Functions for the `u64` type  |
| [std::u128](https://docs.sui.io/references/framework/std/u128) | Functions for the `u128` type |
| [std::u256](https://docs.sui.io/references/framework/std/u256) | Functions for the `u256` type |

</div>

## Exported Addresses

The Standard Library exports a single named address - `std = 0x1`. Note the alias `std` is defined here.

```toml
[addresses]
std = "0x1"
```

## Implicit Imports

Some modules are imported implicitly and are available in the module without the explicit `use`
import. For the Standard Library, these modules and types include:

- std::vector
- std::option
- std::option::Option

## Importing std without Sui Framework

The Move Standard Library can be imported to the package directly. However, `std` alone is not
enough to build a meaningful application, as it does not provide any storage capabilities and can't
interact with the on-chain state.

```toml
MoveStdlib = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/move-stdlib", rev = "framework/mainnet" }
```

## Source Code

The source code of the Move Standard Library is available in the
[Sui repository](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/packages/move-stdlib/sources).