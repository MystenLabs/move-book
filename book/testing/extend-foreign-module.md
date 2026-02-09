---
description: "Extend foreign modules in Move tests: add test-only functions to external packages for creating test data and mock objects."
---

# Extending Modules

When testing code that depends on external packages, you often need to create test data for types
defined in those packages. However, many libraries don't provide test utilities, leaving you unable
to construct the objects your tests require. Module extensions solve this problem by allowing you to
add test-only functions to foreign modules.

## The Problem

Consider an application that uses [Pyth Network](https://pyth.network/) for price feeds. Your code
depends on `PriceInfoObject` from the Pyth package to get asset prices:

```move
module app::trading;

use pyth::price_info::PriceInfoObject;
use pyth::price::{Self, Price};

/// Execute a trade using the current price from Pyth oracle
public fun execute_trade(/* ... */ price_info: &PriceInfoObject, amount: u64): u64 {
    let price = get_price(price_info);
    // ... trading logic using the price
    amount * price / 1_000_000
}

fun get_price(price_info: &PriceInfoObject): u64 {
    // Extract price from the oracle object
    // ...
    0 // placeholder
}
```

To test `execute_trade`, you need a `PriceInfoObject`. But Pyth's Sui implementation doesn't provide
a `create_price_info_for_testing` function - the only way to get a `PriceInfoObject` is through
actual oracle updates, which isn't practical in unit tests.

Without extensions, your options are limited:

- Skip testing price-dependent logic (dangerous)
- Fork and modify the Pyth package (maintenance burden)

## What is an Extension?

An extension allows you to add functions to an existing module - even one from a foreign package.
Extended functions have access to the module's private types and can create, read, or modify them.
This is expressed using the `extend` keyword:

```move
#[test_only]
extend module pyth::price_info;

// Now you can define functions that have access to
// pyth::price_info's private types and functions
```

Extensions are:

- **Additive only**: Extensions can only add new declarations; they cannot modify or remove existing
  items in the target module
- **Local to your package**: They don't affect downstream dependencies or the original package. Only
  extensions defined in the root package are applied - extensions in dependencies are ignored
- **Mode-restricted**: Extensions require a mode attribute, most commonly `#[test_only]` for testing
- **Powerful**: They have full access to the extended module's internals, as if the code were
  written directly in that module

## Solving the Pyth Problem

Here's how to create a test helper for `PriceInfoObject` using an extension. First, create an
extension file:

```move
// tests/extensions/pyth_price_info_ext.move
#[test_only]
extend module pyth::price_info;

public fun new_price_info_object_for_testing(
    price_info: PriceInfo,
    ctx: &mut TxContext,
): PriceInfoObject {
    PriceInfoObject {
        id: object::new(ctx),
        price_info,
    }
}
```

Now you can write proper unit tests:

```move
#[test_only]
module app::trading_tests;

use app::trading;
use pyth::price_info;
use std::unit_test::{Self, assert_eq};

#[test]
fun test_execute_trade_with_price() {
    let ctx = &mut tx_context::dummy();

    // Create test price data using our extension
    let price_info = price_info::new_price_info_object_for_testing(
        /* ... */
        ctx,
    );

    // Test the trading logic
    let result = trading::execute_trade(&price_info, 1000);
    assert_eq!(result, 50_000);

    // Clean up
    unit_test::destroy(price_info);
}
```

## Project Structure

It's good practice to organize extensions in a dedicated folder:

```
my_project/
├── sources/
│   └── trading.move
├── tests/
│   ├── extensions/
│   │   └── pyth_price_info_ext.move
│   └── trading_tests.move
└── Move.toml
```

This keeps test utilities separate from production code and makes it clear which modules have been
extended.

## Extending Your Own Modules

Extensions aren't limited to foreign packages - you can also extend modules in your own package.
This is useful for adding test helpers without cluttering your production code with `#[test_only]`
functions:

```move
#[test_only]
extend module app::trading;

/// Test helper to check internal state
public fun get_internal_value(/* ... */): u64 {
    // Access private fields for testing
}

#[test]
fun test_internal_invariant() {
    // Test can live alongside the helper in the extension
}
```

## Other Use Cases

Beyond oracle mocks, extensions are useful for:

- **Creating and destroying objects with private fields**: When a dependency doesn't expose
  constructors for its types
- **Exposing internal state through public accessors**: When you need to verify internal invariants
  in tests
- **Mocking behavior**: When you need to simulate specific states that are hard to reach normally
- **Testing error conditions**: When you need to create invalid states to test error handling

## Limitations

Extensions have important constraints to be aware of:

- **Mode attribute required**: Extensions must have a mode attribute like `#[test_only]`. When using
  `#[test_only]`, extensions only work when running `sui move test` and cannot be used in production
  builds.
- **Additive only**: You can only add new declarations (functions, types, constants, use
  statements). You cannot modify, override, or shadow existing items in the target module.
- **Root package only**: Only extensions defined in your root package are applied. If a dependency
  defines extensions, they are ignored in your build.
- **Edition compatibility**: Extension code is subject to the same edition features as the target
  module. If the target module uses an older edition, your extension code must be compatible with
  that edition.
- **Edition requirement**: Extensions require the `2024.alpha` edition or later. Ensure your
  `Move.toml` specifies a compatible edition.

## Further Reading

- [Module Extensions | Reference](./../../reference/extensions) - detailed specification of the
  extension syntax and semantics
- [Integrating Pyth in Sui](https://docs.pyth.network/price-feeds/core/use-real-time-data/pull-integration/sui)
- [App Examples: Oracles](https://docs.sui.io/guides/developer/app-examples/oracle)
