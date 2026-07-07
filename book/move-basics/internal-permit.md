---
description: "The std::internal module in Move: use Permit<T> to restrict generic function calls to the module that defines the type T."
---

# Internal Permit

In the [Custom Types with Struct](./struct#field-visibility) section we established a rule that
holds everywhere in Move: only the module that defines a type can access its fields, pack it, and
unpack it. This makes the defining module the sole authority over its type - all other code has to
go through the functions the module chooses to expose.

However, this authority seems to disappear the moment a generic function enters the picture. A
public generic function can be called by _any_ module with _any_ type argument - the library that
defines the function has no way of knowing whether the caller has any relation to the type it was
called with. The `std::internal` module closes this gap: it provides a value that proves the call
was authorized by the module that defines the type.

## The Problem

Let's make the problem concrete. Suppose we want to build a type registry - a place where a type can
be registered under a human-readable name. A natural requirement: a type may only be registered by
the module that defines it, so no one can claim a name for someone else's type.

A first attempt at the signature would look like this:

```move
/// Registers the type `T` under the given `name`.
public fun register<T>(registry: &mut Registry, name: String) { /* ... */ }
```

This function cannot enforce our requirement. Move has no way to inspect the caller at runtime -
there is no "get the calling module" function, and this is by design: what a function does must be
fully determined by its arguments. But that phrasing also points at the solution: if authorization
cannot be observed, it must be _passed in_ - as an argument that only the right module is able to
produce.

## The Permit Type

The `std::internal` module is tiny - it defines one struct and one function:

```move
module std::internal;

/// A privileged witness of the `T` type.
/// Instances can only be created by the module that defines the type `T`.
public struct Permit<phantom T>() has drop;

/// Construct a new `Permit` for the type `T`.
/// Can only be called by the module that defines the type `T`.
public fun permit<T>(): Permit<T> { Permit() }
```

At first glance, there is nothing here: a public struct with no fields and a public function that
anyone should be able to call. The important part is the claim in the comment - `permit<T>()` can
only be called by the module that defines `T`. Regular Move code cannot express such a restriction,
and indeed it is not expressed in the code: it is a special rule, checked by the compiler and by the
network when the package is published. We will see it in action in a moment.

Two details of the definition are worth noting:

- The type parameter is [phantom](./generics#phantom-type-parameters) - a `Permit<T>` does not
  contain a `T`, so a permit can be created for a type without constructing an instance of it.
- The only ability is `drop`: a permit can be discarded, but it cannot be copied and cannot be
  stored. Whoever receives a `Permit<T>` holds a proof that cannot be duplicated or stashed away for
  later.

## Using a Permit

To put the rule to work, a library function lists `Permit<T>` as an argument. That is the entire
recipe: since only the module defining `T` can create the value, receiving it _is_ the
authorization. Here is the registry from our problem statement, fixed:

```move file=packages/samples/sources/move-basics/internal-permit.move anchor=registry

```

The `register` function does not even look at the permit - the underscore in `_permit` says it is
intentionally unused. Its type is the check.

> `std::internal`, like `std::option` and `std::vector`, is
> [imported implicitly](./standard-library#implicit-imports) - no `use` statement is needed. The
> recommended style is to keep the module prefix: write `internal::Permit<T>` in signatures and
> `internal::permit<T>()` at call sites, instead of importing `Permit` directly.

On the other side, the module that defines a type creates a permit and passes it along:

```move file=packages/samples/sources/move-basics/internal-permit-2.move anchor=use_permit

```

The registration can now be exercised in a test:

```move file=packages/samples/sources/move-basics/internal-permit-2.move anchor=test

```

## Breaking the Rule

What stops a third module from creating a permit for `MyApp` and registering it under a misleading
name? Let's try:

```move
module book::registry_intruder;

use book::registry_user::MyApp;
use book::type_registry::Registry;

public fun register_foreign_type(registry: &mut Registry) {
    let permit = internal::permit<MyApp>(); // ERROR!
    registry.register(permit, "Not My App");
}
```

The code above will not compile:

```text
error[Sui E02011]: invalid internal permit call
  ┌─ sources/registry_intruder.move:7:18
  │
7 │     let permit = internal::permit<MyApp>();
  │                  ^^^^^^^^^^^^^^^^^^^^^^^^^
  │                  │                │
  │                  │                The type 'book::registry_user::MyApp' is not declared in the current module
  │                  Invalid call to an internal function. The function 'std::internal::permit' is
  │                  restricted to being called in the module that defines the type, 'book::registry_user'
```

The check does not stop at the compiler. The same rule is enforced by the bytecode verifier when a
package is published onchain, so it cannot be bypassed by hand-crafting bytecode or using a
modified compiler. A published `Permit<T>` is a hard guarantee: if a function received one, the
module defining `T` created it.

Type parameters restricted this way are called _internal type parameters_, and `permit` is not the
only function that has one: `sui::event::emit<T>` and `sui::transfer::transfer<T>`, which we cover
in the [Events](./../programmability/events) and
[Storage Functions](./../storage/storage-functions) sections, follow the same rule. What
`std::internal` adds is a way for _any_ library to demand this guarantee: the special rule applies
only to the creation of the permit, and from there it travels as an ordinary value to any function
that lists it as an argument.

## Why It Works This Way

The design of `Permit` follows a general Move principle: authority is represented by values, not by
runtime checks. A function proves it is allowed to do something by _possessing_ a value that could
only be created in an authorized place. This idea appears throughout Move and Sui - it is the basis
of the [Witness](./../programmability/witness-pattern) and
[Capability](./../programmability/capability) patterns - and `Permit` is its most compact form: a
standard, zero-field witness meaning "the module that defines `T` approved this call".

The abilities of `Permit` are chosen to keep that meaning precise. Without `copy`, a function that
receives a permit cannot duplicate it; without `store`, it cannot be kept onchain and reused later.
The authorization is valid for the current call and then gone - every privileged action requires the
defining module to explicitly create a new permit. And because the type parameter is `phantom`, the
proof is free: no instance of `T` is created, copied, or consumed to produce it.

## Further Reading

- [std::internal](https://docs.sui.io/references/framework/std/internal) module documentation.
- [Witness Pattern](./../programmability/witness-pattern) - the broader pattern behind `Permit`.
