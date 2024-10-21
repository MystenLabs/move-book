// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
// ANCHOR: usage
module book::dynamic_object_field;

use std::string::String;

// there are two common aliases for the long module name: `dof` and
// `ofield`. Both are commonly used and met in different projects.
use sui::dynamic_object_field as dof;
use sui::dynamic_field as df;

/// The `Character` that we will use for the example
public struct Character has key { id: UID }

/// Metadata that doesn't have the `key` ability
public struct Metadata has store, drop { name: String }

/// Accessory that has the `key` and `store` abilities.
public struct Accessory has key, store { id: UID }

#[test]
fun equip_accessory() {
    let ctx = &mut tx_context::dummy();
    let mut character = Character { id: object::new(ctx) };

    // Create an accessory and attach it to the character
    let hat = Accessory { id: object::new(ctx) };

    // Add the hat to the character. Just like with `dynamic_fields`
    dof::add(&mut character.id, b"hat_key", hat);

    // However for non-key structs we can only use `dynamic_field`
    df::add(&mut character.id, b"metadata_key", Metadata {
        name: b"John".to_string()
    });

    // Borrow the hat from the character
    let hat_id = dof::id(&character.id, b"hat_key").extract(); // Option<ID>
    let hat_ref: &Accessory = dof::borrow(&character.id, b"hat_key");
    let hat_mut: &mut Accessory = dof::borrow_mut(&mut character.id, b"hat_key");
    let hat: Accessory = dof::remove(&mut character.id, b"hat_key");

    // Clean up, Metadata is an orphan now.
    sui::test_utils::destroy(hat);
    sui::test_utils::destroy(character);
}
// ANCHOR_END: usage
