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
public fun purchase(seller: address, coin: Coin<SUI>, ctx: &mut TxContext): Item {
    let item = Item { id: object::new(ctx) };

    // Create an instance of `ItemPurchased` and pass it to `event::emit`.
    event::emit(ItemPurchased {
        item: object::id(&item),
        price: coin.value()
    });

    // Send the payment to the seller, return the item to the caller.
    transfer::public_transfer(coin, seller);
    item
}
// ANCHOR_END: emit

#[test_only]
use std::unit_test::assert_eq;

// ANCHOR: test
#[test]
fun test_emit_item_purchased() {
    let ctx = &mut tx_context::dummy();
    let item = Item { id: object::new(ctx) };
    let item_id = object::id(&item);

    event::emit(ItemPurchased { item: item_id, price: 100 });

    // Total number of events emitted in this test so far.
    assert_eq!(event::num_events(), 1);

    // Read back all `ItemPurchased` events and check their contents.
    let purchases = event::events_by_type<ItemPurchased>();
    assert_eq!(purchases.length(), 1);
    assert_eq!(purchases[0].item, item_id);
    assert_eq!(purchases[0].price, 100);

    std::unit_test::destroy(item);
}
// ANCHOR_END: test
