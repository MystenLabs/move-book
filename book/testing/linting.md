---
description: "Run Move linters with sui move lint: catch Sui-specific antipatterns at compile time, suppress false positives, and enforce lints in CI."
---

# Running Lints

The Move compiler ships with a set of _lints_ - static checks that flag suspicious patterns in the
code at compile time. Tests verify that the code does what it should; lints catch code that
compiles and may even pass tests, but does something a more experienced Move developer would not
write: transfers that break composability, comparisons that never do what they look like they do,
or an `entry` function that can never be called. Running lints regularly - and keeping the package
free of warnings - is a cheap way to maintain code quality.

## Running Lints

The `sui move lint` command compiles the package and runs the full set of linters:

```bash
sui move lint
```

To also check the code in the `tests` directory, add the `--test` flag:

```bash
sui move lint --test
```

The same checks are available on other commands via the `--lint` flag - for example,
`sui move test --lint` runs the tests and the full lint set in one go.

Consider a module with a function that transfers a newly created object to the transaction sender:

```move
module book::mint;

public struct Item has key, store { id: UID }

public fun mint(ctx: &mut TxContext) {
    let item = Item { id: object::new(ctx) };
    transfer::transfer(item, ctx.sender());
}
```

Running the linter prints a warning with an explanation and a pointer to the exact expression:

```
warning[Lint W99001]: non-composable transfer to sender
  ┌─ ./sources/mint.move:7:5
  │
5 │ public fun mint(ctx: &mut TxContext) {
  │            ---- Returning an object from a function, allows a caller to use the object and enables composability via programmable transactions.
6 │     let item = Item { id: object::new(ctx) };
7 │     transfer::transfer(item, ctx.sender());
  │     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  │     │                        │
  │     │                        Transaction sender address coming from here
  │     Transfer of an object to transaction sender address
  │
  = This warning can be suppressed with '#[allow(lint(self_transfer))]' applied to the 'module' or module member ('const', 'fun', or 'struct')
```

The fix suggested by this particular lint is to return the `Item` from the function instead of
transferring it, and let the caller decide what to do with the object.

## Default and Extra Lints

Lints come in two tiers. The _default_ tier contains the most important Sui-specific checks, and
runs on every compilation - a plain `sui move build` or `sui move test` reports these warnings
too. The _extra_ tier adds two more Sui checks and a set of code style lints; it runs when linting
is explicitly requested - by `sui move lint` or the `--lint` flag.

## Suppressing Lints

Lints are heuristics, and sometimes the flagged code is intentional. A lint can be suppressed with
the `#[allow(lint(<name>))]` attribute, applied to a module or a module member, using the lint
name printed in the warning:

```move
public struct Account has key { id: UID }

/// An account object, deliberately created for and owned by the sender.
#[allow(lint(self_transfer))]
public fun new_account(ctx: &mut TxContext) {
    transfer::transfer(
        Account { id: object::new(ctx) },
        ctx.sender(),
    );
}
```

A single attribute can suppress multiple lints: `#[allow(lint(share_owned, self_transfer))]`.
Treat suppressions like any other exception - keep them narrow (prefer a function over the whole
module) and explain the reason in a comment or doc comment.

## Lints in CI

To enforce a warning-free codebase, add the `--warnings-are-errors` flag - the command then fails
with a non-zero exit code on any warning, including lints:

```bash
sui move lint --test --warnings-are-errors
```

For tooling that consumes the output programmatically, `--json-errors` switches diagnostics to
JSON format.

## Lint Reference

The linter groups its checks into two sets: the _default_ lints that run on every compilation, and
the _extra_ lints that only run under the `--lint` flag.

### Default Lints

These run on every compilation:

| Lint | Code | What it flags |
| --- | --- | --- |
| `share_owned` | W99000 | Sharing an object that may have been previously owned; share objects in the transaction that creates them |
| `self_transfer` | W99001 | Transferring a new object to the sender instead of returning it; hurts composability |
| `custom_state_change` | W99002 | A custom transfer/share/freeze policy on a type with `store`; the `public_*` [storage functions](./../storage/storage-functions) can bypass it |
| `coin_field` | W99003 | A struct field of type `Coin<T>`; [`Balance<T>`](./../programmability/balance-and-coin) is cheaper and usually the right choice |
| `freeze_wrapped` | W99004 | Freezing an object that wraps other objects |
| `collection_equality` | W99005 | Comparing [dynamic collections](./../programmability/dynamic-collections) with `==`; only the `id` and `size` are compared, never the contents |
| `public_random` | W99006 | A `public` function taking [`Random`](./../programmability/randomness); exposes randomness to composition attacks |
| `missing_key` | W99007 | A struct with an `id: UID` field but no `key` ability |
| `public_entry` | W99010 | Unnecessary [`entry`](./../move-advanced/entry-functions) modifier on a `public` function |
| `uncallable_function` | W99011 | A function that can never be called in a transaction, such as an `entry` function taking `&mut Clock` |

### Extra Lints

Enabled by `sui move lint` or the `--lint` flag:

| Lint | Code | What it flags |
| --- | --- | --- |
| `freezing_capability` | W99008 | Freezing a type that looks like a [capability](./../programmability/capability) |
| `prefer_mut_tx_context` | W99009 | A `public` function taking `&TxContext`; prefer `&mut TxContext` to keep the signature future-proof |

The extra tier also includes code style lints (codes `W04xxx`): `constant_naming`, `while_true`,
`unnecessary_math`, `unneeded_return`, `abort_without_constant`, `loop_without_exit`,
`unnecessary_conditional`, `self_assignment`, `redundant_ref_deref`, `unnecessary_unit`,
`always_equal_operands`, and `combinable_comparisons`. Each flags a small readability or
correctness issue and suggests the simpler equivalent.

## Summary

| Command | Description |
| --- | --- |
| `sui move lint` | Compile the package and run the full lint set |
| `sui move lint --test` | Also lint the code in the `tests` directory |
| `sui move lint --warnings-are-errors` | Fail on any warning - for CI |
| `sui move build` / `sui move test` | Run the default lint tier |
| `sui move test --lint` | Run tests with the full lint set |
| `--no-lint` | Disable linters entirely |

## Further Reading

- [Code Quality Checklist](./../guides/code-quality-checklist) - a broader review checklist that
  lints automate a part of.
- [Move CLI reference](https://docs.sui.io/references/cli/move) in the Sui Documentation.
