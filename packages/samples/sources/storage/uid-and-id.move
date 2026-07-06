// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::uid_and_id;

// ANCHOR: lifecycle
public struct Character has key { id: UID }

/// Creates a `Character` object and immediately destroys it:
/// the UID can only be deleted after the object is unpacked.
public fun create_and_destroy(ctx: &mut TxContext) {
    // Instantiate the `Character` object with a fresh UID.
    let char = Character { id: object::new(ctx) };

    // Unpack the object to take out its UID.
    let Character { id } = char;

    // Delete the UID.
    id.delete();
}
// ANCHOR_END: lifecycle

// ANCHOR: derived
use sui::derived_object;

/// Some central application object.
public struct Base has key { id: UID }

/// A derived object.
public struct Derived has key { id: UID }

/// Creates and shares a new `Derived` object, using an `address`
/// as the derivation key.
public fun derive(base: &mut Base, key: address) {
    let id = derived_object::claim(&mut base.id, key);
    transfer::share_object(Derived { id })
}
// ANCHOR_END: derived

// ANCHOR: conversions
public fun conversion_methods(ctx: &mut TxContext) {
    let uid: UID = object::new(ctx);

    // `to_inner` returns a copy of the underlying `ID`.
    let id: ID = uid.to_inner();

    // Both `UID` and `ID` can be converted to a plain address.
    let addr_from_uid: address = uid.to_address();
    let addr_from_id: address = id.to_address();

    uid.delete();
}
// ANCHOR_END: conversions

#[test]
fun test_lifecycle_and_conversions() {
    let mut ctx = tx_context::dummy();
    create_and_destroy(&mut ctx);
    conversion_methods(&mut ctx);
}

#[test]
fun test_derive() {
    let mut ctx = tx_context::dummy();
    let mut base = Base { id: object::new(&mut ctx) };

    derive(&mut base, @0x1);

    // The derived address is deterministic and can be recomputed.
    let derived_addr = derived_object::derive_address(base.id.to_inner(), @0x1);
    assert!(derived_object::exists(&base.id, @0x1));

    transfer::share_object(base);
}
