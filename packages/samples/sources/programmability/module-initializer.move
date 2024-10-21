// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::shop;

/// The Capability which grants the Shop owner the right to manage
/// the shop.
public struct ShopOwnerCap has key, store { id: UID }

/// The singular Shop itself, created in the `init` function.
public struct Shop has key {
    id: UID,
    /* ... */
}

// Called only once, upon module publication. It must be
// private to prevent external invocation.
fun init(ctx: &mut TxContext) {
    // Transfers the ShopOwnerCap to the sender (publisher).
    transfer::transfer(ShopOwnerCap {
        id: object::new(ctx)
    }, ctx.sender());

    // Shares the Shop object.
    transfer::share_object(Shop {
        id: object::new(ctx)
    });
}
// ANCHOR_END: main
