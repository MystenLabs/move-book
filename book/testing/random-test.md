---
description: "Property-based testing in Move with #[random_test]: run tests with randomized inputs to discover edge cases automatically."
---

# Random Inputs

The Move compiler supports running tests with randomized inputs through the `#[random_test]`
attribute. This enables property-based testing, where a test runs multiple times with randomly
generated values to discover edge cases you might not think to test manually.

> The `#[random_test]` attribute is a compiler feature for test inputs, separate from the
> `sui::random` module used for on-chain randomness.

## Basic Usage

Mark a function with `#[random_test]` and declare parameters with primitive types. The test runner
will generate random values for each parameter when the test is run.

```move
module book::math;

public fun safe_add(a: u64, b: u64): u64 {
    if (a > 0xFFFFFFFFFFFFFFFF - b) {
        0xFFFFFFFFFFFFFFFF // saturate at max
    } else {
        a + b
    }
}

#[random_test]
fun test_safe_add_never_overflows(a: u64, b: u64) {
    let result = safe_add(a, b);
    // Result should always be >= both inputs (no overflow wrap-around)
    assert!(result >= a && result >= b);
}
```

## Supported Types

Random inputs work with all primitive types:

| Type                                      | Generated Range                           |
| ----------------------------------------- | ----------------------------------------- |
| `u8`, `u16`, `u32`, `u64`, `u128`, `u256` | Full range of the type                    |
| `bool`                                    | `true` or `false`                         |
| `address`                                 | Random 32-byte address                    |
| `vector<T>`                               | Random length vector with random elements |

Note: `T` in `vector<T>` must be a primitive type or another vector (e.g., `vector<vector<u8>>`).

## Practical Tips

**Constrain large integers**: If your function expects small values, use a smaller type and cast:

```move
#[random_test]
fun test_with_bounded_input(small: u8) {
    let bounded = (small as u64) % 100; // 0-99 range
    // ... test with bounded value
}
```

**Avoid unbounded vectors**: `vector<u8>` can generate very large vectors, causing slow tests or gas
errors. Prefer fixed-size inputs or construct vectors manually:

```move
// Avoid: can generate huge vectors
#[random_test]
fun test_bad(v: vector<u8>) { /* ... */ }

// Better: control the size
#[random_test]
fun test_good(a: u8, b: u8, c: u8) {
    let v = vector[a, b, c];
    // ... test with known-size vector
}
```

**Complement, don't replace**: Random tests discover unexpected edge cases but may miss specific
scenarios. Use them alongside targeted unit tests:

```move
use std::unit_test::assert_eq;

// Targeted test for specific case
#[test]
fun test_add_zero() {
    assert_eq!(safe_add(std::u64::max(), 0), std::u64::max());
}

// Random test for general properties
#[random_test]
fun test_add_commutative(a: u64, b: u64) {
    assert_eq!(safe_add(a, b), safe_add(b, a));
}
```

**Use `assert_eq!` for better debugging**: When a random test fails, you need to know which values
caused the failure. Using [`assert_eq!`](./test-utilities.md#assert_eq-and-assert_ref_eq) prints
both compared values on failure, making it easier to reproduce and debug issues:

```move
use std::unit_test::assert_eq;

#[random_test]
fun test_double(value: u64) {
    let doubled = value * 2; // This can overflow, but we omit the check for brevity.
    // On failure, prints: "Assertion failed: <actual> != <expected>"
    assert_eq!(doubled / 2, value);
}
```

## Controlling Test Runs

### Number of iterations

By default, random tests run multiple times with different inputs. Use `--rand-num-iters` to control
how many iterations each random test runs:

```bash
# Run each random test 100 times
sui move test --rand-num-iters 100
```

### Reproducible seeds

When a random test fails, the output includes the seed and instructions to reproduce:

```
┌── test_that_failed ────── (seed = 2033439370411573084)
│ ...
│ This test uses randomly generated inputs. Rerun with
│ `sui move test test_that_failed --seed 2033439370411573084`
│ to recreate this test failure.
└──────────────────
```

Use the provided seed to reproduce the exact failure:

```bash
sui move test test_that_failed --seed 2033439370411573084
```

## Limitations

- **No range constraints**: You cannot limit random values to a specific range directly; use modulo
  or type casting as shown above
- **Vector size**: No control over generated vector lengths

## Summary

- Use `#[random_test]` (not `#[test]`) to enable randomized inputs for a test function
- Parameters must be primitive types or vectors of primitives
- Constrain inputs using smaller types and casting to avoid extreme values
- Use `assert_eq!` for better failure diagnostics
- Control iterations with `--rand-num-iters` and reproduce failures with `--seed`
- Use random tests to complement, not replace, targeted unit tests
