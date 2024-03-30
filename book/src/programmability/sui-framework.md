# Sui Framework

Sui Framework is a default dependency set in the [Package Manifest](./../concepts/manifest.md). It depends on the [Standard Library](./../basic-syntax/standard-library.md) and provides Sui-specific features, including the interaction with the storage, and Sui-specific native types and modules.

<!-- Custom CSS addition in the theme/custom.css  -->
<div class="modules-table">

| Module                    | Description                                                                 | Chapter                                                                |
| ------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| sui::address              | Adds conversion methods to the [address type](./../basic-syntax/address.md) | [Address](./../basic-syntax/address.md)                                |
| sui::transfer             | Implements the storage operations for Objects                               | [It starts with an Object](./../object)                                |
| sui::tx_context           | Contains the `TxContext` struct and methods to read it                      | [Transaction Context](./transaction-context.md)                        |
| sui::object               | Defines the `UID` and `ID` type, required for creating objects              | [It starts with an Object](./../object)                                |
| sui::clock                | Defines the `Clock` type and its methods                                    | [Epoch and Time](./epoch-and-time.md)                                  |
| sui::dynamic_field        | Implements methods to add, use and remove dynamic fields                    | [Dynamic Fields](./dynamic-fields.md)                                  |
| sui::dynamic_object_field | Implements methods to add, use and remove dynamic object fields             | [Dynamic Object Fields](./dynamic-object-fields.md)                    |
| sui::vec_map              | Implements a map with vector keys                                           | [Collections](./collections.md)                                        |
| sui::vec_set              | Implements a set type                                                       | [Collections](./collections.md)                                        |
| sui::event                | Allows emitting events for off-chain listeners                              | [Events](./events.md)                                                  |
| sui::package              | Defines the `Publisher` type and package upgrade methods                    | [Publisher](./publisher.md), [Package Upgrades](./package-upgrades.md) |
| -                         | -                                                                           | -                                                                      |

</div>

## Exported Addresses

Sui Framework exports two named addresses: `sui = 0x2` and `std = 0x1` from the std dependency.

```toml
[addresses]
sui = "0x2"

# Exported from the MoveStdlib dependency
std = "0x1"
```

## Implicit Imports

Just like with [Standard Library](./../basic-syntax/standard-library.md#implicit-imports), some of the modules and types are imported implicitly in the Sui Framework. This is the list of modules and types that are available without explicit `use` import:

- sui::object
- sui::object::ID
- sui::object::UID
- sui::tx_context
- sui::tx_context::TxContext
- sui::transfer

## Source Code

The source code of the Sui Framework is available in the [Sui repository](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/packages/sui-framework/sources).

<!--

Modules:

+ sui::address
- sui::authenticator
- sui::bag
- sui::balance
- sui::bcs
- sui::borrow
+ sui::clock
- sui::coin
- sui::deny_list
- sui::display
- sui::dynamic_field
- sui::dynamic_object_field
- sui::event
- sui::hex
- sui::linked_table
- sui::math
- sui::object_bag
- sui::object_table
- sui::object
- sui::package
- sui::pay
- sui::priority_queue
- sui::prover
- sui::random
- sui::sui
- sui::table_vec
- sui::table
- sui::token
- sui::transfer
- sui::tx_context
- sui::types
- sui::url
- sui::vec_map
- sui::vec_set
- sui::versioned

- sui::kiosk
- sui::kiosk_extension
- sui::transfer_policy

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
