// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: doubloon
/// A module that creates the Doubloon currency dynamically - at any
/// point after the package is published.
module book::doubloon;

use sui::coin::Coin;
use sui::coin_registry::{Self, CoinRegistry, MetadataCap};

/// The type of the currency. For dynamic creation, the type must have
/// `key` and only `key`.
public struct Doubloon has key { id: UID }

/// Creates the "Doubloon" currency. Unlike `init`, this function can be
/// called at any time, but only from the module that defines `Doubloon`.
public fun create_currency(
    registry: &mut CoinRegistry,
    ctx: &mut TxContext,
): (Coin<Doubloon>, MetadataCap<Doubloon>) {
    let (mut initializer, mut treasury_cap) = coin_registry::new_currency<Doubloon>(
        registry,
        6, // decimals
        "DBL", // symbol
        "Doubloon", // name
        "Pirate-themed currency", // description
        "https://example.com/doubloon.svg", // icon URL
        ctx,
    );

    // Mint the entire supply upfront, then give up the `TreasuryCap`,
    // fixing the supply forever - no more minting or burning.
    let coins = treasury_cap.mint(1_000_000_000, ctx);
    initializer.make_supply_fixed(treasury_cap);

    // Finalize the initializer; `Currency<Doubloon>` becomes a shared object.
    let metadata_cap = initializer.finalize(ctx);

    (coins, metadata_cap)
}
// ANCHOR_END: doubloon

#[test_only]
use std::unit_test::assert_eq;
#[test_only]
use sui::coin;
#[test_only]
use sui::test_utils;

#[test]
fun test_create_currency() {
    // `dummy()` context has the `@0x0` sender, required by the test-only
    // registry constructor.
    let ctx = &mut tx_context::dummy();
    let mut registry = coin_registry::create_coin_data_registry_for_testing(ctx);

    let (coins, metadata_cap) = create_currency(&mut registry, ctx);
    assert_eq!(coins.value(), 1_000_000_000);

    test_utils::destroy(coins);
    test_utils::destroy(metadata_cap);
    coin_registry::share_for_testing(registry);
}

#[test]
fun test_mint_burn() {
    let ctx = &mut tx_context::dummy();

    // ANCHOR: mint_burn
    // Test-only constructor - normally the `TreasuryCap` comes from
    // currency creation.
    let mut treasury_cap = coin::create_treasury_cap_for_testing<Doubloon>(ctx);

    // Mint 100 units, increasing the total supply.
    let coin = treasury_cap.mint(100, ctx);
    assert_eq!(coin.value(), 100);
    assert_eq!(treasury_cap.total_supply(), 100);

    // Burn the coin, decreasing the total supply.
    let burned = treasury_cap.burn(coin);
    assert_eq!(burned, 100);
    assert_eq!(treasury_cap.total_supply(), 0);
    // ANCHOR_END: mint_burn

    test_utils::destroy(treasury_cap);
}
