// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::cap_vs_addr;

public struct User has key, store { id: UID }

// ANCHOR: with_capability
/// Grants the owner the right to create new users in the system.
public struct AdminCap {}

/// Creates a new user in the system. Requires the `AdminCap` capability to be
/// passed as the first argument.
public fun new(_: &AdminCap, ctx: &mut TxContext): User {
    User { id: object::new(ctx) }
}
// ANCHOR_END: with_capability
