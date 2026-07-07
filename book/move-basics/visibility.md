---
description:
  'Visibility modifiers in Move: private, public, public(package), and entry functions for
  controlling access to module members.'
---

# Visibility Modifiers

Every module member has a visibility. By default, all module members are _private_ - meaning they
are only accessible within the module they are defined in. However, you can add a visibility
modifier to make a module member _public_ - visible outside the module, or _public(package)_ -
visible in the modules within the same package. Additionally, a function can be marked with the
_entry_ modifier, which allows a _non-public_ function to be called from a transaction. Unlike the
rest, `entry` is not a visibility level - it can be combined with them, and it controls how the
function interacts with transactions rather than with other modules.

## Internal Visibility

A function or a struct defined in a module which has no visibility modifier is _private_ to the
module. It can't be called from other modules.

```move
module book::internal_visibility;

// This function can be called from other functions in the same module
fun internal() { /* ... */ }

// Same module -> can call internal()
fun call_internal() {
    internal();
}
```

The following code will not compile, because `internal` is private to `book::internal_visibility`:

```move
module book::try_calling_internal;

use book::internal_visibility;

// Different module -> can't call internal()
fun try_calling_internal() {
    internal_visibility::internal();
    // ^ ERROR! [E04001]: restricted visibility
    //   Invalid call to internal function
    //   'book::internal_visibility::internal'
}
```

Note that just because a struct field is not visible from Move does not mean that its value is kept
confidential &mdash; it is always possible to read the contents of an onchain object from outside
of Move. You should never store unencrypted secrets inside of objects.

## Public Visibility

A struct or a function can be made _public_ by adding the `public` keyword before the `fun` or
`struct` keyword.

```move
module book::public_visibility;

// This function can be called from other modules
public fun public_fun() { /* ... */ }
```

A public function can be imported and called from other modules. The following code will compile:

```move
module book::try_calling_public;

use book::public_visibility;

// Different module -> can call public_fun()
fun try_calling_public() {
    public_visibility::public_fun();
}
```

A `public` function can also be called directly from a
[transaction](./../concepts/what-is-a-transaction). Making a function `public` is the default - and
recommended - way to expose functionality to users: a public function can be a command in a
transaction, be freely combined with other commands in it, and serve as a building block for other
packages. No extra modifier is needed for any of this.

## Package Visibility

A function with _package_ visibility can be called from any module within the same package, but not
from modules in other packages. In other words, it is _internal_ to the package.

```move
module book::package_visibility;

public(package) fun package_only() { /* ... */ }
```

A package function can be called from any module within the same package:

```move
module book::try_calling_package;

use book::package_visibility;

// Same package `book` -> can call package_only()
fun try_calling_package() {
    package_visibility::package_only();
}
```

## Entry Modifier

As shown [above](#public-visibility), a `public` function is already callable from a
[transaction](./../concepts/what-is-a-transaction) - `public` is the default and preferred way to
make a function available, to transactions and other modules alike. The `entry` modifier serves the
opposite goal: a function that can be called _only_ as a command in a transaction. Marking a
_non-public_ function with `entry` keeps it out of reach of other modules' code, while permitting
it as a transaction command - deliberately limiting who can call it and how. It is not a visibility
level: an `entry` function keeps whatever visibility it is declared with. A function marked `entry`
with no other modifier stays _private_ - callable as a transaction command and from its own module,
and nothing else.

```move
module book::entry_functions;

// Can be called from a transaction, but not from other modules
entry fun from_transaction_only() { /* ... */ }

// Can be called from a transaction and from modules of the same package
public(package) entry fun from_package_or_transaction() { /* ... */ }
```

Public functions can already be called from transactions, so `entry` adds nothing to a `public`
function, and the compiler warns about the combination:

```text
warning[Lint W99010]: unnecessary `entry` on a `public` function
  │
7 │ public entry fun both() { }
  │        ^^^^^ `entry` on `public` is meaningless. In conjunction with `public`,
  │              `entry` adds no additional permissions or restrictions.
```

Any Move function can be marked `entry` - there are no restrictions on its signature. The value of
the modifier lies in what it does for _non-public_ functions: they become callable as transaction
commands while staying out of the module's API - and the transaction calling them accepts
additional checks on the arguments it passes.

That guarantee concerns _hot potatoes_ - values that must be consumed before a transaction ends: the
arguments of a non-`public` `entry` function are statically guaranteed not to be entangled with any
such outstanding obligation, which is what lets `entry` serve as a safe transaction boundary. The
full rules, with a worked flash-loan example, are covered in
[Entry Functions](./../move-advanced/entry-functions) in the Advanced Move Features chapter.

To summarize: `entry` limits composability - in both directions. A non-public `entry` function is
not part of the module's API, so other packages cannot call it or build on it; and inside a
transaction, its arguments face restrictions that `public` function arguments do not. Reach for it
when that is the point - when a function should be callable _only_ as a transaction command, or
when it needs the argument guarantee. For everything else, `public` is the right choice.

## Native Functions

Some functions in the [framework](./../programmability/sui-framework) and
[standard library](./standard-library) are marked with the `native` modifier. These functions are
natively provided by the Move VM and do not have a body in Move source code. To learn more about the
native modifier, refer to the
[Move Reference](./../../reference/functions?highlight=native#native-functions).

```move
module std::type_name;

public native fun get<T>(): TypeName;
```

This is an example from `std::type_name`, learn more about this module in the
[reflection chapter](./type-reflection).

## Further Reading

- [Visibility](./../../reference/functions#visibility) in the Move Reference.
