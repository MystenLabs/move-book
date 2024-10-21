// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: usage
module book::dynamic_fields;

// a very common alias for `dynamic_field` is `df` since the
// module name is quite long
use sui::dynamic_field as df;
use std::string::String;

/// The object that we will attach dynamic fields to.
public struct Character has key {
    id: UID
}

// List of different accessories that can be attached to a character.
// They must have the `store` ability.
public struct Hat has key, store { id: UID, color: u32 }
public struct Mustache has key, store { id: UID }

#[test]
fun test_character_and_accessories() {
    let ctx = &mut tx_context::dummy();
    let mut character = Character { id: object::new(ctx) };

    // Attach a hat to the character's UID
    df::add(
        &mut character.id,
        b"hat_key",
        Hat { id: object::new(ctx), color: 0xFF0000 }
    );

    // Similarly, attach a mustache to the character's UID
    df::add(
        &mut character.id,
        b"mustache_key",
        Mustache { id: object::new(ctx) }
    );

    // Check that the hat and mustache are attached to the character
    //
    assert!(df::exists_(&character.id, b"hat_key"), 0);
    assert!(df::exists_(&character.id, b"mustache_key"), 1);

    // Modify the color of the hat
    let hat: &mut Hat = df::borrow_mut(&mut character.id, b"hat_key");
    hat.color = 0x00FF00;

    // Remove the hat and mustache from the character
    let hat: Hat = df::remove(&mut character.id, b"hat_key");
    let mustache: Mustache = df::remove(&mut character.id, b"mustache_key");

    // Check that the hat and mustache are no longer attached to the character
    assert!(!df::exists_(&character.id, b"hat_key"), 0);
    assert!(!df::exists_(&character.id, b"mustache_key"), 1);

    sui::test_utils::destroy(character);
    sui::test_utils::destroy(mustache);
    sui::test_utils::destroy(hat);
}
// ANCHOR_END: usage


#[test] fun foreign_types() {
let ctx = &mut tx_context::dummy();
// ANCHOR: foreign_types
let mut character = Character { id: object::new(ctx) };

// Attach a `String` via a `vector<u8>` name
df::add(&mut character.id, b"string_key", b"Hello, World!".to_string());

// Attach a `u64` via a `u32` name
df::add(&mut character.id, 1000u32, 1_000_000_000u64);

// Attach a `bool` via a `bool` name
df::add(&mut character.id, true, false);
// ANCHOR_END: foreign_types
sui::test_utils::destroy(character);
}

#[test] fun orphan_fields() {
let ctx = &mut tx_context::dummy();
// ANCHOR: orphan_fields
let hat = Hat { id: object::new(ctx), color: 0xFF0000 };
let mut character = Character { id: object::new(ctx) };

// Attach a `Hat` via a `vector<u8>` name
df::add(&mut character.id, b"hat_key", hat);

// ! DO NOT do this in your code
// ! Danger - deleting the parent object
let Character { id } = character;
id.delete();

// ...`Hat` is now stuck in a limbo, it will never be accessible again
// ANCHOR_END: orphan_fields
}

// ANCHOR: exposed_uid
/// Exposes the UID of the character, so that other modules can read
/// dynamic fields.
public fun uid(c: &Character): &UID {
    &c.id
}
// ANCHOR_END: exposed_uid

// ANCHOR: exposed_uid_measures
/// Only allow modules in the same package to access the UID.
public(package) fun uid_package(c: &Character): &UID {
    &c.id
}

/// Allow borrowing dynamic fields from the character.
public fun borrow<Name: copy + store + drop, Value: store>(
    c: &Character,
    n: Name
): &Value {
    df::borrow(&c.id, n)
}
// ANCHOR_END: exposed_uid_measures

// ANCHOR: custom_type
/// A custom type with fields in it.
public struct AccessoryKey has copy, drop, store { name: String }

/// An empty key, can be attached only once.
public struct MetadataKey has copy, drop, store {}
// ANCHOR_END: custom_type

#[test] fun use_custom_types() {
let ctx = &mut tx_context::dummy();
// ANCHOR: custom_type_usage
let mut character = Character { id: object::new(ctx) };

// Attaching via an `AccessoryKey { name: b"hat" }`
df::add(
    &mut character.id,
    AccessoryKey { name: b"hat".to_string() },
    Hat { id: object::new(ctx), color: 0xFF0000 }
);
// Attaching via an `AccessoryKey { name: b"mustache" }`
df::add(
    &mut character.id,
    AccessoryKey { name: b"mustache".to_string() },
    Mustache { id: object::new(ctx) }
);

// Attaching via a `MetadataKey`
df::add(&mut character.id, MetadataKey {}, 42);
// ANCHOR_END: custom_type_usage
sui::test_utils::destroy(character);
}
