// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::transaction_context {

// ANCHOR: reading
public fun some_action(ctx: &TxContext) {
    let me = ctx.sender();
    let epoch = ctx.epoch();
    let digest = ctx.digest();
    // ...
}
// ANCHOR_END: reading

}
