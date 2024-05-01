// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::transfer_to_sender {
    use std::string::String;

// ANCHOR: transfer
/// A struct with `key` is an object. The first field is `id: UID`!
public struct AdminCap has key { id: UID }

/// Init function will be called once on module publish.
fun init(ctx: &mut TxContext) {
    // Create a new `AdminCap` object.
    let admin_cap = AdminCap { id: object::new(ctx) };

    // Transfer the object to the transaction sender.
    transfer::transfer(admin_cap, ctx.sender());
}
// ANCHOR_END: transfer

// ANCHOR: transfer_owned
/// Transfers the `AdminCap` object to the `recipient`. Thus, the recipient
/// becomes the owner of the object, and only they can access it.
public fun transfer_admin_cap(cap: AdminCap, recipient: address) {
    transfer::transfer(cap, recipient);
}
// ANCHOR_END: transfer_owned

// ANCHOR: mint_and_transfer
/// Some `Gift` object that the admin can `mint_and_transfer`.
public struct Gift has key { id: UID }

/// Creates a new `Gift` object and transfers it to the `recipient`.
public fun mint_and_transfer(
    _: &AdminCap, recipient: address, ctx: &mut TxContext
) {
    let gift = Gift { id: object::new(ctx) };
    transfer::transfer(gift, recipient);
}
// ANCHOR_END: mint_and_transfer

// ANCHOR: freeze
/// Some `Config` object that the admin can `create_and_freeze`.
public struct Config has key {
    id: UID,
    message: String
}

/// Creates a new `Config` object and freezes it.
public fun create_and_freeze(
    _: &AdminCap, message: String, ctx: &mut TxContext
) {
    let config = Config {
        id: object::new(ctx),
        message
    };

    // Freeze the object so it becomes immutable.
    transfer::freeze_object(config);
}

/// Returns the message from the `Config` object.
/// Can access the object by immutable reference!
public fun message(c: &Config): String { c.message }
// ANCHOR_END: freeze

// ANCHOR: freeze_owned
/// Freezes the `Gift` object so it becomes immutable.
public fun freeze_gift(gift: Gift) {
    transfer::freeze_object(gift);
}
// ANCHOR_END: freeze_owned

// ANCHOR: modify_config
/// The function can be defined, but it won't be callable on a frozen object!
public fun message_mut(_: &AdminCap, c: &mut Config): &mut String {
    &mut c.message
}
// ANCHOR_END: modify_config

// ANCHOR: delete_config
/// Deletes the `Config` object, takes it by value.
/// Can't be called on a frozen object!
public fun delete_config(_: &AdminCap, c: Config) {
    let Config { id, message: _ } = c;
    id.delete()
}
// ANCHOR_END: delete_config

// ANCHOR: share
public fun create_and_share(
    _: &AdminCap, message: String, ctx: &mut TxContext
) {
    let config = Config {
        id: object::new(ctx),
        message
    };

    // Share the object.
    transfer::share_object(config);
}
// ANCHOR_END: share
}
