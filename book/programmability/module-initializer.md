---
description: "The init function in Move: run one-time setup code when a module is published on Sui, with rules and best practices."
---

# Module Initializer

A common use case in many applications is to run certain code just once when the package is
published. Imagine a simple shop module that needs to create the main `Shop` object upon its
publication. In Sui, this is achieved by defining an `init` function within the module. This
function will automatically be called when the module is published.

> The `init` function of every module in the package is called during the publishing process. This
> behavior is limited to the publish command and does not extend to package upgrades - a module
> added in an upgrade will not have its `init` called.

```move file=packages/samples/sources/programmability/module-initializer.move anchor=main

```

In the same package, another module can have its own `init` function, encapsulating distinct logic.

```move file=packages/samples/sources/programmability/module-initializer-2.move anchor=other

```

## The `init` Rules

The function is called on publish if it is present in the module and follows these rules:

- The function must be named `init`, be private, and have no return values;
- it cannot be declared as `entry` and cannot have type parameters;
- it takes one or two arguments: an optional [One Time Witness](./one-time-witness) and the
  [TxContext](./transaction-context), with `TxContext` always being the last argument.

```move
fun init(ctx: &mut TxContext) { /* ... */ }
fun init(otw: OTW, ctx: &mut TxContext) { /* ... */ }
```

These rules are not a convention - they are enforced by the bytecode verifier. A function named
`init` that violates any of them fails verification, and the package cannot be published.

`TxContext` can also be taken as an immutable reference `&TxContext`, but in practice it should
always be `&mut TxContext`: the `init` function cannot access the onchain state, so creating new
objects is the whole point of it - and that requires a mutable reference to the context.

## Trust and Security

While the `init` function can be used to create sensitive objects once, it is important to know
that the same object (e.g. `ShopOwnerCap` from the first example) can still be created in another
function - especially since new functions can be added to the module during an upgrade. The `init`
function is a good place to set up the initial state of the module, but it is not a security
measure on its own.

There are ways to guarantee that the object was created only once, such as the
[One Time Witness](./one-time-witness). And there are ways to limit or disable package upgrades,
described in
[Custom Upgrade Policies](https://docs.sui.io/concepts/sui-move-concepts/packages/custom-policies)
in the Sui Documentation.

## Testing the Initializer

The `init` function is called by the runtime and cannot be invoked in a transaction. However, it
is a regular function in every other sense, so [tests](./../move-basics/testing) placed in the same
module can call it directly:

```move file=packages/samples/sources/programmability/module-initializer.move anchor=test

```

For an `init` function that takes a [One Time Witness](./one-time-witness), the witness value can
be created in tests with the test-only `sui::test_utils::create_one_time_witness` function. And in
scenario-based tests, described in the [Test Scenario](./../testing/test-scenario) section, the
objects created by `init` can also be inspected after the call.

## Next Steps

As follows from the definition, the `init` function is guaranteed to be called only once when the
module is published. So it is a good place to put the code that initializes the module's objects
and sets up the environment and configuration.

For example, if there's a [Capability](./capability) which is required for certain actions, it
should be created in the `init` function. In the next chapter we will talk about the `Capability`
pattern in more detail.
