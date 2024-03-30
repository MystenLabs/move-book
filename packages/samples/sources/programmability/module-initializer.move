// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::store {
    /// The Capability which grants the store owner the right to manage
    /// the store.
    public struct StoreOwnerCap has key, store { id: UID }

    /// The singular store itself, created in the `init` function.
    public struct Store has key {
        id: UID,
        /* ... */
    }

    // Called only once, upon module publication. It must be
    // private to prevent external invocation.
    fun init(ctx: &mut TxContext) {
        // Transfers the StoreOwnerCap to the sender (publisher).
        transfer::transfer(StoreOwnerCap {
            id: object::new(ctx)
        }, ctx.sender());

        // Shares the Store object.
        transfer::share_object(Store {
            id: object::new(ctx)
        });
    }
}
// ANCHOR_END: main

// ANCHOR: other
// In the same package as the `store` module
module book::bank {

    public struct Bank has key {
        id: UID,
        /* ... */
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Bank {
            id: object::new(ctx)
        });
    }
}
// ANCHOR_END: other
