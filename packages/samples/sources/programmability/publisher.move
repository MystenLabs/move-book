// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
// ANCHOR: publisher
module book::publisher;

use sui::package::{Self, Publisher};

/// Some type defined in the module.
public struct Book {}

/// The OTW for the module.
public struct PUBLISHER has drop {}

/// Uses the One Time Witness to claim the Publisher object.
fun init(otw: PUBLISHER, ctx: &mut TxContext) {
    // Claim the Publisher object.
    let publisher: Publisher = sui::package::claim(otw, ctx);

    // Usually it is transferred to the sender.
    // It can also be stored in another object.
    transfer::public_transfer(publisher, ctx.sender())
}
// ANCHOR_END: publisher

public struct USE_PUBLISHER has drop {}

const ENotAuthorized: u64 = 1;


#[test]
fun test_publisher() {
let ctx = &mut tx_context::dummy();
let publisher = package::test_claim(USE_PUBLISHER {}, ctx);
// ANCHOR: use_publisher
// Checks if the type is from the same module, hence the `Publisher` has the
// authority over it.
assert!(publisher.from_module<Book>());

// Checks if the type is from the same package, hence the `Publisher` has the
// authority over it.
assert!(publisher.from_package<Book>());
// ANCHOR_END: use_publisher
sui::test_utils::destroy(publisher);
}

// ANCHOR: publisher_as_admin
/// Some action in the application gated by the Publisher object.
public fun admin_action(cap: &Publisher, /* app objects... */ param: u64) {
    assert!(cap.from_module<Book>(), ENotAuthorized);

    // perform application-specific action
}
// ANCHOR_END: publisher_as_admin
