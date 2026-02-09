# Test Scenario

The `test_scenario` module from the [Sui Framework](./../programmability/sui-framework.md) provides
a way to simulate multi-transaction scenarios in tests. It maintains a view of the global object
pool and allows you to test how objects are created, transferred, and accessed across multiple
transactions.

```move
#[test_only]
use sui::test_scenario;
```

## Starting and Ending a Scenario

A test scenario begins with `test_scenario::begin` which takes the sender address as an argument.
The scenario must be ended with `test_scenario::end` to clean up resources. Failing to end a
scenario will result in a compilation error.

> **Note:** there should be only one scenario per test. Creating multiple scenarios in the same test
> may produce unexpected results and should be avoided.

```move
use sui::test_scenario;

#[test]
fun test_basic_scenario() {
    let alice = @0xA;

    // Start a scenario with alice as the sender
    let mut scenario = test_scenario::begin(alice);

    // ... perform operations ...

    // End the scenario - returns TransactionEffects
    scenario.end();
}
```

## Transaction Simulation

Use `next_tx` to advance to a new transaction with a specified sender. Objects transferred in the
previous transaction become available in the next one. Each `next_tx` call returns
[`TransactionEffects`](#reading-transaction-effects) containing information about what happened in
the previous transaction.

```move
use sui::test_scenario;

#[test]
fun test_multi_transaction() {
    let alice = @0xA;
    let bob = @0xB;

    let mut scenario = test_scenario::begin(alice);

    // First transaction: alice creates an object
    // Objects created here are not yet in anyone's inventory

    // Advance to second transaction with bob as sender
    // Objects from the first transaction are now available
    let _effects = scenario.next_tx(bob);

    // ... bob can now access objects transferred to him ...

    scenario.end();
}
```

> Important: Objects transferred during a transaction are only available after calling `next_tx`.
> You cannot access an object in the same transaction where it was transferred.

## Accessing Owned Objects

[Owned objects](./../object/ownership.md#owned-by-an-address) transferred to an address can be
accessed using `take_from_sender` or `take_from_address`. The object then can be passed to a
function, returned with `return_to_sender` or `return_to_address`, or transferred elsewhere using
`public_transfer` (if the object has `store` ability).

```move
module book::test_scenario_example;

public struct Item has key, store {
    id: UID,
    value: u64,
}

public fun create(value: u64, ctx: &mut TxContext): Item {
    Item { id: object::new(ctx), value }
}

public fun value(item: &Item): u64 { item.value }

#[test]
fun test_take_and_return() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // Transaction 1: Create and transfer an item to alice
    {
        let item = create(100, scenario.ctx());
        transfer::public_transfer(item, alice);
    };

    // Transaction 2: Alice takes the item
    scenario.next_tx(alice);
    {
        // Take the most recent Item from sender's inventory
        let item = scenario.take_from_sender<Item>();
        assert_eq!(item.value(), 100);

        // Return the item to sender's inventory
        scenario.return_to_sender(item);
    };

    scenario.end();
}
```

### Taking by ID

When multiple objects of the same type exist, use `take_from_sender_by_id` or
`take_from_address_by_id` to take a specific one:

```move
#[test]
fun test_take_by_id() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // Create two items
    let item1 = create(100, scenario.ctx());
    let item2 = create(200, scenario.ctx());
    let id1 = object::id(&item1);

    transfer::public_transfer(item1, alice);
    transfer::public_transfer(item2, alice);

    scenario.next_tx(alice);
    {
        // Take the specific item by ID
        let item = scenario.take_from_sender_by_id<Item>(id1);
        assert_eq!(item.value(), 100);
        scenario.return_to_sender(item);
    };

    scenario.end();
}
```

### Checking Object Availability

Before taking an object, you can check if one exists:

```move
#[test]
fun test_has_object() {
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // No items exist yet
    assert!(!scenario.has_most_recent_for_sender<Item>());

    let item = create(100, scenario.ctx());
    transfer::public_transfer(item, alice);

    scenario.next_tx(alice);

    // Now an item exists
    assert!(scenario.has_most_recent_for_sender<Item>());

    scenario.end();
}
```

## Accessing Shared Objects

[Shared objects](./../object/ownership.md#shared-state) are accessed using `take_shared` and must be
returned with `return_shared`:

```move
module book::shared_counter;

public struct Counter has key {
    id: UID,
    value: u64,
}

public fun create(ctx: &mut TxContext) {
    transfer::share_object(Counter {
        id: object::new(ctx),
        value: 0,
    })
}

public fun increment(counter: &mut Counter) {
    counter.value = counter.value + 1;
}

public fun value(counter: &Counter): u64 { counter.value }

#[test]
fun test_shared_object() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let bob = @0xB;

    let mut scenario = test_scenario::begin(alice);

    // Alice creates a shared counter
    create(scenario.ctx());

    // Bob increments it
    scenario.next_tx(bob);
    {
        let mut counter = scenario.take_shared<Counter>();
        counter.increment();
        assert_eq!(counter.value(), 1);
        test_scenario::return_shared(counter);
    };

    // Alice increments it again
    scenario.next_tx(alice);
    {
        let mut counter = scenario.take_shared<Counter>();
        counter.increment();
        assert_eq!(counter.value(), 2);
        test_scenario::return_shared(counter);
    };

    scenario.end();
}
```

### The `with_shared` Macro

For cleaner code, use the `with_shared!` macro which handles take and return automatically:

```move
#[test]
fun test_with_shared_macro() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    create(scenario.ctx());
    scenario.next_tx(alice);

    scenario.with_shared!<Counter>(|counter, _scenario| {
        counter.increment();
        assert_eq!(counter.value(), 1);
    });

    scenario.end();
}
```

## Accessing Immutable Objects

[Immutable (frozen) objects](./../object/ownership.md#immutable-frozen-object) are accessed with
`take_immutable` and returned with `return_immutable`:

```move
module book::immutable_config;

public struct Config has key {
    id: UID,
    max_value: u64,
}

public fun create(max_value: u64, ctx: &mut TxContext) {
    transfer::freeze_object(Config {
        id: object::new(ctx),
        max_value,
    })
}

public fun max_value(config: &Config): u64 { config.max_value }

#[test]
fun test_immutable_object() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // Create an immutable config
    create(1000, scenario.ctx());

    scenario.next_tx(alice);
    {
        // Take the immutable object
        let config = scenario.take_immutable<Config>();
        assert_eq!(config.max_value(), 1000);

        // Return it to the global inventory
        test_scenario::return_immutable(config);
    };

    scenario.end();
}
```

## Accessing Transaction Context

The `ctx` method provides access to the [`TxContext`](./../programmability/transaction-context.md)
for the current transaction. Use it when calling functions that require a context:

```move
#[test]
fun test_context_access() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // Access the transaction context
    let ctx = scenario.ctx();

    // Use it for operations that need context
    let item = create(100, ctx);
    transfer::public_transfer(item, alice);

    // The sender matches what we passed to begin()
    assert_eq!(ctx.sender(), alice);

    scenario.end();
}
```

## Reading Transaction Effects

Both `next_tx` and `end` return `TransactionEffects` which contains information about what happened
during the transaction:

```move
#[test]
fun test_transaction_effects() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let bob = @0xB;
    let mut scenario = test_scenario::begin(alice);

    // Create objects in first transaction
    let item1 = create(100, scenario.ctx());
    let item2 = create(200, scenario.ctx());
    transfer::public_transfer(item1, alice);
    transfer::public_transfer(item2, bob);

    // Get effects from the first transaction
    let effects = scenario.next_tx(alice);

    // Check what was created
    assert_eq!(effects.created().length(), 2);

    // Check transfers to accounts
    assert_eq!(effects.transferred_to_account().size(), 2);

    // Check number of events emitted
    assert_eq!(effects.num_user_events(), 0);

    scenario.end();
}
```

### Available Effect Fields

| Method                     | Returns               | Description                          |
| -------------------------- | --------------------- | ------------------------------------ |
| `created()`                | `vector<ID>`          | Objects created in this transaction  |
| `written()`                | `vector<ID>`          | Objects modified in this transaction |
| `deleted()`                | `vector<ID>`          | Objects deleted in this transaction  |
| `transferred_to_account()` | `VecMap<ID, address>` | Objects transferred to addresses     |
| `transferred_to_object()`  | `VecMap<ID, ID>`      | Objects transferred to other objects |
| `shared()`                 | `vector<ID>`          | Objects shared in this transaction   |
| `frozen()`                 | `vector<ID>`          | Objects frozen in this transaction   |
| `num_user_events()`        | `u64`                 | Number of events emitted             |

## System Objects

Use `create_system_objects` to make system objects like `Clock`, `Random`, and `DenyList` available
in tests. For more detailed coverage of testing with system objects, see
[Using System Objects](./using-system-objects.md).

```move
use sui::clock::Clock;

#[test]
fun test_with_clock() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // Create system objects (Clock, Random, DenyList)
    scenario.create_system_objects();

    scenario.next_tx(alice);
    {
        // Now Clock is available as a shared object
        let clock = scenario.take_shared<Clock>();
        assert_eq!(clock.timestamp_ms(), 0);
        test_scenario::return_shared(clock);
    };

    scenario.end();
}
```

## Epoch and Time Manipulation

Test [time-dependent logic](./../programmability/epoch-and-time.md) using `next_epoch` and
`later_epoch`:

```move
#[test]
fun test_epoch_advancement() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let alice = @0xA;
    let mut scenario = test_scenario::begin(alice);

    // Check initial epoch
    assert_eq!(scenario.ctx().epoch(), 0);

    // Advance to next epoch
    scenario.next_epoch(alice);
    assert_eq!(scenario.ctx().epoch(), 1);

    // Advance epoch and time together (1000ms = 1 second)
    scenario.later_epoch(1000, alice);
    assert_eq!(scenario.ctx().epoch(), 2);
    assert_eq!(scenario.ctx().epoch_timestamp_ms(), 1000);

    scenario.end();
}
```

## Complete Example

Here's a complete example testing a simple token transfer flow:

```move
module book::simple_token;

public struct Token has key, store {
    id: UID,
    amount: u64,
}

public fun mint(amount: u64, ctx: &mut TxContext): Token {
    Token { id: object::new(ctx), amount }
}

public fun amount(token: &Token): u64 { token.amount }

#[test]
fun test_token_transfer_flow() {
    use std::unit_test::assert_eq;
    use sui::test_scenario;

    let admin = @0xAD;
    let alice = @0xA;
    let bob = @0xB;

    // Start scenario as admin
    let mut scenario = test_scenario::begin(admin);

    // Admin mints tokens for alice
    {
        let token = mint(1000, scenario.ctx());
        transfer::public_transfer(token, alice);
    };

    // Alice receives and transfers to bob
    scenario.next_tx(alice);
    {
        assert!(scenario.has_most_recent_for_sender<Token>());
        let token = scenario.take_from_sender<Token>();
        assert_eq!(token.amount(), 1000);
        transfer::public_transfer(token, bob);
    };

    // Bob receives the token
    scenario.next_tx(bob);
    {
        let token = scenario.take_from_sender<Token>();
        assert_eq!(token.amount(), 1000);
        scenario.return_to_sender(token);
    };

    // Verify final state via effects
    let effects = scenario.end();
    assert_eq!(effects.transferred_to_account().size(), 0); // No transfers in final tx
}
```

## Summary

| Function                    | Purpose                                |
| --------------------------- | -------------------------------------- |
| `begin(sender)`             | Start a new scenario                   |
| `end(scenario)`             | End the scenario and get final effects |
| `next_tx(scenario, sender)` | Advance to next transaction            |
| `ctx(scenario)`             | Get mutable reference to `TxContext`   |
| `take_from_sender<T>`       | Take owned object from sender          |
| `return_to_sender(obj)`     | Return object to sender                |
| `take_shared<T>`            | Take shared object                     |
| `return_shared(obj)`        | Return shared object                   |
| `take_immutable<T>`         | Take immutable object                  |
| `return_immutable(obj)`     | Return immutable object                |
| `create_system_objects`     | Create Clock, Random, DenyList         |
| `next_epoch`                | Advance to next epoch                  |
| `later_epoch(ms, sender)`   | Advance epoch and time                 |

## Further Reading

- [Using System Objects](./using-system-objects.md) - Creating and manipulating Clock, Random,
  DenyList, Coin, and Balance in tests
- [Test Utilities](./test-utilities.md) - `assert_eq!`, `destroy`, and other testing helpers
- [Transaction Context](./../programmability/transaction-context.md) - Understanding `TxContext` and
  its fields
- [Object Ownership](./../object/ownership.md) - How owned, shared, and immutable objects work
- [Epoch and Time](./../programmability/epoch-and-time.md) - Working with time in Sui
