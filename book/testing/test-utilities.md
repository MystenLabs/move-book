# Unit Test Utilities

In addition to the built-in `assert!` macro, the
[Standard Library](./../move-basics/standard-library.md) provides common utilities for testing. The
most important ones are defined in the [`std::unit_test`][stdlib-unit-test] module. While not a
requirement, it is recommended to use this module in tests.

## `assert!`

The `assert!` macro is a built-in language feature and the most basic tool for verifying conditions
in tests. It takes a boolean expression and aborts if the expression evaluates to `false`. For a
detailed explanation of assertions and error handling, see
[Aborting Execution](./../move-basics/assert-and-abort.md).

```move
#[test]
fun test_addition() {
    let sum = 2 + 2;
    assert!(sum == 4);
}
```

In published code, `assert!` should normally have an abort code as the second argument to help
identify failures. However, in tests, the abort code is not necessary and doesn't provide any value.

```move
// In published code - abort code required
assert!(balance >= amount, EInsufficientBalance);

// In test code - abort code optional
assert!(balance >= amount);
```

## `assert_eq!` and `assert_ref_eq!`

While `assert!` works, it has a limitation: when it fails, it only shows that the condition was
false, not giving any insight into the actual values that caused the failure. Consider this test:

```move
#[test]
fun test_balance_update() {
    let balance = calculate_balance();
    assert!(balance == 1000); // does not print compared values on failure
}
```

If this test fails, you only know that the assertion failed - not what `balance` actually was. You
would need to add debug statements or investigate further to understand the failure.

The `assert_eq!` macro from `std::unit_test` solves this by printing both values when the assertion
fails:

```move
use std::unit_test::assert_eq;

#[test]
fun test_balance_update() {
    let balance = calculate_balance();
    assert_eq!(balance, 1000); // fails with: "Assertion failed: 750 != 1000"
}
```

Now the error message shows the actual value (`750`) and the expected value (`1000`), making it
immediately clear what went wrong. This debug output works because `assert_eq!` calls the
[`std::debug::print`](./../move-basics/standard-library.md) function, which prints the values if the
assertion fails.

To compare by reference, use `assert_ref_eq!` instead of `assert_eq!`:

```move
use std::unit_test::assert_ref_eq;

#[test]
fun test_reference_equality() {
    let user = get_user();
    let expected = create_expected_user();
    assert_ref_eq!(&user, &expected);
}
```

## Black Hole Function: `destroy`

The `destroy` function consumes any value, regardless of its abilities. This is essential for
testing types that don't have the `drop` ability - without it, cleanup would require additional
logic implemented for each type.

```move
module std::unit_test;

/// Consumes any value `T` and makes it disappear.
public native fun destroy<T>(v: T);
```

Consider a type without `drop`:

```move
module book::ticket;

/// A ticket is an Object - doesn't have `drop`.
public struct Ticket has key, store {
    id: UID,
    event_id: u64,
    seat: u64,
}

public fun new(event_id: u64, seat: u64, ctx: &mut TxContext): Ticket {
    Ticket { id: object::new(ctx), event_id, seat }
}
```

In published code, `Ticket` type may not have a deletion function or require a condition to be met
before deletion. In this case, `destroy` is the best way to deal with the value:

```move
use std::unit_test;

#[test]
fun test_ticket_creation() {
    let ctx = &mut tx_context::dummy();
    let ticket = ticket::new(1, 42, ctx);

    // Test passes - but how do we get rid of `ticket`?

    unit_test::destroy(ticket); // Consumes the ticket
}
```

The `destroy` function acts as a "black hole" - it accepts any type and makes it disappear. This
lets you focus tests on specific functionality without being forced to handle cleanup logic that
isn't relevant to what you're testing.

> The `destroy` function is only available in test code. It cannot be used in production modules.

In the next sections, we will cover Sui-specific testing utilities and features.

[stdlib-unit-test]:
  https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/move-stdlib/sources/unit_test.move
