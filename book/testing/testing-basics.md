---
description: "Move testing basics: write tests with the #[test] attribute, use expected failures, and organize test-only code in your modules."
---

# Testing Basics

The Move compiler has a built-in testing framework - tests are written in Move and live alongside
your source code. You annotate functions with `#[test]`, and the compiler handles discovery and
execution. The VM execution environment is the same as in production, so your code runs with
identical semantics. However, network and storage features are simulated in tests and don't behave
exactly as they do during actual on-chain execution - something to keep in mind when testing
interactions with objects, transactions, and other platform-specific functionality.

## What is a Test?

A test is a function annotated with the `#[test]` attribute. Tests cannot take arguments and should
not return a value. Test functions are automatically detected and executed when running the test
command. If a test function [aborts](./../move-basics/assert-and-abort.md) unexpectedly, the test
fails.

```move
module book::my_module;

#[test]
fun test_addition() {
    assert!(2 + 2 == 4);
}

#[test]
fun test_that_aborts() {
    abort // This test will FAIL - unexpected abort
}

#[test, expected_failure]
fun test_expected_abort() {
    abort // This test will PASS - abort was expected
}
```

## Running Tests

To run tests, use the `sui move test` command. The compiler builds the package in _test mode_ and
runs all tests found in the package.

```bash
sui move test
```

Example output:

```
Running Move unit tests
[ PASS    ] book::my_module::test_addition
[ FAIL    ] book::my_module::test_that_aborts
[ PASS    ] book::my_module::test_expected_abort
Test result: FAILED. Total tests: 3; passed: 2; failed: 1
```

## Filtering Tests

Run specific tests by providing a filter string. Only tests whose fully qualified name contains the
filter will run:

```bash
# Run tests containing "addition" in the name
sui move test addition

# Run all tests in a specific module
sui move test my_module

# Run a specific test
sui move test book::my_module::test_addition
```

## Expected Failures

Use `#[expected_failure]` to test that code aborts under certain conditions. The test passes only if
it aborts; if it completes normally, the test fails.

### Basic Expected Failure

```move
#[test, expected_failure]
fun test_division_by_zero() {
    let _ = 1 / 0; // Aborts - test passes
}
```

### Expected Abort Code

Specify the expected abort code to ensure the function fails for the right reason:

```move
module book::errors;

const EInvalidInput: u64 = 1;
const ENotFound: u64 = 2;

public fun validate(x: u64) {
    assert!(x > 0, EInvalidInput);
}

#[test, expected_failure(abort_code = EInvalidInput)]
fun test_validate_zero_fails() {
    validate(0); // Aborts with EInvalidInput - test passes
}

#[test, expected_failure(abort_code = ENotFound)]
fun test_wrong_error_code() {
    validate(0); // Aborts with EInvalidInput, not ENotFound - test FAILS
}
```

### Expected Location

Specify where the abort should occur using `location`:

```move
#[test, expected_failure(abort_code = EInvalidInput, location = book::errors)]
fun test_abort_location() {
    validate(0);
}

// Use `location = Self` for aborts in the current module
#[test, expected_failure(abort_code = 1, location = Self)]
fun test_abort_in_self() {
    abort 1
}
```

## Test-Only Code

Code marked with `#[test_only]` is compiled only in test mode. Use it for test utilities, helper
functions, or imports that shouldn't exist in production code. It is common for `#[test_only]`
functions to have `public` or `public(package)` visibility so they can be called from tests in other
modules - since test-only code is stripped from production builds, this does not affect the public
API of your package.

> Note: a good rule of thumb is to add `_for_testing` suffix to test-only functions and constants.
> This helps distinguish them from production code and makes it easier to find them in the codebase.
> Given that test-only functions often do things that production code cannot, this is a good way to
> ensure that you are not accidentally using a test-only function in production code.

### Test-Only Imports

```move
#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_with_assert_eq() {
    assert_eq!(2 + 2, 4);
}
```

### Test-Only Functions

```move
#[test_only]
fun setup_test_data(): vector<u64> {
    vector[1, 2, 3, 4, 5]
}

#[test]
fun test_sum() {
    let data = setup_test_data();
    let mut sum = 0;
    data.do!(|x| sum = sum + x);
    assert!(sum == 15);
}
```

### Test-Only Constants

```move
#[test_only]
const TEST_ADDRESS: address = @0xCAFE;
```

### Test-Only Modules

An entire module can be test-only:

```move
#[test_only]
module book::test_helpers;

public fun create_test_scenario(): u64 { 42 }
```

## Useful CLI Options

| Option                 | Description                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------- |
| `<filter>`             | Run only tests matching the filter (positional argument)                                |
| `--coverage`           | Collect coverage information (see [Coverage](./coverage.md))                            |
| `--trace`              | Generate traces for coverage LCOV output                                                |
| `--statistics`         | Show execution statistics including gas usage (see [Gas Profiling](./gas-profiling.md)) |
| `--threads <n>`        | Number of threads for parallel test execution                                           |
| `--rand-num-iters <n>` | Number of iterations for [random tests](./random-test.md)                               |
| `--seed <n>`           | Seed for reproducible random test runs                                                  |

## Test Output

When a test fails, the output shows:

- The test name and FAIL status
- The abort code (if any)
- The location where the failure occurred
- A stack trace for debugging

```table
┌── test_that_failed ──────
│ error[E11001]: test failure
│    ┌─ ./sources/module.move:15:9
│    │
│ 15 │         assert!(balance == 100);
│    │         ^^^^^^^^^^^^^^^^^^^^^^^ Test was not expected to error, but it
│    │         aborted with code 1 originating in the module 0x0::module
│
└──────────────────
```

## Next Steps

In the next sections you will learn how to write good tests, how to use test utilities, how to test
transactions and how to master the testing framework.
