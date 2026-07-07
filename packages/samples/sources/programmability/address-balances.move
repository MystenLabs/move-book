// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::address_balances;

use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::funds_accumulator::Withdrawal;

// ANCHOR: pay
/// Deposit a coin into the recipient's address balance.
public fun pay<T>(coin: Coin<T>, recipient: address) {
    coin.send_funds(recipient);
}
// ANCHOR_END: pay

// ANCHOR: collect
/// Redeem a withdrawal provided by the transaction into a spendable coin.
public fun collect<T>(w: Withdrawal<Balance<T>>, ctx: &mut TxContext): Coin<T> {
    coin::redeem_funds(w, ctx)
}
// ANCHOR_END: collect

// ANCHOR: split_join
public fun inspect_and_split<T>(w: &mut Withdrawal<Balance<T>>): (address, u256) {
    // Read who the funds belong to and how much may still be withdrawn.
    let owner = w.owner();
    let remaining = w.limit();

    // Carve off a sub-withdrawal with its own, smaller limit. The
    // parent's limit is reduced by the same amount.
    let sub: Withdrawal<Balance<T>> = w.split(100);

    // Withdrawals from the same owner can be joined back together,
    // adding the limits up.
    w.join(sub);

    (owner, remaining)
}
// ANCHOR_END: split_join

// ANCHOR: object_withdraw
/// Withdraw `value` units of `T` held at this object's address.
public fun withdraw<T>(id: &mut UID, value: u64): Withdrawal<Balance<T>> {
    balance::withdraw_funds_from_object<T>(id, value)
}
// ANCHOR_END: object_withdraw
