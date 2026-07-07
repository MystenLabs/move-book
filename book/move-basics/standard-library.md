---
description: "Overview of the Move Standard Library: common modules for strings, vectors, options, and type names available in every Move package."
---

# Standard Library

The Move Standard Library provides functionality for native types and operations. It is a standard
collection of modules that do not interact with storage, but provide basic tools for working with
and manipulating data. It is the only dependency of the
[Sui Framework](./../programmability/sui-framework), and is imported together with it.

## Most Common Modules

In this book we go into detail about most of the modules in the Standard Library, however, it is
also helpful to give an overview of the features, so that you can get a sense of what is available
and which module implements it.

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                                                                           | Description                                                                | Chapter                              |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------ |
| [std::string](https://docs.sui.io/references/framework/std/string)               | Provides basic string operations                                           | [String](./string)                   |
| [std::ascii](https://docs.sui.io/references/framework/std/ascii)                 | Provides basic ASCII operations                                            | -                                    |
| [std::option](https://docs.sui.io/references/framework/std/option)               | Implements `Option<T>`                                                     | [Option](./option)                   |
| [std::vector](https://docs.sui.io/references/framework/std/vector)               | Native operations on the vector type                                       | [Vector](./vector)                   |
| [std::internal](https://docs.sui.io/references/framework/std/internal)           | Provides the `Permit<T>` type for module-authorized calls                  | [Internal Permit](./internal-permit) |
| [std::bcs](https://docs.sui.io/references/framework/std/bcs)                     | Contains the `bcs::to_bytes()` function                                    | [BCS](./../programmability/bcs)      |
| [std::address](https://docs.sui.io/references/framework/std/address)             | Contains a single `address::length` function                               | [Address](./address)                 |
| [std::type_name](https://docs.sui.io/references/framework/std/type_name)         | Allows runtime _type reflection_                                           | [Type Reflection](./type-reflection) |
| [std::hash](https://docs.sui.io/references/framework/std/hash)                   | Hashing functions: `sha2_256` and `sha3_256`                               | -                                    |
| [std::debug](https://docs.sui.io/references/framework/std/debug)                 | Contains debugging functions, which are available in only in **test** mode | -                                    |
| [std::unit_test](https://docs.sui.io/references/framework/std/unit_test)         | The `assert_eq!` and `assert_ref_eq!` macros for **test** code             | [Testing](./testing)                 |
| [std::bit_vector](https://docs.sui.io/references/framework/std/bit_vector)       | Provides operations on bit vectors                                         | -                                    |
| [std::uq32_32](https://docs.sui.io/references/framework/std/uq32_32)             | Fixed-point arithmetic: the `UQ32_32` type                                 | -                                    |
| [std::uq64_64](https://docs.sui.io/references/framework/std/uq64_64)             | Fixed-point arithmetic: the `UQ64_64` type                                 | -                                    |
| [std::fixed_point32](https://docs.sui.io/references/framework/std/fixed_point32) | The `FixedPoint32` type; deprecated in favor of `std::uq32_32`             | -                                    |

</div>

## Integer Modules

The Move Standard Library provides a set of functions associated with integer types. These functions
are split into multiple modules, each associated with a specific integer type. The modules should
not be imported directly, as their functions are available on every integer value.

> All of the modules provide the same set of functions: `min`, `max`, `diff`,
> `divide_and_round_up`, `sqrt`, `pow`, and `to_string`; checked conversions to smaller types -
> `try_as_u8`, `try_as_u16`, and so on; and macros, such as `max_value!` and the iteration
> helpers `do!` and `range_do!`.

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                                                         | Description                   |
| -------------------------------------------------------------- | ----------------------------- |
| [std::u8](https://docs.sui.io/references/framework/std/u8)     | Functions for the `u8` type   |
| [std::u16](https://docs.sui.io/references/framework/std/u16)   | Functions for the `u16` type  |
| [std::u32](https://docs.sui.io/references/framework/std/u32)   | Functions for the `u32` type  |
| [std::u64](https://docs.sui.io/references/framework/std/u64)   | Functions for the `u64` type  |
| [std::u128](https://docs.sui.io/references/framework/std/u128) | Functions for the `u128` type |
| [std::u256](https://docs.sui.io/references/framework/std/u256) | Functions for the `u256` type |

</div>

## Exported Addresses

The Standard Library exports a single named address - `std = 0x1`. This is where the `std` alias
used throughout the book is defined.

## Implicit Imports

Some modules are imported implicitly and are available in the module without the explicit `use`
import. For the Standard Library, these modules and types include:

- std::vector
- std::option
- std::option::Option
- std::internal

Note that `std::internal` is imported as a module, not a member: its members keep the module
prefix, as in `internal::Permit<T>` and `internal::permit<T>()` - no `use` statement required. See
the [Internal Permit](./internal-permit) section for how it is used.

## Importing std without Sui Framework

The Move Standard Library can be imported to the package directly. However, `std` alone is not
enough to build a meaningful application, as it does not provide any storage capabilities and can't
interact with the onchain state.

```toml
MoveStdlib = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/move-stdlib", rev = "framework/mainnet" }
```

## Source Code

The source code of the Move Standard Library is available in the
[Sui repository](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/packages/move-stdlib/sources).
