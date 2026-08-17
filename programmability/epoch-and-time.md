> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Epoch and Time

Sui has two ways of accessing the current time: the _epoch_ and the `Clock` object. The former
represents operational periods in the system and changes roughly every 24 hours. The latter gives
the current time in milliseconds since the Unix Epoch. Both can be accessed freely in the program.

## Epoch

Epochs are used to separate the system into operational periods. During an epoch the validator set
is fixed; at the epoch boundary, it can change. Epochs play a crucial role in the consensus
algorithm and are used as a unit of measurement in the staking mechanism.

The current epoch can be read from the [transaction context](./transaction-context):

```move
public fun current_epoch(ctx: &TxContext) {
    let epoch = ctx.epoch();
    // ...
}
```

It is also possible to get the Unix timestamp (in milliseconds) of the epoch start:

```move
public fun current_epoch_start(ctx: &TxContext) {
    let epoch_start = ctx.epoch_timestamp_ms();
    // ...
}
```

Both values are embedded in the transaction itself, so reading them is free and does not require
access to any object.

Normally, epochs are used in staking and system operations, however, in custom scenarios they can be
used to emulate 24h periods. They are critical if an application relies on the staking logic or
needs to know the current validator set.

## Time

For a more precise time measurement, Sui provides the `Clock` object. It is a system object,
updated by a system transaction on every consensus commit - roughly every quarter of a second -
which stores the current time in milliseconds since the Unix Epoch. The `Clock` object is defined
in the `sui::clock` module and has a
[reserved address](./../appendix/reserved-addresses) `0x6`.

Clock is a shared object, but a transaction attempting to access it mutably will fail. This
limitation allows parallel access to the `Clock` object, which is important for maintaining
performance.

```move
module sui::clock;

/// Singleton shared object that exposes time to Move calls.  This
/// object is found at address 0x6, and can only be read (accessed
/// via an immutable reference) by entry functions.
///
/// Entry Functions that attempt to accept `Clock` by mutable
/// reference or value will fail to verify, and honest validators
/// will not sign or execute transactions that use `Clock` as an
/// input parameter, unless it is passed by immutable reference.
public struct Clock has key {
    id: UID,
    /// The clock's timestamp, which is set automatically by a
    /// system transaction every time consensus commits a
    /// schedule, or by `sui::clock::increment_for_testing` during
    /// testing.
    timestamp_ms: u64,
}
```

For regular use, the module exposes a single function - `timestamp_ms`. It returns the current
time in milliseconds since the Unix Epoch.

```move
use sui::clock::Clock;

/// Clock needs to be passed as an immutable reference.
public fun current_time(clock: &Clock) {
    let time = clock.timestamp_ms();
    // ...
}
```

The `Clock` comes with a few useful guarantees: within a single transaction, `timestamp_ms` always
returns the same value, and across transactions the value never decreases. However, because the
clock is only updated on consensus commits, transactions executed close to each other may see an
identical timestamp.

## Testing

Since the real `Clock` is only updated by the system, the module provides test-only functions to
create a clock, set its value, and destroy it:

```move
#[test_only]
use sui::clock;
#[test_only]
use std::unit_test::assert_eq;

#[test]
fun use_clock_in_test() {
    // Get `ctx` and create `Clock` for testing
    let ctx = &mut tx_context::dummy();
    let mut clock = clock::create_for_testing(ctx);
    assert_eq!(clock.timestamp_ms(), 0);

    // Add a value to the timestamp stored in `Clock`
    clock.increment_for_testing(2_000_000_000);
    assert_eq!(clock.timestamp_ms(), 2_000_000_000);

    // Set the timestamp, but the time set must be no less than the value stored in `Clock`
    clock.set_for_testing(3_000_000_000);
    assert_eq!(clock.timestamp_ms(), 3_000_000_000);

    // The following setting will fail because the time set must be at least the timestamp stored in `Clock`
    // clock.set_for_testing(1_000_000_000);
    // assert_eq!(clock.timestamp_ms(), 1_000_000_000);

    // If need a shared `Clock` for testing, you can set it through this function
    // clock.share_for_testing();

    // `Clock` does not have a `drop` capability, so it needs to be destroyed manually at the end of the test
    clock.destroy_for_testing();
}
```

## Summary

- The current epoch and its start timestamp are read from the
  [transaction context](./transaction-context) - free and available in every transaction; an
  epoch lasts roughly 24 hours.
- The `Clock` object at the reserved address `0x6` gives the time in milliseconds, updated on
  every consensus commit; it can only be accessed immutably.
- Within a transaction the `Clock` value never changes, and across transactions it never
  decreases.
- In tests, use `create_for_testing`, `set_for_testing`, `increment_for_testing`, and
  `destroy_for_testing` to control the clock.

## Further Reading

- [sui::clock](https://docs.sui.io/references/framework/sui/clock) module documentation.
