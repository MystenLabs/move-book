// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::addr_vs_cap;

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

