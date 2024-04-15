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
However, there are use cases when we want to pass a value to a function but retain the ownership.
This is where references come into play.

To illustrate this, let's consider a simple example - an application for a metro (subway) pass. We
will look at 4 different scenarios:

1. Card can be purchased at the kiosk for a fixed price
2. Card can be shown to inspectors to prove that the passenger has a valid pass
3. Card can be used at the turnstile to enter the metro, and spend a ride
4. Card can be recycled once it's empty

## Layout

The initial layout of the metro pass application is simple. We define the `Card` type and the `USES`
[constant](./constants.md) that represents the number of rides for a single card. We also add an
[error constant](./assert-and-abort.md#error-constants) for the case when the card is empty.

```move
module book::metro_pass {
{{#include ../../../packages/samples/sources/move-basics/references.move:header}}

{{#include ../../../packages/samples/sources/move-basics/references.move:new}}
}
```

<!-- In [the previous section](./ownership-and-scope.md) we explained the ownership and scope in Move. We showed how the value is *moved* to a new scope, and how it changes the owner. In this section, we will explain how to *borrow* a reference to a value to avoid moving it, and how Move's *borrow checker* ensures that the references are used correctly. -->

## Reference

References are a way to _show_ a value to a function without giving up the ownership. In our case,
when we show the Card to the inspector, we don't want to give up the ownership of it, and we don't
allow them to spend the rides. We just want to allow _reading_ the value of the Card and prove its
ownership.

To do so, in the function signature, we use the `&` symbol to indicate that we are passing a
reference to the value, not the value itself.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:immutable}}
```

Now the function can't take the ownership of the card, and it can't spend the rides. But it can read
its value. Worth noting, that a signature like this makes it impossible to call the function without
a Card at all. This is an important property which allows the
[Capability Pattern](./../programmability/capability.md) which we will cover in the next chapters.

## Mutable Reference

In some cases, we want to allow the function to change the value of the Card. For example, when we
use the Card at the turnstile, we want to spend a ride. To implement it, we use the `&mut` keyword
in the function signature.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:mutable}}
```

As you can see in the function body, the `&mut` reference allows mutating the value, and the
function can spend the rides.

## Passing by Value

Lastly, let's give an illustration of what happens when we pass the value itself to the function. In
this case, the function takes the ownership of the value, and the original scope can no longer use
it. The owner of the Card can recycle it, and, hence, lose the ownership.

```move
{{#include ../../../packages/samples/sources/move-basics/references.move:move}}
```

In the `recycle` function, the Card is _taken by value_ and can be unpacked and destroyed. The
original scope can't use it anymore.

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
