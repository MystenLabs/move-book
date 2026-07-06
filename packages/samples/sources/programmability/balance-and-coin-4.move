// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: currency_reader
module book::currency_reader;

use sui::coin::Coin;
use sui::coin_registry::Currency;

/// The coin value has a fractional part.
const ENotWholeUnit: u64 = 0;

/// The number of whole units in the coin, calculated with the
/// on-chain `decimals` value. Aborts if the value has a fractional
/// part - a "half a coin" deposit is not allowed.
public fun whole_units<T>(currency: &Currency<T>, coin: &Coin<T>): u64 {
    let one_unit = 10u64.pow(currency.decimals());
    assert!(coin.value() % one_unit == 0, ENotWholeUnit);
    coin.value() / one_unit
}
// ANCHOR_END: currency_reader
