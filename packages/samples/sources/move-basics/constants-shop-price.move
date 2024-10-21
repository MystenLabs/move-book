// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: shop_price
module book::shop_price;

use sui::{coin::Coin, sui::SUI};

/// The price of an item in the shop.
const ITEM_PRICE: u64 = 100;
/// The owner of the shop, an address.
const SHOP_OWNER: address = @0xa11ce;

/// An item sold in the shop.
public struct Item {}

/// Purchase an item from the shop.
public fun purchase(coin: Coin<SUI>): Item {
    assert!(coin.value() == ITEM_PRICE);

    transfer::public_transfer(coin, SHOP_OWNER);

    Item {}
}
// ANCHOR_END: shop_price
