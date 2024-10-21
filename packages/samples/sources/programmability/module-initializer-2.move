// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: other
// In the same package as the `shop` module
module book::bank;

public struct Bank has key {
    id: UID,
    /* ... */
}

fun init(ctx: &mut TxContext) {
    transfer::share_object(Bank {
        id: object::new(ctx)
    });
}
// ANCHOR_END: other
