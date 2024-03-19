# Standard Library

<!-- The Move standard library provides a set of modules  -->

The Move Standard Library provides functionality for native types and operations. It is a standard collection of modules which does utilize the storage model, and operates on native types. It is the only dependency of the [Sui Framework](../programmability/sui-framework.md), and is imported together with it.

## Most Common Modules

In this book we go into detail about most of the modules in the standard library, however, it is also helpful to give an overview of the features, so that you can get a sense of what is available and which module implements that.

<!-- Custom CSS addition in the theme/chrome.css  -->
<div class="modules-table">

| Module | Description | Chapter |
| ------ | ----------- | ------- |
| std::string | Provides basic string operations | [String](./string.md) |
| std::ascii | Provides basic ASCII operations | [String](./string.md) |
| std::option | Implements an `Option<T>` | [Option](./option.md) |
| std::vector | Native operations on the vector type | [Vector](./vector.md) |
| std::hash | Hashing functions: `sha2_256` and `sha3_256` | [Cryptography and Hashing](../programmability/cryptography-and-hashing.md) |
| std::bcs | Contains the `bcs::to_bytes()` function | [BCS](../basic-syntax/bcs.md) |
| std::address | Contains a single `address::length` function | [Address](./address.md) |
| std::type_name | Allows runtime *type reflection* | [Type Reflection](./type-reflection.md) |
| std::debug | Contains debugging functions, which are available in only in **test** mode | [Debugging](./debugging.md) |
| std::bit_vector | Provides operations on bit vectors | - |
| std::fixed_point32 | Provides the `FixedPoint32` type | - |

</div>

## Implicit Imports

Some of the modules are imported implicitly, and are available in the module without explicit `use` import. For Standard Library, these modules and types are:

- std::vector
- std::option
- std::option::Option

## Importing std without Sui Framework

The Move Standard Library can be imported to the package directly. However, std alone is not enough to build a meaningful application, as it does not provide any storage capabilities, and can't interact with the on-chain state.

```toml
MoveStdlib = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/move-stdlib", rev = "framework/mainnet" }
```
