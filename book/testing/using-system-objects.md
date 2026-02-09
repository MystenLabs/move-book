---
description: "Use system objects in Move tests: create and manipulate Clock, Random, and DenyList for testing time, randomness, and deny lists."
---

# Creating and Using System Objects in Tests

Some tests require system objects like `Clock`, `Random`, or `DenyList`. These objects have
[fixed addresses](./../appendix/reserved-addresses.md) on the network and are created during
genesis. In tests, they don't exist by default, so the Sui Framework provides `#[test_only]`
functions to create and manipulate them.

## Clock

The [`Clock`](./../programmability/epoch-and-time.md#clock) provides the current network timestamp.
Use `clock::create_for_testing` to create one, and manipulate time with test-only functions:

```move
use std::unit_test::assert_eq;
use sui::clock;

#[test]
fun test_clock() {
    let ctx = &mut tx_context::dummy();
    let mut clock = clock::create_for_testing(ctx);

    // Starts at 0
    assert_eq!(clock.timestamp_ms(), 0);

    // Add time (in milliseconds)
    clock.increment_for_testing(1000);
    assert_eq!(clock.timestamp_ms(), 1000);

    // Set absolute time (must be >= current)
    clock.set_for_testing(5000);
    assert_eq!(clock.timestamp_ms(), 5000);

    // Clean up - Clock doesn't have `drop`
    clock.destroy_for_testing();
}
```

To share a `Clock` for use in a test scenario, call `share_for_testing`:

```move
#[test]
fun test_shared_clock() {
    let ctx = &mut tx_context::dummy();
    let clock = clock::create_for_testing(ctx);
    clock.share_for_testing();
}
```

## Random

The `Random` object provides on-chain randomness. In tests, the full `Random` shared object can only
be created inside a [test scenario](./test-scenario.md) via `random::create_for_testing`. However,
the preferred approach is to structure your code so that the core logic takes a `RandomGenerator`
parameter - this lets you create a generator directly in unit tests with
`random::new_generator_for_testing()`, bypassing the `Random` object entirely. This is easier to
work with because `Random` requires an `entry` function (which cannot return non-droppable values),
making it harder to assert on results.

```move
use sui::random::{Self, Random, RandomGenerator};

// To use Random, a function must have `entry` modifier, hence it cannot return
// a value, and not so easy to test.
entry fun my_entry_function(r: &Random, ctx: &mut TxContext) {
    let mut gen = random::new_generator(r, ctx);
    let result = inner_function(&mut gen);
    result.destroy_or!(abort);
}

// Example of an inner function that is easier to test than the entry point.
public(package) fun inner_function(gen: &mut RandomGenerator): Option<u64> {
    if (gen.generate_bool()) {
        option::some(gen.generate_u64())
    } else {
        option::none()
    }
}

#[test]
fun test_simple_random() {
    // Deterministic, always the same value.
    let mut gen = random::new_generator_for_testing();
    assert!(inner_function(&mut gen).is_none());

    // Deterministic (reproducible with same seed)
    let seed = b"Arbitrary seed bytes";
    let mut gen = random::new_generator_from_seed_for_testing(seed);
    assert!(inner_function(&mut gen).is_some());
}
```

For entry points that take the full `Random` shared object (the only possible way is to take it as a
reference `&Random`), use a [test scenario](./test-scenario.md):

```move
use sui::random::{Self, Random};
use sui::test_scenario;

#[test]
fun test_random_shared() {
    let mut scenario = test_scenario::begin(@0x0);

    // Create and share Random
    random::create_for_testing(scenario.ctx());
    scenario.next_tx(@0x0);

    let mut random = scenario.take_shared<Random>();

    // Initialize with seed bytes (required before use)
    random.update_randomness_state_for_testing(
        0,
        x"1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F",
        scenario.ctx(),
    );

    my_entry_function(&random, scenario.ctx());

    test_scenario::return_shared(random);
    scenario.end();
}
```

## DenyList

The `DenyList` is used by regulated coins to block specific addresses. Create a local instance with
`new_for_testing`, or a shared one with `create_for_testing`:

```move
use sui::deny_list;
use sui::test_scenario;
use std::unit_test::destroy;

#[test]
fun test_deny_list() {
    let mut scenario = test_scenario::begin(@0x0);

    // Create a local instance for simple tests
    let deny_list = deny_list::new_for_testing(scenario.ctx());
    // ... use deny_list
    destroy(deny_list);

    // Or create a shared DenyList
    deny_list::create_for_testing(scenario.ctx());
    scenario.next_tx(@0x0);
    // ... take_shared and use

    scenario.end();
}
```

## Coin and Balance

For testing with coins, use `coin::mint_for_testing` and `balance::create_for_testing`:

```move
use std::unit_test::assert_eq;
use sui::coin;
use sui::balance;
use sui::sui::SUI;

#[test]
fun test_coins() {
    let ctx = &mut tx_context::dummy();

    // Create a coin of any type
    let coin = coin::mint_for_testing<SUI>(1000, ctx);
    assert_eq!(coin.value(), 1000);

    // Destroy and get the value back
    let value = coin.burn_for_testing();
    assert_eq!(value, 1000);

    // Create a balance directly
    let balance = balance::create_for_testing<SUI>(500);
    let value = balance.destroy_for_testing();
    assert_eq!(value, 500);
}
```

## Create All System Objects at Once

When using [Test Scenario](./test-scenario.md), you can create all system objects at once with
`create_system_objects`. This creates and shares `Clock`, `Random`, and `DenyList`:

```move
use sui::clock::Clock;
use sui::random::Random;
use sui::deny_list::DenyList;
use sui::test_scenario;

#[test]
fun test_with_all_system_objects() {
    let mut scenario = test_scenario::begin(@0xA);

    // Creates Clock, Random, and DenyList as shared objects
    scenario.create_system_objects();
    scenario.next_tx(@0xA);

    // Take objects by type
    let clock = scenario.take_shared<Clock>();
    let random = scenario.take_shared<Random>();
    let deny_list = scenario.take_shared<DenyList>();

    // ... use the objects

    // Return them when done
    test_scenario::return_shared(clock);
    test_scenario::return_shared(random);
    test_scenario::return_shared(deny_list);

    scenario.end();
}
```

> System objects created in tests won't have the same fixed addresses they have on a live network.
> Use `take_shared<T>()` to access them by type rather than by ID.

To take a specific shared object by ID, use `take_shared_by_id`:

```move
use sui::test_scenario::{Self, most_recent_id_shared};

#[test]
fun test_take_by_id() {
    let mut scenario = test_scenario::begin(@0xA);
    scenario.create_system_objects();
    scenario.next_tx(@0xA);

    // Get the ID of the most recent shared Clock
    let clock_id = most_recent_id_shared<Clock>().destroy_some();

    // Take by ID
    let clock = scenario.take_shared_by_id<Clock>(clock_id);
    // ...
    test_scenario::return_shared(clock);

    scenario.end();
}
```

## Summary

| Object             | Creation                                | Test-only Features                         |
| ------------------ | --------------------------------------- | ------------------------------------------ |
| `Clock`            | `clock::create_for_testing(ctx)`        | `increment_for_testing`, `set_for_testing` |
| `Random`           | `random::create_for_testing(ctx)`       | `update_randomness_state_for_testing`      |
| `RandomGenerator`  | `random::new_generator_for_testing()`   | `new_generator_from_seed_for_testing`      |
| `DenyList`         | `deny_list::create_for_testing(ctx)`    | `new_for_testing`                          |
| `Coin<T>`          | `coin::mint_for_testing<T>(value, ctx)` | `burn_for_testing`                         |
| `Balance<T>`       | `balance::create_for_testing<T>(value)` | `destroy_for_testing`                      |
| All system objects | `scenario.create_system_objects()`      | Creates Clock, Random, DenyList            |
