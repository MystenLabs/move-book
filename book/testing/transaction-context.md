# Simulating Transaction Context

Most Move functions that create objects or interface with the user have a `TxContext` argument. When
a transaction is executed, its value is provided by the runtime, but in tests you need to create and
pass it yourself. The `sui::tx_context` module provides several utility functions for this purpose.

> **Note:** The utilities in this chapter are suitable for simple unit tests only. They do not
> provide access to shared or transferred objects from storage. For tests that require taking
> objects from storage or simulating multi-transaction scenarios, use
> [Test Scenario](./test-scenario.md).

## Creating a Dummy Context

The simplest way to get a `TxContext` is `tx_context::dummy()`. It creates a context with default
values - zero address sender, epoch 0, and a fixed transaction hash:

```move
use std::unit_test::assert_eq;

#[test]
fun test_create_object() {
    let ctx = &mut tx_context::dummy();
    let obj = my_module::new(ctx);

    assert_eq!(ctx.sender(), @0); // sender is 0x0 by default
    // ...
}
```

This is sufficient for most tests where you don't care about specific context values, and when you
need to test the creation of objects, rather than the interaction with the storage.

## Custom Context with `new`

When you need specific values for sender, epoch, or timestamp, use `tx_context::new`:

```move
use std::unit_test::assert_eq;

#[test]
fun test_with_specific_sender() {
    let sender = @0xA;
    let tx_hash = x"3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532";
    let epoch = 5;
    let epoch_timestamp_ms = 1234567890000;
    let ids_created = 0;

    let ctx = &mut tx_context::new(
        sender,
        tx_hash,
        epoch,
        epoch_timestamp_ms,
        ids_created,
    );

    assert_eq!(ctx.sender(), @0xA);
    assert_eq!(ctx.epoch(), 5);
}
```

The `tx_hash` must be exactly 32 bytes. For convenience, use `new_from_hint` to generate a unique
hash from a simple integer:

```move
#[test]
fun test_with_hint() {
    let ctx = &mut tx_context::new_from_hint(
        @0xA,    // sender
        42,      // hint (used to generate unique tx_hash)
        5,       // epoch
        1000,    // epoch_timestamp_ms
        0,       // ids_created
    );
    // ...
}
```

## Tracking Created Objects

When testing object creation, you may want to verify how many objects were created or get the ID of
the last created object:

```move
use std::unit_test::assert_eq;

#[test]
fun test_object_creation_count() {
    let ctx = &mut tx_context::dummy();

    assert_eq!(ctx.ids_created(), 0);

    let obj1 = my_module::new(ctx);
    assert_eq!(ctx.ids_created(), 1);

    let obj2 = my_module::new(ctx);
    assert_eq!(ctx.ids_created(), 2);

    // Get the ID of the most recently created object
    let last_id = ctx.last_created_object_id();

    // ...
}
```

## Simulating Time and Epochs

For tests that depend on time or epoch changes, use the increment functions:

```move
use std::unit_test::assert_eq;

#[test]
fun test_time_dependent_logic() {
    let ctx = &mut tx_context::dummy();

    // Initial state
    assert_eq!(ctx.epoch(), 0);
    assert_eq!(ctx.epoch_timestamp_ms(), 0);

    // Simulate epoch change
    ctx.increment_epoch_number();
    assert_eq!(ctx.epoch(), 1);

    // Simulate time passing (add 1 day in milliseconds)
    ctx.increment_epoch_timestamp(24 * 60 * 60 * 1000);
    assert_eq!(ctx.epoch_timestamp_ms(), 86_400_000);
}
```

## Full Control with `create`

For complete control over all context fields including gas-related values, use `tx_context::create`:

```move
use std::unit_test::assert_eq;

#[test]
fun test_with_full_context() {
    let ctx = &tx_context::create(
        @0xA,                    // sender
        tx_context::dummy_tx_hash_with_hint(1), // tx_hash
        10,                      // epoch
        1700000000000,           // epoch_timestamp_ms
        0,                       // ids_created
        1000,                    // reference_gas_price
        1500,                    // gas_price
        10_000_000,              // gas_budget
        option::none(),          // sponsor (None = no sponsor)
    );

    assert_eq!(ctx.gas_budget(), 10_000_000);
}
```

## Summary

| Function                      | Use Case                                      |
| ----------------------------- | --------------------------------------------- |
| `dummy()`                     | Quick context for simple tests                |
| `new()`                       | Custom sender, epoch, or timestamp            |
| `new_from_hint()`             | Like `new` but generates tx_hash from integer |
| `create()`                    | Full control including gas parameters         |
| `ids_created()`               | Check number of objects created               |
| `last_created_object_id()`    | Get ID of most recent object                  |
| `increment_epoch_number()`    | Simulate epoch progression                    |
| `increment_epoch_timestamp()` | Simulate time passing                         |

## Further Reading

- [Transaction Context](./../programmability/transaction-context.md) - detailed overview of
  `TxContext` and its role in transactions
