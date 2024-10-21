// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::capability;

use std::string::String;
use sui::event;

/// The capability granting the application admin the right to create new
/// accounts in the system.
public struct AdminCap has key, store { id: UID }

/// The user account in the system.
public struct Account has key, store {
    id: UID,
    name: String
}

/// A simple `Ping` event with no data.
public struct Ping has copy, drop { by: ID }

/// Creates a new account in the system. Requires the `AdminCap` capability
/// to be passed as the first argument.
public fun new(_: &AdminCap, name: String, ctx: &mut TxContext): Account {
    Account {
        id: object::new(ctx),
        name,
    }
}

/// Account, and any other objects, can also be used as a Capability in the
/// application. For example, to emit an event.
public fun send_ping(acc: &Account) {
    event::emit(Ping {
        by: acc.id.to_inner()
    })
}

/// Updates the account name. Can only be called by the `Account` owner.
public fun update(account: &mut Account, name: String) {
    account.name = name;
}
// ANCHOR_END: main
