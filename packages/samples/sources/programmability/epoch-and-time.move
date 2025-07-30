// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::epoch_and_time {

// ANCHOR: epoch
public fun current_epoch(ctx: &TxContext) {
    let epoch = ctx.epoch();
    // ...
}
// ANCHOR_END: epoch

// ANCHOR: epoch_start
public fun current_epoch_start(ctx: &TxContext) {
    let epoch_start = ctx.epoch_timestamp_ms();
    // ...
}
// ANCHOR_END: epoch_start

// ANCHOR: clock
use sui::clock::Clock;

/// Clock needs to be passed as an immutable reference.
public fun current_time(clock: &Clock) {
    let time = clock.timestamp_ms();
    // ...
}
// ANCHOR_END: clock

// ANCHOR: test
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
// ANCHOR_END: test

}
