// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::store_ability;

use std::string::String;

// ANCHOR: definition
/// Extra metadata with `store`; all of its fields must have `store` as well!
public struct Metadata has store {
    bio: String,
}

/// An object for a single user record.
public struct User has key {
    id: UID,
    name: String, // `String` has `store`
    age: u8, // all integers have `store`
    metadata: Metadata, // another type with the `store` ability
}
// ANCHOR_END: definition

#[test]
fun test_pack_unpack() {
    let mut ctx = tx_context::dummy();
    let user = User {
        id: object::new(&mut ctx),
        name: "Alice",
        age: 100,
        metadata: Metadata { bio: "Movegeist" },
    };

    let User { id, metadata: Metadata { bio: _ }, .. } = user;
    id.delete();
}
