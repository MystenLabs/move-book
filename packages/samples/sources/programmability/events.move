// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: emit
module book::events;

use sui::coin::Coin;
use sui::sui::SUI;
use sui::event;

/// The item that can be purchased.
public struct Item has key { id: UID }

/// Event emitted when an item is purchased. Contains the ID of the item and
/// the price for which it was purchased.
public struct ItemPurchased has copy, drop {
    item: ID,
    price: u64
}

/// A marketplace function which performs the purchase of an item.
public fun purchase(coin: Coin<SUI>, ctx: &mut TxContext) {
    let item = Item { id: object::new(ctx) };

    // Create an instance of `ItemPurchased` and pass it to `event::emit`.
    event::emit(ItemPurchased {
        item: object::id(&item),
        price: coin.value()
    });

    // Omitting the rest of the implementation to keep the example simple.
    abort
}
// ANCHOR_END: emit
