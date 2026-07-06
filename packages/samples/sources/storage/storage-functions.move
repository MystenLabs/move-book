// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::storage_functions;

use std::string::String;

// ANCHOR: admin_cap
/// A struct with `key` is an object. The first field is `id: UID`!
public struct AdminCap has key { id: UID }

/// `init` is a special function called once, when the module is
/// published. It is the best place to create singleton objects,
/// such as an admin capability.
fun init(ctx: &mut TxContext) {
    // Create the `AdminCap` object in this scope.
    let admin_cap = AdminCap { id: object::new(ctx) };

    // Transfer the object to the transaction sender.
    transfer::transfer(admin_cap, ctx.sender());
}

/// Transfers the `AdminCap` object to the `recipient`. Thus, the
/// recipient becomes the owner of the object, and only they can
/// access it.
public fun transfer_admin_cap(cap: AdminCap, recipient: address) {
    transfer::transfer(cap, recipient);
}
// ANCHOR_END: admin_cap

// ANCHOR: mint_and_transfer
/// Some `Gift` object that the admin can `mint_and_transfer`.
public struct Gift has key, store { id: UID }

/// Creates a new `Gift` object and transfers it to the `recipient`.
public fun mint_and_transfer(
    _: &AdminCap,
    recipient: address,
    ctx: &mut TxContext,
) {
    let gift = Gift { id: object::new(ctx) };
    transfer::public_transfer(gift, recipient);
}
// ANCHOR_END: mint_and_transfer

// ANCHOR: freeze_gift
/// Freezes the `Gift` object so it becomes immutable.
/// `Gift` has `key` + `store`, so `public_freeze_object` can be used!
public fun freeze_gift(gift: Gift) {
    transfer::public_freeze_object(gift);
}
// ANCHOR_END: freeze_gift

// ANCHOR: config
/// Some `Config` object that the admin can `create_and_freeze`.
public struct Config has key {
    id: UID,
    message: String,
}

/// Creates a new `Config` object and freezes it.
public fun create_and_freeze(
    _: &AdminCap,
    message: String,
    ctx: &mut TxContext,
) {
    let config = Config {
        id: object::new(ctx),
        message,
    };

    // Freeze the object so it becomes immutable.
    transfer::freeze_object(config);
}

/// Returns the message from the `Config` object.
/// Can access the object by immutable reference!
public fun message(c: &Config): String { c.message }
// ANCHOR_END: config

// ANCHOR: frozen_uncallable
/// The function can be defined, but it won't be callable on a frozen
/// object - only immutable references to it are available.
public fun message_mut(c: &mut Config): &mut String { &mut c.message }
// ANCHOR_END: frozen_uncallable

// ANCHOR: share
/// Creates a new `Config` object and shares it.
public fun create_and_share(message: String, ctx: &mut TxContext) {
    let config = Config {
        id: object::new(ctx),
        message,
    };

    // Share the object so it becomes shared.
    transfer::share_object(config);
}
// ANCHOR_END: share

// ANCHOR: delete_shared
/// Deletes the `Config` object, takes it by value.
/// Can be called on a shared object!
public fun delete_config(c: Config) {
    let Config { id, message: _ } = c;
    id.delete()
}
// ANCHOR_END: delete_shared

#[test]
fun test_storage_flow() {
    let mut ctx = tx_context::dummy();

    // Mimic what `init` does, then exercise the admin functions.
    let cap = AdminCap { id: object::new(&mut ctx) };

    mint_and_transfer(&cap, @0xB0B, &mut ctx);
    create_and_freeze(&cap, "frozen", &mut ctx);
    create_and_share("shared", &mut ctx);

    transfer_admin_cap(cap, @0xA11CE);
}

#[test]
fun test_delete_config() {
    let mut ctx = tx_context::dummy();
    let config = Config {
        id: object::new(&mut ctx),
        message: "doomed",
    };

    assert!(message(&config) == "doomed");
    delete_config(config);
}
