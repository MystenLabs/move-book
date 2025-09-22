// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::receiving;

use sui::derived_object;
use sui::transfer::Receiving; // not imported by default!

/// Base derivation object to create derived `PostBox`-es.
public struct PostOffice has key { id: UID }

/// Object with derived UID which receives objects sent to an address.
public struct PostBox has key { id: UID, owner: address }

/// Transfer functionality. Anyone can come to the PostOffice and send to a specific
/// recipient's PostBox. Items can be received from the `PostBox` by the recipient.
public fun send<T: key + store>(office: &PostOffice, parcel: T, recipient: address) {
    let postbox = derived_object::derive_address(office.id.to_inner(), recipient);
    transfer::public_transfer(parcel, postbox)
}

/// Receive the parcel. Requires the sender to be the owner of the `PostBox`!
public fun receive<T: key + store>(
    box: &mut PostBox,
    to_receive: Receiving<T>,
    ctx: &TxContext
): T {
    assert!(box.owner == ctx.sender());

    // Receive `to_receive` from `PostBox`.
    let parcel = transfer::public_receive(&mut box.id, to_receive);
    parcel
}

/// If user hasn't claimed their `PostBox` yet, create it.
/// Note: this is not a requirement for transferring assets!
/// Parcels can be sent even to unregistered post boxes, see `send` implementation.
public fun register_address(office: &mut PostOffice, ctx: &mut TxContext) {
    transfer::share_object(PostBox {
        id: derived_object::claim(&mut office.id, ctx.sender()),
        owner: ctx.sender()
    })
}

// Create a PostOffice on module publish.
fun init(ctx: &mut TxContext) {
    transfer::share_object(PostOffice { id: object::new(ctx) });
}
// ANCHOR_END: main
