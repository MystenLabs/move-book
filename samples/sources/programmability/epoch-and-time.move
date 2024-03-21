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

}
