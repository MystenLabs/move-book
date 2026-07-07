---
description: "TxContext in Sui Move: access sender address, transaction digest, epoch, gas price, and generate unique IDs in your smart contracts."
---

# Transaction Context

Every transaction is executed in a _transaction context_. The context is a set of predefined
values available to the program during execution, such as the sender address, the current epoch,
or the transaction digest.

The transaction context is available to the program through the `TxContext` struct. The struct is
defined in the [`sui::tx_context`][tx-context-framework] module and contains the following fields:

[tx-context-framework]: https://docs.sui.io/references/framework/sui/tx_context

```move
module sui::tx_context;

/// Information about the transaction currently being executed.
/// This cannot be constructed by a transaction--it is a privileged object created by
/// the VM and passed in to the entrypoint of the transaction as `&mut TxContext`.
public struct TxContext has drop {
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

> While the struct still declares its original fields, current versions of the framework no longer
> read most of them directly - the getter functions forward to native functions implemented in the
> Sui execution environment. The fields are kept for compatibility, and `TxContext` is best thought
> of as an opaque handle to the execution environment.

Transaction context cannot be constructed manually or directly modified. It is created by the
system and passed to the function as a reference in a transaction. Any function called in a
[Transaction](./../concepts/what-is-a-transaction) has access to the context and can pass it into
the nested calls.

> `TxContext` has to be the last argument in the function signature.

## Reading the Transaction Context

The `sui::tx_context` module provides a getter for each of the values available in the context.
None of the getters require a mutable reference, since reading the context does not modify it:

- `sender()` - the address that signed the transaction;
- `digest()` - a reference to the 32-byte digest (hash) of the current transaction, unique per
  transaction;
- `epoch()` - the current [epoch](./epoch-and-time) number;
- `epoch_timestamp_ms()` - the timestamp of the moment the epoch started, in milliseconds;
- `sponsor()` - the address of the transaction sponsor, or `None` if the transaction was not
  sponsored;
- `gas_price()` - the gas price submitted with the current transaction;
- `reference_gas_price()` - the reference gas price of the current epoch.

```move file=packages/samples/sources/programmability/transaction-context.move anchor=reading

```

> The transaction digest is a hash of the transaction inputs, and while it is unique per
> transaction, it should never be used as a source of randomness - it is known before the
> transaction is executed, and can be manipulated by the sender.

The `sponsor()` getter is related to _sponsored transactions_ - transactions where a third party,
the sponsor, pays the gas fees on behalf of the user. In a sponsored transaction, `sender()` still
returns the address of the user, so sender-based logic behaves the same whether or not the
transaction is sponsored.

These getters are the complete public interface for reading the context. Other values, such as the
transaction's gas budget, are intentionally not exposed to the program.

## Mutability

Some operations require the context to be passed as a mutable reference - `&mut TxContext`. The
most important of them is the creation of new objects: every object on Sui must have a globally
unique `UID`. Fresh UIDs are derived from the transaction digest and a counter of IDs created so
far in this transaction - the `ids_created` field. Each time a new UID is requested, the counter is
incremented, which guarantees that every derived address is unique. Because the counter has to
change, the operation requires a mutable reference to the context.

We cover object creation in detail in the [UID and ID](./../storage/uid-and-id) section.

## Generating Unique Addresses

The same derivation mechanism can be used directly in your program to generate unique addresses.
The `sui::tx_context` module exposes the `fresh_object_address` function for that, which may be
useful if an application needs a unique identifier - for example, to use as a key in a
[dynamic field](./dynamic-fields) or an offchain index.

```move
module sui::tx_context;

/// Create an `address` that has not been used. As it is an object address, it will never
/// occur as the address for a user.
/// In other words, the generated address is a globally unique object ID.
public fun fresh_object_address(ctx: &mut TxContext): address;
```

## Transaction Context in Tests

Since `TxContext` cannot be constructed in regular code, [tests](./../move-basics/testing) would
not be able to call any function that expects it. For this scenario the framework provides
test-only constructors: the simplest of them is `tx_context::dummy()`, which returns a context
with placeholder values. You will see it in code samples throughout this book:

```move
#[test]
fun test_some_action() {
    let ctx = &mut tx_context::dummy();
    // pass `ctx` into functions that expect `&mut TxContext`
}
```

For tests that need specific values - a certain sender, epoch, or gas price - the module provides
more test-only constructors, as well as helpers to simulate epoch changes. They are covered in the
[Simulating Transaction Context](./../testing/transaction-context) section. For multi-transaction
scenarios and access to objects in storage, use the `sui::test_scenario` module, described in the
[Test Scenario](./../testing/test-scenario) section.

## Further Reading

- [sui::tx_context][tx-context-framework] module documentation.
