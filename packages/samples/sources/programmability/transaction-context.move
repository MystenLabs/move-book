// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::transaction_context;

// ANCHOR: reading
public fun some_action(ctx: &TxContext) {
    let sender = ctx.sender();
    let tx_digest = ctx.digest();
    let epoch = ctx.epoch();
    let epoch_start = ctx.epoch_timestamp_ms();
    let sponsor = ctx.sponsor();
    let gas_price = ctx.gas_price();
    let ref_gas_price = ctx.reference_gas_price();
    // ...
}
// ANCHOR_END: reading
