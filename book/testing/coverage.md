---
description: "Generate code coverage reports for Move tests: use the --coverage flag and sui move coverage to identify untested code paths."
---

# Generating Coverage Reports

Code coverage is a metric that shows which parts of your code are executed during tests. It helps
identify untested code paths and ensures your tests are comprehensive. The `--coverage` flag on
`sui move test` generates coverage data, and `sui move coverage` provides tools to analyze it.

## Running Tests with Coverage

To generate coverage data, run your tests with the `--coverage` flag:

```bash
sui move test --coverage
```

This will run all tests and collect coverage information. The coverage data is stored in the `build`
directory and can be analyzed using the `sui move coverage` subcommands.

## Coverage Summary

The `sui move coverage summary` command displays a high-level overview of coverage for all modules:

```bash
sui move coverage summary
```

This outputs a table showing the coverage percentage for each module:

```
+-------------------------+
| Move Coverage Summary   |
+-------------------------+
Module 0x0::my_module
>>> % Module coverage: 85.71
Module 0x0::another_module
>>> % Module coverage: 100.00
Module 0x0::untested_module
>>> % Module coverage: 0.00
+-------------------------+
| % Move Coverage: 62.50  |
+-------------------------+
```

To see coverage broken down by individual functions, add the `--summarize-functions` flag:

```bash
sui move coverage summary --summarize-functions
```

For programmatic processing, you can output the results in CSV format:

```bash
sui move coverage summary --csv
```

## Source Coverage

The `source` subcommand shows which lines of a specific module were executed:

```bash
sui move coverage source --module <MODULE_NAME>
```

This displays the source code with coverage annotations, showing which lines were covered (executed
during tests) and which were not. This is useful for identifying specific code paths that need
additional test coverage.

## LCOV Format

For integration with external tools and CI/CD pipelines, you can generate coverage reports in
[LCOV format](https://github.com/linux-test-project/lcov). LCOV is a widely-supported format that
works with many coverage visualization tools.

First, run tests with the `--trace` flag to generate the necessary trace data:

```bash
sui move test --coverage --trace
```

Then generate the LCOV report:

```bash
sui move coverage lcov
```

This creates an `lcov.info` file in the current directory. The file contains detailed coverage
information that can be used with tools like:

- [genhtml](https://github.com/linux-test-project/lcov) - Generate HTML coverage reports
- [VS Code Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) -
  Visualize coverage in your editor
- [Codecov](https://codecov.io/) / [Coveralls](https://coveralls.io/) - Upload to coverage tracking
  services

### Generating HTML Reports

To generate an HTML report from the LCOV file, use `genhtml` (part of the LCOV package):

```bash
genhtml lcov.info -o coverage_html
```

This creates a `coverage_html` directory with an interactive HTML report you can open in a browser.

### Differential Coverage

The `lcov` command supports differential coverage analysis with the `--differential-test` flag. This
shows which lines are covered exclusively by a specific test:

```bash
sui move coverage lcov --differential-test <TEST_NAME>
```

Lines hit only by the specified test show as covered, while lines hit by both the specified test and
other tests show as uncovered. This helps identify what unique coverage each test provides.

### Single Test Coverage

To generate coverage for a single test only:

```bash
sui move coverage lcov --only-test <TEST_NAME>
```

This is useful for understanding the coverage footprint of individual tests.

## Bytecode Coverage

For advanced debugging, you can view coverage against disassembled bytecode:

```bash
sui move coverage bytecode --module <MODULE_NAME>
```

This shows coverage at the bytecode level, which can be useful for understanding exactly which
instructions were executed.

## Summary

| Command | Description |
| --- | --- |
| `sui move test --coverage` | Run tests and collect coverage data |
| `sui move test --coverage --trace` | Run tests with trace data (required for LCOV) |
| `sui move coverage summary` | Show coverage percentage per module |
| `sui move coverage summary --summarize-functions` | Show coverage broken down by function |
| `sui move coverage summary --csv` | Output coverage summary in CSV format |
| `sui move coverage source --module <NAME>` | Show line-by-line coverage for a module |
| `sui move coverage lcov` | Generate LCOV report (`lcov.info`) |
| `sui move coverage lcov --differential-test <TEST>` | Show lines covered exclusively by a test |
| `sui move coverage lcov --only-test <TEST>` | Generate coverage for a single test |
| `sui move coverage bytecode --module <NAME>` | Show coverage against disassembled bytecode |
