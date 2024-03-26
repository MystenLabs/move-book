// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::store {
    /// The Capability which grants the store owner the right to manage
    /// the store.
    public struct StoreOwnerCap has key, store { id: UID }

    /// The store itself, one and only, created in the `init` function.
    public struct Store has key {
        id: UID,
        /* ... */
    }

    // Will be called only once, when the module is published. Has to be
    // private, so it is not callable from the outside.
    fun init(ctx: &mut TxContext) {
        // transfer the StoreOwnerCap to the sender (publisher)
        transfer::transfer(StoreOwnerCap {
            id: object::new(ctx)
        }, ctx.sender());

        // share the Store object
        transfer::share_object(Store {
            id: object::new(ctx)
        })
    }
}
// ANCHOR_END: main

// ANCHOR: other
// same package with the `store` module
module book::bank {

    public struct Bank has key {
        id: UID,
        /* ... */
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Bank {
            id: object::new(ctx)
        })
    }
}
// ANCHOR_END: other
