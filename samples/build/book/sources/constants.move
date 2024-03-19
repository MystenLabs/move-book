// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::constants {
    const MAX: u64 = 100;

    // however you can pass constant outside using a function
    public fun max(): u64 {
        MAX
    }

    // or using
    public fun is_max(num: u64): bool {
        num == MAX
    }
}

// ANCHOR: shop_price
module book::shop_price {
    use sui::coin::Coin;
    use sui::sui::SUI;

    /// The price of an item in the shop.
    const ITEM_PRICE: u64 = 100;
    /// The owner of the shop, an address.
    const SHOP_OWNER: address = @0xa11ce;

    /// An item sold in the shop.
    public struct Item { /* ... */ }

    /// Purchase an item from the shop.
    public fun purchase(coin: Coin<SUI>): Item {
        assert!(coin.value() == ITEM_PRICE, 0);

        transfer::public_transfer(coin, SHOP_OWNER);

        Item { /* ... */ }
    }
}
// ANCHOR_END: shop_price
