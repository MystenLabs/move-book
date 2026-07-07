---
description: "Write and run unit tests in Move using the #[test] attribute, expected failures, and utilities for testing smart contract logic."
---

# Testing

Move has a built-in testing framework that lets you write unit tests alongside your code. Tests are
functions marked with the `#[test]` attribute, excluded from the published bytecode, and run with the
`sui move test` command. The framework supports expected failures via `#[expected_failure]` and
test-only helpers via `#[test_only]`.

```move
module book::testing;

#[test_only]
use std::unit_test::assert_eq;

// test functions take no arguments and return nothing
#[test]
fun simple_test() {
    let sum = 2 + 2;
    assert_eq!(sum, 4);
}

#[test, expected_failure(abort_code = 0)]
fun test_fail() {
    abort 0
}
```

A test passes if it runs to completion and fails if it aborts - which is exactly what the
`assert_eq!` macro does when its two values differ. For arbitrary conditions there is the more
general [`assert!`](./assert-and-abort) macro; both are the workhorses of Move tests. The second
test above inverts the outcome: `#[expected_failure(abort_code = 0)]` makes the test pass only if
it aborts with the given code, which is the way to test error conditions.

## Test-Only Code

The `#[test_only]` attribute marks a module member - or an entire module - as compiled only for
tests. Test helpers, mock constructors, and imports like the `std::unit_test` import above are
marked this way: the published bytecode stays free of testing machinery, while tests get access to
everything they need, including things the public API deliberately does not expose.

## Explore More

This page only scratches the surface. The dedicated [Testing](./../testing/index.md) chapter walks
through test scenarios, coverage reports, gas profiling, working with system objects, and best
practices for writing tests you can actually trust in production.

## What's Next

This page concludes the Move Basics chapter. You can now define modules and custom types, control
whether values can be copied or discarded, pass them around by reference or by value, write logic
with pattern matching, abstract it with generics and macros - and test all of it. What we have set
aside so far is what makes Move on Sui special: the storage model. The
[Object Model](./../object/) chapter picks up exactly there - it introduces _objects_, the Move
structs that become onchain assets, and the chapters after it show how to store, own, and
transfer them.

## Further Reading

- [Unit Testing](./../../reference/unit-testing) in the Move Reference.
