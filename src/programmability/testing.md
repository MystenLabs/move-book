# Testing

A crucial part of any software development, and even more - blockchain development, is testing. In this chapter, we will cover the basics of testing in Move and how to write and organize tests for your Move code.

## The `#[test]` attribute

Tests in Move are functions marked with the `#[test]` attribute. This attribute tells the compiler that the function is a test function, and it should be run when the tests are executed. Test functions are regular functions, but they must return `()` and take no arguments. They are excluded from the bytecode, and are not included in the final package.

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

To run tests, you can use the `sui move test` command. This command will first build the package in the *test mode* and then run all the tests found in the package. During test mode, modules from both `sources/` and `tests/` directories are processed, and the tests are executed.

```bash
$ sui move test
> INCLUDING DEPENDENCY Sui
> INCLUDING DEPENDENCY MoveStdlib
> BUILDING book
> Running Move unit tests
> ...
```

<!-- TODO: fill output -->

## Utilities with `#[test_only]`

In some cases, it is helpful to give the test environment access to some of the internal functions or features. It simplifies the testing process and allows for more thorough testing. However, it is important to remember that these functions should not be included in the final package. This is where the `#[test_only]` attribute comes in handy.

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

Functions marked with the `#[test_only]` will be available to the test environment, and to the other modules if their visibility is set so.

## Topics not covered

- Unit Testing with Dummy Context
- Utilizing the Test Scenario
- Building custom testing frameworks
- Adding Examples

<!-- <!-- ## Unit Testing with Dummy Context

## Utilizing the Test Scenario -->

<!-- ## Adding Examples

When publishing a package that is intented to be used (an NFT protocol or a library), it is important to showcase how this package can be used. This is where examples come in handy. There's no special functionality for examples in Move, however, there are some conventions that are used to mark examples. First of all, only sources are included into the package bytecode, so any code placed in a different directory will not be included, but will be tested!

This is why placing examples into a separate `examples/` directory is a good idea.

```bash
sources/
    protocol.move
    library.move
tests/
    protocol_test.move
examples/
    my_example.move
Move.toml
``` -->
