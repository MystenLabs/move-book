// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::balance_and_coin;

#[test_only]
use sui::balance;
#[test_only]
use sui::coin;
#[test_only]
use sui::sui::SUI;
#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_balance_operations() {
    // ANCHOR: balance
    // There is no public constructor for `Balance` - in this test we use
    // a test-only helper. Real balances come from minting or from a `Coin`.
    let mut balance = balance::create_for_testing<SUI>(1000);
    assert_eq!(balance.value(), 1000);

    // Split part of the balance into a new `Balance`.
    let part = balance.split(300);
    assert_eq!(balance.value(), 700);
    assert_eq!(part.value(), 300);

    // Join it back; `join` returns the new total.
    let total = balance.join(part);
    assert_eq!(total, 1000);

    // A zero `Balance` can be created and destroyed freely,
    // as it does not represent any value.
    let zero = balance::zero<SUI>();
    assert_eq!(zero.value(), 0);
    zero.destroy_zero();
    // ANCHOR_END: balance

    balance.destroy_for_testing();
}

#[test]
fun test_coin_operations() {
    let ctx = &mut tx_context::dummy();

    // ANCHOR: coin
    // Like `Balance`, `Coin` has no public constructor - here we use a
    // test-only helper to mint one out of thin air.
    let mut coin = coin::mint_for_testing<SUI>(1000, ctx);
    assert_eq!(coin.value(), 1000);

    // `Coin` is an object, so splitting requires `ctx` to create a new UID.
    let part = coin.split(300, ctx);
    assert_eq!(coin.value(), 700);
    assert_eq!(part.value(), 300);

    // A `Coin` can be turned into a `Balance` and back.
    let balance = part.into_balance();
    let part = balance.into_coin(ctx);

    // Join the split part back into the original coin.
    coin.join(part);
    assert_eq!(coin.value(), 1000);
    // ANCHOR_END: coin

    coin.burn_for_testing();
}
