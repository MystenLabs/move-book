// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::capability {
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
}
// ANCHOR_END: main

// ANCHOR: admin_cap
module book::admin_cap {
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
}
// ANCHOR_END: admin_cap


module book::addr_vs_cap {

    public struct User has key, store { id: UID }

// ANCHOR: with_address
/// Error code for unauthorized access.
const ENotAuthorized: u64 = 0;

/// The application admin address.
const APPLICATION_ADMIN: address = @0xa11ce;

/// Creates a new user in the system. Requires the sender to be the application
/// admin.
public fun new(ctx: &mut TxContext): User {
    assert!(ctx.sender() == APPLICATION_ADMIN, ENotAuthorized);
    User { id: object::new(ctx) }
}
// ANCHOR_END: with_address

}

module book::cap_vs_addr {

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
}
