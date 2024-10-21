// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: admin_cap
module book::admin_cap;

/// The capability granting the admin privileges in the system.
/// Created only once in the `init` function.
public struct AdminCap has key { id: UID }

/// Create the AdminCap object on package publish and transfer it to the
/// package owner.
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        AdminCap { id: object::new(ctx) },
        ctx.sender()
    )
}
// ANCHOR_END: admin_cap
