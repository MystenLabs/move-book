# What Makes a Good Test

Writing tests is one thing; writing _good_ tests is another. A test suite that merely exists provides
false confidence if it doesn't actually catch bugs or help you understand your code. This section
covers the principles and practices that distinguish effective tests from superficial ones.

## Characteristics of Good Tests

### 1. Tests Should Be Independent

Each test should run in isolation without depending on the state left by other tests. In Move, each
test function starts with a fresh state, which helps enforce this naturally. However, you should
still avoid designing tests that assume a particular execution order.

### 2. Tests Should Be Fast

Slow tests discourage frequent testing. While some integration tests may take longer, most unit
tests should execute in milliseconds. A fast test suite encourages developers to run tests often
and catch issues early.

### 3. Tests Should Be Readable

Tests serve as documentation for your code's expected behavior. Anyone reading a test should quickly
understand what scenario is being tested and what the expected outcome is.

```move
#[test]
fun test_add_increases_balance_by_specified_amount() {
    // Arrange: set up initial state
    let mut balance = balance::new(100);

    // Act: perform the operation being tested
    balance.add(50);

    // Assert: verify the expected outcome
    assert_eq!(balance.value(), 150);
}
```

### 4. Tests Should Test One Thing

Each test should verify a single behavior or scenario. When a test fails, you should immediately
know what went wrong. Tests that verify multiple unrelated behaviors make debugging harder.

```move
module book::single_responsibility;

public struct Counter has copy, drop { value: u64 }

public fun increment(c: &mut Counter) { c.value = c.value + 1; }
public fun decrement(c: &mut Counter) { c.value = c.value - 1; }

// Good: separate tests for each behavior
#[test]
fun test_increment_adds_one() {
    let mut counter = Counter { value: 0 };
    increment(&mut counter);
    assert!(counter.value == 1);
}

#[test]
fun test_decrement_subtracts_one() {
    let mut counter = Counter { value: 1 };
    decrement(&mut counter);
    assert!(counter.value == 0);
}
```

## What to Test

### Test the Contract, Not the Implementation

Focus on testing the observable behavior of your functions - what they return and what side effects
they produce - rather than how they achieve it internally. This allows you to refactor
implementations without breaking tests.

### Test Edge Cases

Edge cases are where bugs often hide. For numeric operations, consider:

- Zero values
- Maximum values (`U64_MAX`, `U128_MAX`)
- Boundary conditions (off-by-one errors)
- Empty collections

```move
module book::edge_cases;

public fun safe_divide(a: u64, b: u64): u64 {
    if (b == 0) return 0;
    a / b
}

#[test]
fun test_divide_normal_case() {
    assert!(safe_divide(10, 2) == 5);
}

#[test]
fun test_divide_by_zero_returns_zero() {
    assert!(safe_divide(10, 0) == 0);
}

#[test]
fun test_divide_zero_by_nonzero() {
    assert!(safe_divide(0, 5) == 0);
}
```

### Test Error Conditions

Verify that your code fails appropriately when given invalid inputs. Use `#[expected_failure]` to
test that functions abort with the correct error codes.

```move
module book::error_conditions;

const EInsufficientBalance: u64 = 1;

public struct Wallet has copy, drop { balance: u64 }

public fun withdraw(wallet: &mut Wallet, amount: u64) {
    assert!(wallet.balance >= amount, EInsufficientBalance);
    wallet.balance = wallet.balance - amount;
}

#[test]
fun test_withdraw_succeeds_with_sufficient_balance() {
    let mut wallet = Wallet { balance: 100 };
    withdraw(&mut wallet, 50);
    assert!(wallet.balance == 50);
}

#[test, expected_failure(abort_code = EInsufficientBalance)]
fun test_withdraw_fails_with_insufficient_balance() {
    let mut wallet = Wallet { balance: 50 };
    withdraw(&mut wallet, 100);
}
```

### Aim for Good Coverage, but Don't Chase Numbers

High test coverage is a positive indicator - it means more of your code is exercised during testing,
increasing the chance of catching bugs. Reaching good coverage demonstrates that you've thought
through various code paths and scenarios.

However, coverage should not be the primary goal of writing tests. A test suite with 100% coverage
can still miss critical bugs if the tests don't verify meaningful behavior. Tests that exist solely
to increase coverage metrics - without asserting anything useful - provide false confidence.

Write tests to verify behavior and catch bugs. Good coverage should be a natural outcome of
thorough testing, not an end in itself. For more information on measuring and interpreting coverage,
see [Coverage Reports](./coverage.md).

## Test Organization

### Use Descriptive Names

Test names should describe the scenario being tested and the expected outcome. A good naming
convention is `test_<function>_<scenario>_<expected_result>` or simply a description of the
behavior.

### Group Related Tests

Organize tests logically, either by the function they test or by the feature they verify. In Move,
you can place tests in the same module as the code they test, or in separate test modules.

## The Testing Pyramid

A well-balanced test suite typically follows the testing pyramid:

1. **Unit tests** (base): Many small, fast tests that verify individual functions in isolation
2. **Integration tests** (middle): Fewer tests that verify how components work together
3. **End-to-end tests** (top): Few tests that verify complete user scenarios

In Move, unit tests are written using the `#[test]` attribute, while integration tests often use
[Test Scenario](./test-scenario.md) to simulate multi-transaction workflows.

## Common Testing Mistakes

### Testing Only the Happy Path

Don't just test that code works when everything goes right. Test what happens when things go wrong -
invalid inputs, edge cases, and error conditions.

### Writing Tests After the Fact

Tests written as an afterthought often just verify that code does what it already does, rather than
what it should do. Consider writing tests alongside or before implementation to clarify
requirements.

### Over-Mocking

While isolation is important, over-mocking can lead to tests that pass even when the real
integration would fail. Balance unit tests with integration tests that use real components.

### Ignoring Test Maintenance

Tests are code too. Keep them clean, remove obsolete tests, and update them when requirements
change. A neglected test suite becomes a liability rather than an asset.
