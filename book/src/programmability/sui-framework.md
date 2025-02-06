# Sui Framework

Sui Framework is a default dependency set in the [Package Manifest](./../concepts/manifest.md). It
depends on the [Standard Library](./../move-basics/standard-library.md) and provides Sui-specific
features, including the interaction with the storage, and Sui-specific native types and modules.

_For convenience, we grouped the modules in the Sui Framework into multiple categories. But they're
still part of the same framework._

## Core

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                                                                                                   | Description                                                                | Chapter                                                                |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [sui::address](https://docs.sui.io/references/framework/sui/address)                           | Adds conversion methods to the [address type](./../move-basics/address.md) | [Address](./../move-basics/address.md)                                 |
| [sui::transfer](https://docs.sui.io/references/framework/sui/transfer)                         | Implements the storage operations for Objects                              | [It starts with an Object](./../object)                                |
| [sui::tx_context](https://docs.sui.io/references/framework/sui/tx_context)                     | Contains the `TxContext` struct and methods to read it                     | [Transaction Context](./transaction-context.md)                        |
| [sui::object](https://docs.sui.io/references/framework/sui/object)                             | Defines the `UID` and `ID` type, required for creating objects             | [It starts with an Object](./../object)                                |
| [sui::clock](https://docs.sui.io/references/framework/sui/clock)                               | Defines the `Clock` type and its methods                                   | [Epoch and Time](./epoch-and-time.md)                                  |
| [sui::dynamic_field](https://docs.sui.io/references/framework/sui/dynamic_field)               | Implements methods to add, use and remove dynamic fields                   | [Dynamic Fields](./dynamic-fields.md)                                  |
| [sui::dynamic_object_field](https://docs.sui.io/references/framework/sui/dynamic_object_field) | Implements methods to add, use and remove dynamic object fields            | [Dynamic Object Fields](./dynamic-object-fields.md)                    |
| [sui::event](https://docs.sui.io/references/framework/sui/event)                               | Allows emitting events for off-chain listeners                             | [Events](./events.md)                                                  |
| [sui::package](https://docs.sui.io/references/framework/sui/package)                           | Defines the `Publisher` type and package upgrade methods                   | [Publisher](./publisher.md), [Package Upgrades](./package-upgrades.md) |
| [sui::display](https://docs.sui.io/references/framework/sui/display)                           | Implements the `Display` object and ways to create and update it           | [Display](./display.md)                                                |

</div>

## Collections

<div class="modules-table">

| Module                                                                                   | Description                                                       | Chapter                                         |
| ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------------------------------------- |
| [sui::vec_set](https://docs.sui.io/references/framework/sui/vec_set)           | Implements a set type                                             | [Collections](./collections.md)                 |
| [sui::vec_map](https://docs.sui.io/references/framework/sui/vec_map)           | Implements a map with vector keys                                 | [Collections](./collections.md)                 |
| [sui::table](https://docs.sui.io/references/framework/sui/table)               | Implements the `Table` type and methods to interact with it       | [Dynamic Collections](./dynamic-collections.md) |
| [sui::linked_table](https://docs.sui.io/references/framework/sui/linked_table) | Implements the `LinkedTable` type and methods to interact with it | [Dynamic Collections](./dynamic-collections.md) |
| [sui::bag](https://docs.sui.io/references/framework/sui/bag)                   | Implements the `Bag` type and methods to interact with it         | [Dynamic Collections](./dynamic-collections.md) |
| [sui::object_table](https://docs.sui.io/references/framework/sui/object_table) | Implements the `ObjectTable` type and methods to interact with it | [Dynamic Collections](./dynamic-collections.md) |
| [sui::object_bag](https://docs.sui.io/references/framework/sui/object_bag)     | Implements the `ObjectBag` type and methods to interact with it   | [Dynamic Collections](./dynamic-collections.md) |

</div>

## Utilities

<div class="modules-table">

| Module                                                                       | Description                                                | Chapter                                    |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------ |
| [sui::bcs](https://docs.sui.io/references/framework/sui/bcs)       | Implements the BCS encoding and decoding functions         | [Binary Canonical Serialization](./bcs.md) |
| [sui::borrow](https://docs.sui.io/references/framework/sui/borrow) | Implements the borrowing mechanic for borrowing by _value_ | [Hot Potato](./hot-potato-pattern.md)      |
| [sui::hex](https://docs.sui.io/references/framework/sui/hex)       | Implements the hex encoding and decoding functions         | -                                          |
| [sui::types](https://docs.sui.io/references/framework/sui/types)   | Provides a way to check if the type is a One-Time-Witness  | [One Time Witness](./one-time-witness.md)  |

## Exported Addresses

Sui Framework exports two named addresses: `sui = 0x2` and `std = 0x1` from the std dependency.

```toml
[addresses]
sui = "0x2"

# Exported from the MoveStdlib dependency
std = "0x1"
```

## Implicit Imports

Just like with [Standard Library](./../move-basics/standard-library.md#implicit-imports), some of
the modules and types are imported implicitly in the Sui Framework. This is the list of modules and
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

<!--

Modules:

Coins:
- sui::pay
- sui::sui
- sui::coin
- sui::token
- sui::balance
- sui::deny_list

Commerce:
- sui::kiosk
- sui::display
- sui::kiosk_extension
- sui::transfer_policy


Utilities:
+ sui::bcs
+ sui::hex
- sui::math (deprecated)
+ sui::types
+ sui::borrow


- sui::authenticator

- sui::priority_queue
- sui::table_vec

- sui::url
- sui::versioned

- sui::prover
- sui::random

- sui::bls12381
- sui::ecdsa_k1
- sui::ecdsa_r1
- sui::ecvrf
- sui::ed25519
(also mention verifier 16 growth)
- sui::group_ops
- sui::hash
- sui::hmac
- sui::poseidon
- sui::zklogin_verified_id
- sui::zklogin_verified_issuer

 -->
