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

## Explore More

This page only scratches the surface. The dedicated [Testing](./../testing/index.md) chapter walks
through test scenarios, coverage reports, gas profiling, working with system objects, and best
practices for writing tests you can actually trust in production.

## Further Reading

- [Unit Testing](/reference/unit-testing) in the Move Reference.
- [Testing](./../testing/index.md) chapter in the Move Book.
