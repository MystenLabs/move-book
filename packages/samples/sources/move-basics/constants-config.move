// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: config
module book::config;

const ITEM_PRICE: u64 = 100;
const TAX_RATE: u64 = 10;
const SHIPPING_COST: u64 = 5;

/// Returns the price of an item.
public fun item_price(): u64 { ITEM_PRICE }
/// Returns the tax rate.
public fun tax_rate(): u64 { TAX_RATE }
/// Returns the shipping cost.
public fun shipping_cost(): u64 { SHIPPING_COST }
// ANCHOR_END: config
