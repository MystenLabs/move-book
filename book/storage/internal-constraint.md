# Sui Verifier: Internal Constraint

The Sui Bytecode Verifier enforces a set of rules on Move bytecode to ensure the safety of critical
storage operations. One of these rules is the _internal constraint_. It requires that the caller of
a function with a type parameter `T` must be the _defining module_ of that type. In other words, T
must be _internal_ to the module making the call.

This rule is not (yet) part of the Move language itself, which can make it feel opaque. Still, it’s
an important rule to understand, especially when working with storage-related operations on Sui.

Let’s look at an example from the [Sui Framework][sui-framework]. The emit function in the
[`sui::event`][event] module requires its type parameter T to be internal to the caller:

```move
// An actual example of a function that enforces `internal` on `T`.
module sui::event;

// Sui Verifier will emit an error at compilation if this function is
// called from a module that does not define `T`.
public native fun emit<T: copy + drop>(event: T);
```

Here’s a correct call to `emit`. The type `A` is defined inside the module `exercise_internal`, so
it’s internal and valid:

```move
// Defines type `A`.
module book::exercise_internal;

use sui::event;

/// Type defined in this module, so it's internal here.
public struct A has copy, drop {}

// This works because `A` is defined locally.
public fun call_internal() {
    event::emit(A {})
}
```

But if you try to call `emit` with a type defined elsewhere, the verifier rejects it. For example,
this function, when added to the same module, fails because it tries to use the `TypeName` type from
the [Standard Library][move-stdlib]:

```move
// This one fails!
public fun call_foreign_fail() {
    use std::type_name;

    event::emit(type_name::get<A>());
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invalid event.
    // Error: `sui::event::emit` must be called with a type
    // defined in the current module.
}
```

Internal constraints only apply to certain functions in the [Sui Framework][sui-framework]. We’ll
return to this concept several times throughout the book.

[sui-framework]: ./../programmability/sui-framework.md
[move-stdlib]: ./../move-basics/standard-library.md
[event]: ./../programmability/events.md
[reflection]: ./../move-basics/type-reflection.md
