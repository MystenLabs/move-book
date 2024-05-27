// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::transfer_to_object {
use std::string::String;

use sui::transfer::Receiving;

/// An invite to join a group. Sent to a user's mailbox.
public struct Invite has key {
    id: UID,
    group: ID,
}


/// Send an invite to a user's mailbox.
public fun send_invite(group: ID, mailbox_id: ID, ctx: &mut TxContext) {
    transfer::transfer(Invite {
        id: object::new(ctx),
        group
    }, mailbox_id.to_address())
}

/// Receive an invite from a mailbox. Due to `Invite` being a `key`-only object,
/// it can only be received by this module (the one declaring the `Invite`).
public fun receive_invite(
    mailbox: &mut Mailbox, to_receive: Receiving<Invite>
): Invite {
    transfer::receive(&mut mailbox.id, to_receive)
}

/// Objects that have `store` ability can also be received in the Mailbox.
public fun public_receive<T: key + store>(
    mailbox: &mut Mailbox, to_receive: Receiving<T>
): T {
    transfer::public_receive(&mut mailbox.id, to_receive)
}

public struct Letter has key, store {
    id: UID,
    message: String,
}

// ANCHOR: send_to_object
/// A private mailbox object that can receive letters.
public struct Mailbox has key, store {
    id: UID
}

/// Send a message to a `Mailbox` object.
/// Assuming that the `Mailbox` implements necessary methods to receive the message.
public fun send(obj: &Mailbox, message: String, ctx: &mut TxContext) {
    // simple object with a `String` message.
    let letter = Letter { id: object::new(ctx), message };

    // send the letter to the Mailbox address
    transfer::transfer(letter, obj.id.to_address())
}
// ANCHOR_END: send_to_object
}
