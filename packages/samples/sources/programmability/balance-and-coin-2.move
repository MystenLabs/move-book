// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: gold
/// A module that creates the GOLD currency on package publish.
module book::gold;

use sui::coin_registry;

/// The One-Time Witness for the GOLD currency.
public struct GOLD has drop {}

/// Called once, on package publish. Creates the `Currency<GOLD>` and
/// a `TreasuryCap<GOLD>` to manage the supply.
fun init(otw: GOLD, ctx: &mut TxContext) {
    let (initializer, treasury_cap) = coin_registry::new_currency_with_otw(
        otw,
        8, // decimals
        "GOLD", // symbol
        "Gold", // name
        "In-game gold currency", // description
        "https://example.com/gold.svg", // icon URL
        ctx,
    );

    // Finalize the initializer, claiming the `MetadataCap`.
    let metadata_cap = initializer.finalize(ctx);

    // Transfer both capabilities to the publisher.
    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata_cap, ctx.sender());
}
// ANCHOR_END: gold

#[test]
fun test_init() {
    let ctx = &mut tx_context::dummy();
    init(sui::test_utils::create_one_time_witness<GOLD>(), ctx);
}
