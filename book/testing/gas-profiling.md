---
description: "Profile gas usage in Move tests: measure computation costs, compare implementations, and analyze traces with sui analyze-trace."
---

# Gas Profiling

Understanding gas consumption helps optimize your Move code and estimate transaction costs. The Move
testing framework provides built-in tools to measure gas usage during test execution. In addition to
that, a special utility `sui analyze-trace` is available for more thorough analysis of gas usage.

> The statistics shown by `-s` only reflect **computation units** - they do not include storage
> costs. Additionally, compiler computation units don't map directly to actual onchain gas charges;
> they show relative computational complexity, useful for comparing implementations against each
> other. To get actual gas costs, publish your package to testnet and measure real transactions.

## Simple Measurement: Test Statistics

Use the `-s` or `--statistics` flag with `sui move test` to see execution time and gas consumption
for each test:

```bash
sui move test -s
```

The output shows a table with three columns:

```table
Test Statistics:

┌────────────────────────────────────────────────────────┬────────────┬───────────────────────────┐
│                       Test Name                        │    Time    │         Gas Used          │
├────────────────────────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::my_module::test_simple_operation                 │   0.006    │          998001           │
├────────────────────────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::my_module::test_complex_operation                │   0.007    │          998068           │
├────────────────────────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::my_module::test_with_objects                     │   0.006    │          998001           │
└────────────────────────────────────────────────────────┴────────────┴───────────────────────────┘

Test result: OK. Total tests: 3; passed: 3; failed: 0
```

- **Test Name**: Fully qualified name of the test function
- **Time**: Execution time in seconds
- **Gas Used**: Gas units consumed by the test

> Every test's total includes a large fixed base cost - even an empty test reports roughly 998000
> gas units. When comparing tests, look at the difference between their totals rather than the
> absolute values.

## CSV Output

For programmatic analysis or importing into spreadsheets, use the `csv` option:

```bash
sui move test -s csv
```

This produces comma-separated output:

```
name,nanos,gas
book::my_module::test_simple_operation,5992125,998001
book::my_module::test_complex_operation,6870583,998068
book::my_module::test_with_objects,6022917,998001
```

The time is in nanoseconds, which allows for more precise measurements when comparing similar
operations.

## Gas Limits

Use the `-i` or `--gas-limit` flag to set a maximum gas budget for tests. Tests exceeding this limit
will timeout:

```bash
sui move test -i 1000
```

> The limit is measured in internal execution gas units, which do not map one-to-one to the values
> in the `Gas Used` column - a trivial test that reports ~998000 gas passes comfortably with a
> limit of 1000.

Output when a test exceeds the gas limit:

```
[ TIMEOUT ] book::my_module::test_complex_operation
[ PASS    ] book::my_module::test_simple_operation
[ PASS    ] book::my_module::test_with_objects

Test failures:

Failures in book::my_module:

┌── test_complex_operation ──────
│ Test timed out
└──────────────────

Test result: FAILED. Total tests: 3; passed: 2; failed: 1
```

This is useful for:

- **Identifying expensive operations**: Find tests that consume unexpected amounts of gas
- **Enforcing gas budgets**: Ensure critical paths stay within acceptable limits
- **Testing gas exhaustion**: Verify your code handles out-of-gas scenarios correctly (see
  [Expected Failures](./testing-basics.md#expected-failures))

## Comparing Implementations

Use statistics to compare gas consumption between different implementations:

```move
module book::comparison;

use std::unit_test::assert_eq;

public fun sum_loop(n: u64): u64 {
    let mut sum = 0;
    n.do!(|i| sum = sum + i);
    sum
}

public fun sum_formula(n: u64): u64 {
    n * (n - 1) / 2
}

#[test]
fun test_sum_loop() {
    let result = sum_loop(1000);
    assert_eq!(result, 499500);
}

#[test]
fun test_sum_formula() {
    let result = sum_formula(1000);
    assert_eq!(result, 499500);
}
```

Running with statistics reveals the difference:

```bash
sui move test comparison -s
```

```table
┌────────────────────────────────────┬────────────┬───────────────────────────┐
│           Test Name                │    Time    │         Gas Used          │
├────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::comparison::test_sum_loop    │   0.003    │          998078           │
├────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::comparison::test_sum_formula │   0.001    │          998001           │
└────────────────────────────────────┴────────────┴───────────────────────────┘
```

The loop costs 77 gas units on top of the base cost, while the formula adds nothing measurable.

## Trace Analysis

For deeper profiling, you can generate execution traces from tests and visualize them with
[speedscope](https://www.speedscope.app/). This shows a flamegraph of gas consumption broken down by
function calls, making it easy to spot exactly where gas is being spent.

### Step 1: Generate Traces

Run tests with the `--trace` flag to produce trace files:

```bash
sui move test --trace
```

Trace files are written to the `traces/` directory in the package root (next to `Move.toml`).

### Step 2: Generate a Gas Profile

Use `sui analyze-trace` with the `gas-profile` subcommand to convert a trace into a profile:

```bash
sui analyze-trace -p traces/<TRACE_FILE> gas-profile
```

This outputs a `gas_profile_<TRACE_FILE>.json` file in the current directory. You can specify a
different output directory with the `-o` flag, which goes before the `gas-profile` subcommand:

```bash
sui analyze-trace -p traces/<TRACE_FILE> -o ./profiles gas-profile
```

### Step 3: Visualize with Speedscope

Install [speedscope](https://www.speedscope.app/) and open the profile:

```bash
npm install -g speedscope
speedscope gas_profile_<TRACE_FILE>.json
```

Speedscope provides three views:

- **Time Order**: Shows the call stack from left to right in invocation order. Bar width corresponds
  to gas consumption.
- **Left Heavy**: Groups repeated calls together, ordered by total gas consumption - useful for
  finding the most expensive code paths.
- **Sandwich**: Lists gas consumption per function with **Total** (including called functions) and
  **Self** (function only) columns.

## Further Reading

- [Running Tests](./testing-basics.md) - Basic test execution and expected failures
- [Test Utilities](./test-utilities.md) - Assertion macros and test helpers
- [Collections](./../programmability/collections.md) - Choosing efficient data structures
- [Trace Analysis](https://docs.sui.io/references/cli/trace-analysis) - Sui CLI trace analysis
  reference
