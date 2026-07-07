---
description: "The Sui Verifier internal constraint: why storage operations require the type to be defined in the calling module."
---

# Sui Verifier: Internal Constraint

In the [Internal Permit](./../move-basics/internal-permit) section, we introduced _internal type
parameters_: type parameters that only accept types defined in the calling module. There,
`std::internal::permit<T>()` used the rule to produce a proof value. On Sui, the same rule
protects a handful of critical framework functions _directly_ - no permit value involved - and the
component enforcing it is the _Sui Verifier_.

The Sui Verifier is a set of bytecode-level checks that run on top of regular Move verification,
both at compilation and when a package is published onchain. Most of its rules formalize what
this chapter has already described - such as the `id: UID` first-field requirement from the
[key ability](./key-ability) section. The _internal constraint_ is the rule that matters most for
what comes next: a function marked with it can only be called with a type parameter `T` that is
_internal_ - defined in the calling module.

Let's look at the classic example - the `emit` function from the `sui::event` module (covered in
detail in the [Events](./../programmability/events) section), which requires its type parameter to
be internal to the caller:

```move
module sui::event;

// Sui Verifier will emit an error at compilation if this function is
// called from a module that does not define `T`.
public native fun emit<T: copy + drop>(event: T);
```

Here is a correct call to `emit`. The type `A` is defined in the same module that makes the call,
so the constraint is satisfied:

```move file=packages/samples/sources/storage/internal-constraint.move anchor=main

```

But calling `emit` with a type defined elsewhere - for example, the `TypeName` type from the
[Standard Library](./../move-basics/standard-library) - is rejected:

```move
// This one fails!
public fun call_foreign_fail() {
    use std::type_name;

    event::emit(type_name::with_defining_ids<A>());
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invalid event.
    // Error: `sui::event::emit` must be called with a type
    // defined in the current module.
}
```

The effect is the same authority rule we established for [struct fields](./../move-basics/struct#field-visibility)
and saw generalized by `Permit`: the module that defines a type decides what happens with it. For
`emit`, it means only the defining module can emit events of its type; for the
[storage functions](./storage-functions) in the next section, it means the defining module fully
governs how its objects enter storage - unless it opts out by adding the
[`store`](./store-ability) ability.

## Summary

- The Sui Verifier is a set of bytecode-level rules checked at compilation and on publish.
- The internal constraint restricts a function's type parameter to types defined in the calling
  module.
- It applies to a handful of critical framework functions: `event::emit`, and the restricted
  storage functions covered in the [next section](./storage-functions).

## Further Reading

- [Internal Permit](./../move-basics/internal-permit) - the same rule, available to any library
  through `std::internal`.
