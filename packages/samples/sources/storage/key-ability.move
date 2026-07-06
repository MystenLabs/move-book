// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::key_ability;

use std::string::String;

// ANCHOR: user
/// An object: a struct with the `key` ability and an `id: UID` field.
public struct User has key {
    id: UID, // required by the Sui Verifier, always the first field
    name: String, // all other fields must have `store`
}

/// Creates a new `User` object. The fresh `UID` is derived from the
/// transaction context `ctx`.
public fun new(name: String, ctx: &mut TxContext): User {
    User {
        id: object::new(ctx),
        name,
    }
}
// ANCHOR_END: user

#[test]
fun test_new() {
    let mut ctx = tx_context::dummy();
    let user = new("Alice", &mut ctx);

    // The object cannot be discarded: unpack it and delete the UID.
    let User { id, name: _ } = user;
    id.delete();
}
