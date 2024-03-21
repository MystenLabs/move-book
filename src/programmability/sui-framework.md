# Sui Framework

Sui Framework is a default dependency set in the [Package Manifest](./../concepts/manifest.md). It depends on the [Standard Library](./../basic-syntax/standard-library.md) and provides Sui-specific features, including the interaction with the storage, and Sui-specific native types and modules.

| Module | Description | Chapter |
| ------ | ----------- | ------- |
| sui::address | Adds conversion methods to the [address type](./../basic-syntax/address.md) | [Address](./../basic-syntax/address.md) |
| - | - | - |

## Implicit Imports

Just like with [Standard Library](./../basic-syntax/standard-library.md), some of the modules and types are imported implicitly in the Sui Framework. This is the list of modules and types that are available without explicit `use` import:

- sui::object
- sui::object::ID
- sui::object::UID
- sui::tx_context
- sui::tx_context::TxContext
- sui::transfer

<!--

Modules:

- sui::address
- sui::authethicator_state
- sui::bag
- sui::balance
- sui::bcs
- sui::borrow
- sui::clock
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
- sui::groth16
- sui::group_ops
- sui::hash
- sui::hmac
- sui::poseidon
- sui::zklogin_verified_id
- sui::zklogin_verified_issuer

 -->
