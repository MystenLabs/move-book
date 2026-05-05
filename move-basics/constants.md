> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Constants

Constants are immutable values that are defined at the module level. They often serve as a way to
give names to static values that are used throughout a module. For example, if there's a default
price for a product, you might define a constant for it. Constants are stored in the module's
bytecode, and each time they are used, the value is copied.

```move
module book::shop_price;

use sui::{coin::Coin, sui::SUI};

/// Trying to purchase an item at an incorrect price.
const EWrongPrice: u64 = 0;

/// The price of an item in the shop.
const ITEM_PRICE: u64 = 100;
/// The owner of the shop, an address.
const SHOP_OWNER: address = @0xa11ce;

/// An item sold in the shop.
public struct Item {}

/// Purchase an item from the shop.
public fun purchase(coin: Coin<SUI>): Item {
    assert!(coin.value() == ITEM_PRICE, EWrongPrice);

    transfer::public_transfer(coin, SHOP_OWNER);

    Item {}
}
```

## Naming Convention

Constants must start with a capital letter - this is enforced at the compiler level. For constants
used as a value, the convention is to use all uppercase letters and underscores between words, which
makes constants stand out from other identifiers in the code. An exception is made for
[error constants](./assert-and-abort#error-constants), which are written in ECamelCase.

```move
/// Price of the item used at the shop.
const ITEM_PRICE: u64 = 100;

/// Error constant.
const EItemNotFound: u64 = 1;
```

## Constants are Immutable

Constants can't be changed and assigned new values. As part of the package bytecode, they are
inherently immutable.

```move
module book::immutable_constants;

const ITEM_PRICE: u64 = 100;

// emits an error
fun change_price() {
    ITEM_PRICE = 200;
}
```

## Using Config Pattern

A common use case for an application is to define a set of constants that are used throughout the
codebase. But due to constants being private to the module, they can't be accessed from other
modules. One way to solve this is to define a "config" module that exports the constants.

```move
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
```

This way other modules can import and read the constants, and the update process is simplified. If
the constants need to be changed, only the config module needs to be updated during the package
upgrade.

## Links

- [Constants](./../../reference/constants) in the Move Reference
- [Coding conventions for constants](./../guides/code-quality-checklist#regular-constant-are-all_caps)
