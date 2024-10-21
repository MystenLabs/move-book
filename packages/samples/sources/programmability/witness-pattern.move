// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::witness_definition;

// ANCHOR: definition
/// Canonical definition of a witness - a type with the `drop` ability.
public struct MyWitness has drop {}
// ANCHOR_END: definition

// ANCHOR: regulated_coin
/// A custom RegulatedCoin type with implementable functions.
public struct RegulatedCoin<phantom T> has key {
    id: UID,
    value: u64
}

/// Protected function - requires a Witness.
/// Mints a new `RegulatedCoin` with the value.
public fun mint<T: drop>(_: T, value: u64, ctx: &mut TxContext): RegulatedCoin<T> {
    RegulatedCoin { id: object::new(ctx), value }
}

/// Protected function - requires a Witness.
/// Burns the `RegulatedCoin` and returns the value.
public fun burn<T: drop>(_: T, coin: RegulatedCoin<T>): u64 {
    let RegulatedCoin { id, value } = coin;
    id.delete();
    value
}

/// Protected function - requires a Witness.
public fun transfer<T: drop>(_: T, coin: RegulatedCoin<T>, to: address) {
    transfer::transfer(coin, to)
}

/// Public API - does not require a Witness.
public fun join<T>(coin: &mut RegulatedCoin<T>, other: RegulatedCoin<T>) {
    let RegulatedCoin { id, value } = other;
    coin.value = coin.value + value;
    id.delete();
}
// ANCHOR_END: regulated_coin
