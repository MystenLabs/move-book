# Constants

<!--

Chapter: Basic Syntax
Goal: Introduce constants.
Notes:
    - constants are immutable
    - constants are private
    - start with a capital letter always
    - stored in the bytecode (but w/o a name)
    - mention standard for naming constants

Links:
    - next section (abort and assert)
    - coding conventions (constants)
    - constants (language reference)

 -->

Constants are immutable values that are defined at the module level. They often serve as a way to give names to values that are used throughout a module. For example, if there's a default price for a product, you might define a constant for it. Constants are *internal* to the module and can not be accessed from other modules.

```move
module book::shop_price {
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    /// The price of an item in the shop.
    const ITEM_PRICE: u64 = 100;

    /// An item sold in the shop.
    struct Item { /* ... */ }

    /// Purchase an item from the shop.
    public fun purchase(coin: Coin<SUI>): Item {
        assert!(coin.value() == ITEM_PRICE, 0);

        Item { /* ... */ }
    }
}
```

## Naming Convention

Constants are named using `UPPER_SNAKE_CASE`. This is a convention that is used throughout the Move codebase. It's a way to make constants stand out from other identifiers in the code. Move compiler will error if the first letter of a constant is not an uppercase letter.

## Constants are Immutable

Constants can't be changed and assigned new values. They are part of the package bytecode, and inherently immutable.

```move
module book::immutable_constants {
    const ITEM_PRICE: u64 = 100;

    // emits an error
    fun change_price() {
        ITEM_PRICE = 200;
    }
}
```
