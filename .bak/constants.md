The Move Book

Constants
Constants are immutable values that are defined in the module. They often serve as a way to give names to values that are used throughout a module, which otherwise would be hard to remember. For example, if there's a default price for a product, you might define a constant for it. Constants are stored in the module's bytecode, and each time they are used, the value is copied.


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
Naming Convention
Constants must start start with a capital letter - this is enforced at the compiler level. For constants used as a value, there's a convention to use uppercase letters and underscores to separate words. It's a way to make constants stand out from other identifiers in the code. One exception is made for error constants, which are written in ECamelCase.

Constants are Immutable
Constants can't be changed and assigned new values, however, they can be removed or redefined with package upgrades.

module book::immutable_constants {
    const ITEM_PRICE: u64 = 100;

    // Compiler error!
    fun change_price() {
        ITEM_PRICE = 200;
    }
}
Using Config Pattern
A common use case for an application is to define a set of constants that are used throughout the codebase. But due to constants being private to the module, they can't be accessed from other modules. One way to solve this is to define a "config" module that exports the constants.

module book::config {
    const ITEM_PRICE: u64 = 100;
    const TAX_RATE: u64 = 10;
    const SHIPPING_COST: u64 = 5;

    /// Returns the price of an item.
    public fun item_price(): u64 { ITEM_PRICE }
    /// Returns the tax rate.
    public fun tax_rate(): u64 { TAX_RATE }
    /// Returns the shipping cost.
    public fun shipping_cost(): u64 { SHIPPING_COST }
}
This way other modules can import and read the constants, and the update process is simplified. If the constants need to be changed, only the config module needs to be updated during the package upgrade.

Links
Constants in the Move Language Reference.
Coding conventions for constants.
