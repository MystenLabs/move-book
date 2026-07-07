---
description: "The Sui Framework: built-in modules for storage, coins, display, clock, events, and other Sui-specific features available to every package."
---

# Sui Framework

Sui Framework is a default dependency set in the [Package Manifest](./../concepts/manifest). It
depends on the [Standard Library](./../move-basics/standard-library) and provides the Sui-specific
functionality: storage operations, native types, and the modules the rest of this chapter is built
on.

_For convenience, we grouped the modules in the Sui Framework into multiple categories. But they're
still part of the same framework._

## Core

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                                                                                         | Description                                                             | Chapter                                                     |
| ---------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------- |
| [sui::address](https://docs.sui.io/references/framework/sui/address)                           | Adds conversion methods to the [address type](./../move-basics/address) | [Address](./../move-basics/address)                         |
| [sui::transfer](https://docs.sui.io/references/framework/sui/transfer)                         | Implements the storage operations for Objects                           | [Storage Functions](./../storage/storage-functions.md)      |
| [sui::tx_context](https://docs.sui.io/references/framework/sui/tx_context)                     | Contains the `TxContext` struct and methods to read it                  | [Transaction Context](./transaction-context)                |
| [sui::object](https://docs.sui.io/references/framework/sui/object)                             | Defines the `UID` and `ID` type, required for creating objects          | [UID and ID](./../storage/uid-and-id.md)                    |
| [sui::derived_object](https://docs.sui.io/references/framework/sui/derived_object)             | Allows `UID` generation through key derivation                          | [UID Derivation](./../storage/uid-and-id.md#uid-derivation) |
| [sui::clock](https://docs.sui.io/references/framework/sui/clock)                               | Defines the `Clock` type and its methods                                | [Epoch and Time](./epoch-and-time)                          |
| [sui::dynamic_field](https://docs.sui.io/references/framework/sui/dynamic_field)               | Implements methods to add, use and remove dynamic fields                | [Dynamic Fields](./dynamic-fields)                          |
| [sui::dynamic_object_field](https://docs.sui.io/references/framework/sui/dynamic_object_field) | Implements methods to add, use and remove dynamic object fields         | [Dynamic Object Fields](./dynamic-object-fields)            |
| [sui::event](https://docs.sui.io/references/framework/sui/event)                               | Allows emitting events for offchain listeners                          | [Events](./events)                                          |
| [sui::package](https://docs.sui.io/references/framework/sui/package)                           | Defines the `Publisher` type and package upgrade methods                | [Publisher](./publisher)                                    |
| [sui::display](https://docs.sui.io/references/framework/sui/display)                           | Implements the `Display` object and ways to create and update it        | [Display](./display)                                        |

</div>

## Collections

<div class="modules-table">

| Module                                                                         | Description                                                       | Chapter                                      |
| ------------------------------------------------------------------------------ | ----------------------------------------------------------------- | -------------------------------------------- |
| [sui::vec_set](https://docs.sui.io/references/framework/sui/vec_set)           | Implements a set type                                             | [Collections](./collections)                 |
| [sui::vec_map](https://docs.sui.io/references/framework/sui/vec_map)           | Implements a map with vector keys                                 | [Collections](./collections)                 |
| [sui::table](https://docs.sui.io/references/framework/sui/table)               | Implements the `Table` type and methods to interact with it       | [Dynamic Collections](./dynamic-collections) |
| [sui::linked_table](https://docs.sui.io/references/framework/sui/linked_table) | Implements the `LinkedTable` type and methods to interact with it | [Dynamic Collections](./dynamic-collections) |
| [sui::bag](https://docs.sui.io/references/framework/sui/bag)                   | Implements the `Bag` type and methods to interact with it         | [Dynamic Collections](./dynamic-collections) |
| [sui::object_table](https://docs.sui.io/references/framework/sui/object_table) | Implements the `ObjectTable` type and methods to interact with it | [Dynamic Collections](./dynamic-collections) |
| [sui::object_bag](https://docs.sui.io/references/framework/sui/object_bag)     | Implements the `ObjectBag` type and methods to interact with it   | [Dynamic Collections](./dynamic-collections) |

</div>

## Coins and Assets

<div class="modules-table">

| Module                                                                 | Description                                            | Chapter                                  |
| ---------------------------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------- |
| [sui::balance](https://docs.sui.io/references/framework/sui/balance)   | The `Balance` type - the underlying store of value     | [Balance and Coin](./balance-and-coin)     |
| [sui::coin](https://docs.sui.io/references/framework/sui/coin)         | The `Coin` type - a transferable fungible asset        | [Balance and Coin](./balance-and-coin)     |
| [sui::sui](https://docs.sui.io/references/framework/sui/sui)           | The SUI coin type                                      | [Balance and Coin](./balance-and-coin)     |
| [sui::pay](https://docs.sui.io/references/framework/sui/pay)           | Helper functions for splitting and merging coins       | -                                        |
| [sui::deny_list](https://docs.sui.io/references/framework/sui/deny_list) | Deny list for regulated coin types                   | -                                        |
| [sui::token](https://docs.sui.io/references/framework/sui/token)       | The closed-loop token standard                         | -                                        |

</div>

## Utilities

<div class="modules-table">

| Module                                                             | Description                                                | Chapter                                 |
| ------------------------------------------------------------------ | ---------------------------------------------------------- | --------------------------------------- |
| [sui::bcs](https://docs.sui.io/references/framework/sui/bcs)       | Implements the BCS encoding and decoding functions         | [Binary Canonical Serialization](./bcs) |
| [sui::borrow](https://docs.sui.io/references/framework/sui/borrow) | Implements the borrowing mechanic for borrowing by _value_ | [Hot Potato](./hot-potato-pattern)      |
| [sui::hex](https://docs.sui.io/references/framework/sui/hex)       | Implements the hex encoding and decoding functions         | -                                       |
| [sui::random](https://docs.sui.io/references/framework/sui/random) | The `Random` object and secure onchain randomness         | [Randomness](./randomness)              |
| [sui::types](https://docs.sui.io/references/framework/sui/types)   | Provides a way to check if the type is a One-Time-Witness  | [One Time Witness](./one-time-witness)  |

</div>

The framework also contains modules not covered in this book: the commerce primitives
([sui::kiosk](https://docs.sui.io/references/framework/sui/kiosk),
[sui::transfer_policy](https://docs.sui.io/references/framework/sui/transfer_policy)), a set of
cryptographic functions ([sui::hash](https://docs.sui.io/references/framework/sui/hash),
[sui::ed25519](https://docs.sui.io/references/framework/sui/ed25519),
[sui::bls12381](https://docs.sui.io/references/framework/sui/bls12381), and others), and assorted
utilities such as [sui::url](https://docs.sui.io/references/framework/sui/url) and
[sui::versioned](https://docs.sui.io/references/framework/sui/versioned). Refer to the
[framework documentation](https://docs.sui.io/references/framework) for the full list.

## Exported Addresses

Sui Framework exports two named addresses: `sui = 0x2` and `std = 0x1` from the std dependency.

## Implicit Imports

Just like with [Standard Library](./../move-basics/standard-library#implicit-imports), some of the
modules and types are imported implicitly in the Sui Framework. This is the list of modules and
types that are available without explicit `use` import:

- sui::object
- sui::object::ID
- sui::object::UID
- sui::tx_context
- sui::tx_context::TxContext
- sui::transfer

## Source Code

The source code of the Sui Framework is available in the
[Sui repository](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/packages/sui-framework/sources).
