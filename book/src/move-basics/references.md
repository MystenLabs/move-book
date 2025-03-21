# References

<!--

Chapter: Basic Syntax
Goal: Show what the borrow checker is and how it works.
Notes:
    - give the metro pass example
    - show why passing by reference is useful
    - mention that reference comparison is faster
    - references can be both mutable and immutable
    - immutable access to shared objects is faster
    - implicit copy
    - moving the value
    - unpacking a reference (mutable and immutable)

 -->

In the [Ownership and Scope](./ownership-and-scope.md) section, we explained that when a value is
passed to a function, it is _moved_ to the function's scope. This means that the function becomes
the owner of the value, and the original scope (owner) can no longer use it. This is an important
concept in Move, as it ensures that the value is not used in multiple places at the same time.
However, there are use cases when we want to pass a value to a function but retain ownership.
This is where references come into play.

To illustrate this, let's consider a simple example - an application for a metro (subway) pass. We
will look at 4 different scenarios where a card can be:

1. Purchased at a kiosk for a fixed price
2. Shown to an inspector to prove that the passenger has a valid pass
3. Used at the turnstile to enter the metro, and purchase a ride
4. Recycled after it's empty

## Layout

The initial layout of the metro pass application is simple. We define the `Card` type and the `USES`
[constant](./constants.md) that represents the number of rides on a single card. We also add an
[error constant](./assert-and-abort.md#error-constants) for the case when the card is empty.

```move
module book::metro_pass;
{{#include ../../../packages/samples/sources/move-basics/references.move:header}}

{{#include ../../../packages/samples/sources/move-basics/references.move:new}}
```

<!-- In [the previous section](./ownership-and-scope.md) we explained the ownership and scope in Move. We showed how the value is *moved* to a new scope, and how it changes the owner. In this section, we will explain how to *borrow* a reference to a value to avoid moving it, and how Move's *borrow checker* ensures that the references are used correctly. -->

## References

References are a way to _show_ a value to a function without giving up ownership. In our case,
when we show the Card to the inspector, we don't want to give up ownership of it, and we don't
allow the inspector to use up any of our rides. We just want to allow the _reading_ of the value
of our Card and to prove its ownership.

To do so, in the function signature, we use the `&` symbol to indicate that we are passing a
_reference_ to the value, not the value itself.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:immutable}}
```

Because the function does not take ownership of the Card, it can _read_ its data but cannot _write_
to it, meaning it cannot modify the number of rides. Additionally, the function signature ensures
that it cannot be called without a Card instance. This is an important property that allows the
[Capability Pattern](./../programmability/capability.md), which we will cover in the next chapters.

Creating a reference to a value is often referred to as "borrowing" the value. For example, the
method to get a reference to the value wrapped by an `Option` is called `borrow`.

## Mutable Reference

In some cases, we want to allow the function to modify the Card. For example, when using the Card
at a turnstile, we need to deduct a ride. To achieve this, we use the `&mut` keyword in the function
signature.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:mutable}}
```

As you can see in the function body, the `&mut` reference allows mutating the value, and the
function can spend rides.

## Passing by Value

Lastly, let's illustrate what happens when we pass the value itself to the function. In
this case, the function takes the ownership of the value, making it inaccessible in the original
scope. The owner of the Card can recycle it and thereby relinquish ownership to the function.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:move}}
```

In the `recycle` function, the Card is passed by value, transferring ownership to the function.
This allows it to be unpacked and destroyed.

> Note: In Move, `_` is a wildcard pattern used in destructuring to ignore a field while still consuming the value.
> Destructuring must match all fields in a struct type. If a struct has fields, you must list all of them
> explicitly or use `_` to ignore unwanted fields.

## Full Example

To illustrate the full flow of the application, let's put all the pieces together in a test.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:move_2024}}
```

<!-- ## Dereference and Copy -->

<!-- TODO: defer and copy, *& -->

<!-- ## Notes -->

<!--
    Move 2024 is great but it's better to show the example with explicit &t and &mut t
    ...and then say that the example could be rewritten with the new syntax


-->

<!-- ## Move 2024

Here's the test from this page written with the Move 2024 syntax:

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:move_2024}}
```
-->
