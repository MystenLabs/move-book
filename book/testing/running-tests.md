# Testing Basics

Move compiler supports tests written in Move and has a built-in testing functionality.

## What is a Test?

Test is a function within a package that is annotated with the `#[test]` attribute. It cannot take
any arguments and can, but generally should not, return a value. Test functions are detected and run
automatically when the testing command is run. If a test function
[aborts](./../move-basics/assert-and-abort.md) (if a test did not expect an abort), the test is
considered to have failed.

```move
module book::my_module;

#[test]
// Will be marked as `book::my_module::this_is_a_test` when running tests
fun this_is_a_test() {
    assert!(true);
}

#[test]
// Will be marked as `book::my_module::this_is_another_test` when running tests
// and will be marked as FAILED since it aborts, and does not expect an abort
fun this_is_another_test() {
    abort
}

#[test, expected_failure]
// Will be marked as `book::my_module::this_is_expected_to_fail` when running tests
// and will be marked as PASSED since it aborts, as expected
fun this_is_expected_to_fail() {
    abort
}
```

## Running Tests

To run tests, use the `sui move test` command. Compiler will build the package in _test mode_ and
then run all the tests found in the package.

```bash
sui move test
```
