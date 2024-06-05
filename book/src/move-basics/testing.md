# Testing

A crucial part of any software development, and even more - blockchain development, is testing.
Here, we will cover the basics of testing in Move and how to write and organize tests for your Move
code.

## The `#[test]` attribute

Tests in Move are functions marked with the `#[test]` attribute. This attribute tells the compiler
that the function is a test function, and it should be run when the tests are executed. Test
functions are regular functions, but they must take no arguments and have no return value. They
are excluded from the bytecode, and are never published.

```move
module book::testing {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test]
    fun simple_test() {
        let sum = 2 + 2;
        assert!(sum == 4, 1);
    }

    // The name of the test would be `book::testing::more_advanced_test`.
    #[test] fun more_advanced_test() {
        let sum = 2 + 2 + 2;
        assert!(sum == 4, 1);
    }
}
```

## Running Tests

To run tests, you can use the `sui move test` command. This command will first build the package in
the _test mode_ and then run all the tests found in the package. During test mode, modules from both
`sources/` and `tests/` directories are processed, and the tests are executed.

```bash
$ sui move test
> INCLUDING DEPENDENCY Sui
> INCLUDING DEPENDENCY MoveStdlib
> BUILDING book
> Running Move unit tests
> ...
```

<!-- TODO: fill output -->

## Test Fail Cases with `#[expected_failure]`

Tests for fail cases can be marked with `#[expected_failure]`. This attribute placed on a `#[test]`
function tells the compiler that the test is expected to fail. This is useful when you want to test
that a function fails when a certain condition is met.

> This attribute can only be placed on a `#[test]` function.

The attribute can take an argument for abort code, which is the expected abort code when the test
fails. If the test fails with a different abort code, the test will fail. If the execution did not
abort, the test will also fail.

```move
module book::testing_failure {

    const EInvalidArgument: u64 = 1;

    #[test]
    #[expected_failure(abort_code = 0)]
    fun test_fail() {
        abort 0 // aborts with 0
    }

    // attributes can be grouped together
    #[test, expected_failure(abort_code = EInvalidArgument)]
    fun test_fail_1() {
        abort 1 // aborts with 1
    }
}
```

The `abort_code` argument can use constants defined in the tests module as well as imported from
other modules. This is the only case where constants can be used and "accessed" in other modules.

## Utilities with `#[test_only]`

In some cases, it is helpful to give the test environment access to some of the internal functions
or features. It simplifies the testing process and allows for more thorough testing. However, it is
important to remember that these functions should not be included in the final package. This is
where the `#[test_only]` attribute comes in handy.

```move
module book::testing {
    // Public function which uses the `secret` function.
    public fun multiply_by_secret(x: u64): u64 {
        x * secret()
    }

    /// Private function which is not available to the public.
    fun secret(): u64 { 100 }

    #[test_only]
    /// This function is only available for testing purposes in tests and other
    /// test-only functions. Mind the visibility - for `#[test_only]` it is
    /// common to use `public` visibility.
    public fun secret_for_testing(): u64 {
        secret()
    }

    #[test]
    // In the test environment we have access to the `secret_for_testing` function.
    fun test_multiply_by_secret() {
        let expected = secret_for_testing() * 2;
        assert!(multiply_by_secret(2) == expected, 1);
    }
}
```

Functions marked with the `#[test_only]` will be available to the test environment, and to the other
modules if their visibility is set so.

## Further Reading

- [Unit Testing](https://move-book.com/reference/unit-testing.html) in the Move Reference.
