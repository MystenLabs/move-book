# Transaction Context

Every transaction has the execution context. The context is a set of predefined variables that are
available to the program during execution. For example,
[every transaction](./../concepts/what-is-a-transaction.md) has a sender
[address](./../concepts/address.md), and the transaction context contains a variable that holds it.
Transaction Context is an essential part of appications on Sui, as it is required to create new
objects in the system.

## Definition

The transaction context is available to the program through the `TxContext` type. It is defined in
the `sui::tx_context` module and contains the following fields:

```move
// File: sui-framework/sources/tx_context.move
/// Information about the transaction currently being executed.
/// This cannot be constructed by a transaction--it is a privileged object created by
/// the VM and passed in to the entrypoint of the transaction as `&mut TxContext`.
struct TxContext has drop {
    /// The address of the user that signed the current transaction
    sender: address,
    /// Hash of the current transaction
    tx_hash: vector<u8>,
    /// The current epoch number
    epoch: u64,
    /// Timestamp that the epoch started at
    epoch_timestamp_ms: u64,
    /// Counter recording the number of fresh id's created while executing
    /// this transaction. Always 0 at the start of a transaction
    ids_created: u64
}
```

Transaction context cannot be constructed manually or directly modified. Instead, it is constructed
by the runtime and passed to the function as a reference in a transaction. Any function called in a
[Transaction Block](./../concepts/what-is-a-transaction.md) has access to the context and can pass
it into other functions. 

> `TxContext` has to be the last argument in the function signature.

## Reading the Transaction Context

With only exception of the `ids_created`, all of the fields in the `TxContext` have getters. The
getters are defined in the `sui::tx_context` module and are available to the program. The getters
don't require `&mut` because they don't modify the context.

```move
{{#include ../../../packages/samples/sources/storage/transaction-context.move:reading}}
```

## Mutability

The `TxContext` is required to create new objects (or just `UID`s) in the system. New UIDs are
derived from the transaction digest, and for the digest to be unique, there needs to be a changing
parameter. Sui uses the `ids_created` field for that. Every time a new UID is created, the
`ids_created` field is incremented by one. This way, the digest is always unique.

Internally, it is represented as the `derive_id` function:

```move
// File: sui-framework/sources/tx_context.move
native fun derive_id(tx_hash: vector<u8>, ids_created: u64): address;
```

## Generating unique addresses

The underlying `derive_id` function can also be utilized in your program to generate unique
addresses. The function itself is not exposed, but a wrapper function `fresh_object_address` is
available in the `sui::tx_context` module. It may be useful if you need to generate a unique
identifier in your program.

```move
// File: sui-framework/sources/tx_context.move
/// Create an `address` that has not been used. As it is an object address, it will never
/// occur as the address for a user.
/// In other words, the generated address is a globally unique object ID.
public fun fresh_object_address(ctx: &mut TxContext): address {
    let ids_created = ctx.ids_created;
    let id = derive_id(*&ctx.tx_hash, ids_created);
    ctx.ids_created = ids_created + 1;
    id
}
```

## Summary

- The transaction context is a set of predefined variables available to the program during
  execution.
- The context is passed to the program as a reference and cannot be stored nor constructed manually.
- The context contains the sender's address, the transaction hash, the epoch number, the epoch
  timestamp, and the number of fresh IDs created during the transaction.
- The `TxContext` is required to create new UIDs. The UIDs are derived from the transaction digest
  and an index.
