// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::uid_and_id {
public struct Character has key {
    id: UID
}

// ANCHOR: lifecycle
/// Creates a new `Character` object with a unique identifier.
public fun new(ctx: &mut TxContext): Character {
    Character {
        // Fresh UID is generated from the TxContext
        id: object::new(ctx)
    }
}

/// Unpacks the `Character` object and returns the unique identifier.
public fun delete(c: Character) {
    let Character { id } = c;
    // Delete the UID
    id.delete()
}
// ANCHOR_END: lifecycle

// ANCHOR: migration
/// An example of struct that contains the old UID and the new UID.
public struct CharacterV2 has key {
    id: UID,
    old_uid: UID
}

/// Migrates the old `Character` to a new `CharacterV2` object.
public fun migrate(c: Character, ctx: &mut TxContext): CharacterV2 {
    let Character { id } = c;

    CharacterV2 {
        id: object::new(ctx),
        old_uid: id // Store the old UID
    }
}
// ANCHOR_END: migration

// ANCHOR: using_id
/// A dummy Pointer struct that points to a given ID.
public struct Pointer has key, store {
    id: UID,
    to: ID
}

/// Creates a new `Pointer` object which points to the given ID.
public fun new_pointer(to: ID, ctx: &mut TxContext): Pointer {
    Pointer {
        id: object::new(ctx),
        to
    }
}
// ANCHOR_END: using_id
// ANCHOR: pointer_pattern
/// Some object that is managed by a capability.
public struct ManagedObject has key, store { id: UID }

/// A capability that manages the `ManagedObject`. Stores the `managed_id`.
public struct Capability has key, store {
    id: UID,
    /// The ID of the managed object, guaranteed to exist.
    managed_id: ID
}

/// Creates a new `ManagedObject` and a `Capability` object.
/// Links them together, so that the `Capability` always points to an
/// existing `ManagedObject`.
public fun new_object(ctx: &mut TxContext): (ManagedObject, Capability) {
    let id = object::new(ctx);
    let managed_id = id.to_inner(); // copy the inner ID

    (
        ManagedObject { id },
        Capability { id: object::new(ctx), managed_id }
    )
}
// ANCHOR_END: pointer_pattern

#[test, allow(unused_variable)]
fun id_uid_methods() {

let ctx = &mut tx_context::dummy();
let object = Character { id: object::new(ctx) };

// ANCHOR: id_methods
let id = @sui.to_id(); // construct ID from the named address 0x2
let id = @0xa11ce.to_id();

let uid = object::new(ctx);

// the type hints are kept for clarity and are not necessary
let id: ID = uid.to_inner(); // copy the ID from the UID
let id_bytes: vector<u8> = id.to_bytes(); // get the address bytes
let id_addr: address = id.to_address(); // get the address as a string

// alternatively, there's a native function to get the `ID` for an object
// it is very useful when you take a foreign object as an argument and
// need to get its ID
let id = object::id(&object);
// ANCHOR_END: id_methods
let Character { id } = object;
id.delete();
uid.delete();
}

// ANCHOR: uid-generation
#[test]
fun test_uid_from_same_ctx() {
    // `dummy` is a helper function that creates a dummy TxContext
    let ctx1 = &mut tx_context::dummy();
    // we create the same context twice - don't do this in your tests!
    let ctx2 = &mut tx_context::dummy();

    // check that the `tx_hash` is the same
    assert!(ctx1.digest() == ctx2.digest(), 0);

    // create two objects from identical contexts
    let obj1 = object::new(ctx1);
    let obj2 = object::new(ctx2);

    // check that the UIDs are the same from the same context
    assert!(&obj1 == &obj2, 1);

    // create another UID from the context 1
    let obj3 = object::new(ctx1);

    // the new UID is different from the previous one!
    assert!(&obj1 != &obj3, 2);

    // cleanup
    obj1.delete();
    obj2.delete();
    obj3.delete();
}
// ANCHOR_END: uid-generation
}
