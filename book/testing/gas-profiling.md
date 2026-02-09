---
description: "Profile gas usage in Move tests: measure computation costs, compare implementations, and analyze traces with sui analyze-trace."
---

# Gas Profiling

Understanding gas consumption helps optimize your Move code and estimate transaction costs. The Move
testing framework provides built-in tools to measure gas usage during test execution. In addition to
that, a special utility `sui analyze-trace` is available for more thorough analysis of gas usage.

> The statistics shown by `-s` only reflect **computation units** - they do not include storage
> costs. Additionally, compiler computation units don't map directly to actual on-chain gas charges;
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
│ book::my_module::test_simple_operation                 │   0.003    │             1             │
├────────────────────────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::my_module::test_complex_operation                │   0.011    │            59             │
├────────────────────────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::my_module::test_with_objects                     │   0.008    │            25             │
└────────────────────────────────────────────────────────┴────────────┴───────────────────────────┘

Test result: OK. Total tests: 3; passed: 3; failed: 0
```

- **Test Name**: Fully qualified name of the test function
- **Time**: Execution time in seconds
- **Gas Used**: Gas units consumed by the test

## CSV Output

For programmatic analysis or importing into spreadsheets, use the `csv` option:

```bash
sui move test -s csv
```

This produces comma-separated output:

```
test_name,time_ns,gas_used
book::my_module::test_simple_operation,3381750,1
book::my_module::test_complex_operation,8454125,59
book::my_module::test_with_objects,3905625,25
```

The time is in nanoseconds, which allows for more precise measurements when comparing similar
operations.

## Gas Limits

Use the `-i` or `--gas-limit` flag to set a maximum gas budget for tests. Tests exceeding this limit
will timeout:

```bash
sui move test -i 50
```

Output when a test exceeds the gas limit:

```
[ PASS    ] book::my_module::test_simple_operation
[ TIMEOUT ] book::my_module::test_complex_operation
[ PASS    ] book::my_module::test_with_objects

Test failures:

Failures in book::my_module:

┌── test_complex_operation ──────
│ Test timed out
└──────────────────
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
    let result = sum_loop(100);
    assert_eq!(result, 4950);
}

#[test]
fun test_sum_formula() {
    let result = sum_formula(100);
    assert_eq!(result, 4950);
}
```

Running with statistics reveals the difference:

```bash
sui move test -s comparison
```

```table
┌────────────────────────────────────┬────────────┬───────────────────────────┐
│           Test Name                │    Time    │         Gas Used          │
├────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::comparison::test_sum_loop    │   0.005    │            201            │
├────────────────────────────────────┼────────────┼───────────────────────────┤
│ book::comparison::test_sum_formula │   0.002    │             3             │
└────────────────────────────────────┴────────────┴───────────────────────────┘
```

## Trace Analysis

For deeper profiling, you can generate execution traces from tests and visualize them with
[speedscope](https://www.speedscope.app/). This shows a flamegraph of gas consumption broken down by
function calls, making it easy to spot exactly where gas is being spent.

### Step 1: Generate Traces

Run tests with the `--trace` flag to produce trace files:

```bash
sui move test --trace
```

Trace files are written to the `traces/` directory inside the package build folder.

### Step 2: Generate a Gas Profile

Use `sui analyze-trace` with the `gas-profile` subcommand to convert a trace into a profile:

```bash
sui analyze-trace -p traces/<TRACE_FILE> gas-profile
```

This outputs a `gas_profile_<TRACE_FILE>.json` file in the current directory. You can specify a
different output directory with the `-o` flag:

```bash
sui analyze-trace -p traces/<TRACE_FILE> gas-profile -o ./profiles
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
