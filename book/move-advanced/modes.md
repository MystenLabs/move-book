# Modes

Modes let you include **unpublishable** code only when you explicitly opt into a named build `mode`.
Think of them as generalizations of the `#[test_only]` [test annotation](../move-basics/testing) for
any purpose you choose (e.g. `debug`, `benchmark`, `spec`, or any other feature).

Modes at a glance:

* Annotate items with `#[mode(name, ...)]` or use the shorthand `#[test_only]` for the built-in
  `test` mode.
  * The `#[test_only]` attribute is syntactic sugar for `#[mode(test)]`.
* Build with `--mode <name>` (or `--test` for unit testing). Items whose mode list contains a name
  you enabled are compiled in. Items whose mode list does **not** match are compiled **out**.
* Code compiled with any mode enabled is **not publishable**. This keeps debug/test scaffolding from
  ever making it on-chain.
* Items with **no** `#[mode(...)]`/`#[test_only]` annotation are always included.

> Tip: Modes are filters enforced at compile-time—they don’t affect bytecode at runtime. Use them
> for helpers, simulators, and other mock types and functions that should never be published.

## Syntax

Like `#[test_only]`, You can attach a mode attribute to modules and to individual members:

```move
// Entire module is included only when a matching mode is enabled
#[mode(debug)]
module my_pkg::debug_tools {
    public fun dump_state() { /* ... */ }
}

module my_pkg::library {
    // This function exists only in `debug` or `test` builds
    #[mode(debug, test)]
    public fun assert_invariants() { /* ... */ }

    // Test-only helper; equivalent to #[mode(test)]
    #[test_only]
    fun mk_fake() { /* ... */ }
}
```

As we can see here, multiple modes can be listed in a single attribute: `#[mode(name1,name2,...)]`.
This item will be included during compilation if **any** of the listed names is enabled. In
addition, any definition without a mode annotation is always included.

> Tip: The annotation `#[mode(test)]` is equivalent to `#[test_only]`.

## Building with modes

Use the Sui CLI to opt into a mode when building or testing:

```bash
# Build with a custom mode enabled
sui move build --mode debug

# Run tests; includes #[test_only] automatically
sui move test --test

# Combine: run unit tests with extra debug helpers
sui move test --test --mode debug
```

Items annotated with a mode you enabled are compiled **in**; items annotated with a different,
non-enabled mode are compiled **out**. Unannotated items are always compiled in.

> **Publish safety**: Any artifact produced while a mode is enabled (including `--test`) is non-publishable. Always run a clean build **without** `--mode`/`--test` before `sui client publish`.

### Example — `test` mode (unit tests)

`#[test_only]` is the built-in mode for unit testing. It works exactly like a mode named `test`.

```move
#[mode(test)]
module my_pkg::math_tests {
    use my_pkg::math;

    #[modetest]
    fun add_basic() { /* ... */ }

    // Private test helper
    fun mk_case() { /* ... */ }
}
```

To build and run:

```bash
# Includes modules and members marked #[test_only]
sui move test --test
```

As described in the [testing](../move-basics/testing) documentation, this is a great way to
keep test helpers and test-only public functions out of published packages.

### Example 2: Debug testing

Suppose you have a `bank` module with a `transfer` function. You want to add debug logging in test
runs where you can see internal state, but you only want to run that test with those logs during
development (e.g., not during CI, etc). You can use a `debug` mode for this.

```move
module my_pkg::bank {
    use std::error;

    public fun transfer(from: &signer, to: address, amount: u64) {
        // ... production logic ...
    }
}

// Debug-only wrappers & helpers
#[mode(debug)]
module my_pkg::bank_debug {
    use std::debug;
    use my_pkg::bank;

    public fun transfer_debug(from: &signer, to: address, amount: u64) {
        // Perform debugging prints before the real call
        debug::print(&b"[DEBUG] transfer begin".to_vector());
        debug::print(&amount);
        debug::print(&to);
        // Main Call
        bank::transfer(from, to, amount);
        // More debugging prints
        debug::print(&b"[DEBUG] transfer end".to_vector());
    }
}
```

Here, `bank::transfer` is the **only** production entry point, with not printing. The
`#[mode(debug)]` exposes `bank_debug::{transfer_debug, dump_account, ...}`, however, which will
**only** be included in `debug`-mode builds. Now, we can write tests that use this extra visibility
without affecting production code or other tests:

```move
#[test_only]
module my_pkg::bank_tests {
    use my_pkg::bank;

    // Runs in all builds (no mode needed)
    #[test]
    fun transfer_basic() {
        // create signers, call bank::transfer(...)
    }

    // Runs only with `--test --mode debug`
    #[mode(debug)]
    #[test]
    fun transfer_with_logs() {
        use my_pkg::bank_debug; // only exists in debug builds
        // create signers, then:
        bank_debug::transfer_debug(&signer, @bob, 100);
        // assertions same as normal test; plus you see prints
    }
}
```

Now we can execute this test with extra logging by enabling the `debug` mode:

```bash
# Standard tests (no debug helpers compiled in)
sui move test

# Debug tests with extra logging
sui move test --mode debug
```

This allows us to produce production bytecode, continuous integration tests, and debug logging
tests, each at different times, without code duplication or complex branching.

## Publication

Code built with any mode enabled is non-publishable. Always do a clean build without `--mode` or
`--test` before publishing:

```bash
sui move build   # no --mode, no --test
```

## See also

* [Testing basics](../move-basics/testing) in the Move Book.
* [Modes](/reference/modes) in the Move Reference.
