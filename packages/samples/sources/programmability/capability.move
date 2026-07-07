// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::capability;

use std::string::String;

/// The capability granting the application admin the right to create new
/// accounts in the system.
public struct AdminCap has key, store { id: UID }

/// The user account in the system.
public struct Account has key, store {
    id: UID,
    name: String
}

/// Creates a new account in the system. Requires the `AdminCap` capability
/// to be passed as the first argument.
public fun new(_: &AdminCap, name: String, ctx: &mut TxContext): Account {
    Account {
        id: object::new(ctx),
        name,
    }
}

/// The `Account` itself acts as a capability too: only its owner can pass
/// a mutable reference to it, and hence only the owner can update the name.
public fun update(account: &mut Account, name: String) {
    account.name = name;
}
// ANCHOR_END: main
