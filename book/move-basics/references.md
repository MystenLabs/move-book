---
description: "References in Move: immutable and mutable borrows, the borrow checker, and how to safely pass values without transferring ownership."
---

# References

In the [Ownership and Scope](./ownership-and-scope) section, we explained that when a value is
passed to a function, it is _moved_ to the function's scope. This means that the function becomes
the owner of the value, and the original scope (owner) can no longer use it. This is an important
concept in Move, as it ensures that the value is not used in multiple places at the same time.
However, there are use cases when we want to pass a value to a function but retain ownership. This
is where references come into play.

To illustrate this, let's consider a simple example - an application for a metro (subway) pass. We
will look at 4 different scenarios where a card can be:

1. Purchased at a kiosk for a fixed price
2. Shown to an inspector to prove that the passenger has a valid pass
3. Used at the turnstile to enter the metro, and purchase a ride
4. Recycled after it's empty

## The Metro Pass Application

The initial layout of the metro pass application is simple. We define the `Card` type and the `USES`
[constant](./constants) that represents the number of rides on a single card. We also add
[error constants](./assert-and-abort#error-constants) for the case when the card is empty and when
the card is not empty.

```move file=packages/samples/sources/move-basics/references.move anchor=header_new
module book::metro_pass;


```

## Immutable References

References are a way to _show_ a value to a function without giving up ownership. In our case, when
we show the Card to the inspector, we don't want to give up ownership of it, and we don't allow the
inspector to use up any of our rides. We just want to allow the _reading_ of the value of our Card
and to prove its ownership.

To do so, in the function signature, we use the `&` symbol to indicate that we are passing a
_reference_ to the value, not the value itself.

```move file=packages/samples/sources/move-basics/references.move anchor=immutable

```

Because the function does not take ownership of the Card, it can _read_ its data but cannot _write_
to it, meaning it cannot modify the number of rides. Additionally, the function signature ensures
that it cannot be called without a Card instance. This is an important property that allows the
[Capability Pattern](./../programmability/capability), which we will cover in the next chapters.

The `&` operator is not limited to function signatures: it is an expression that can be applied to
any value or to a single field of a struct. The resulting reference can be stored in a local
variable and passed on:

```move
let card = purchase();

let card_ref = &card;       // reference to the whole value
let uses_ref = &card.uses;  // reference to a single field
```

Creating a reference to a value is often referred to as "borrowing" the value. For example, the
method to get a reference to the value wrapped by an `Option` is called `borrow`.

## Mutable Reference

In some cases, we want to allow the function to modify the Card. For example, when using the Card at
a turnstile, we need to deduct a ride. To achieve this, we use the `&mut` keyword in the function
signature.

```move file=packages/samples/sources/move-basics/references.move anchor=mutable

```

As you can see in the function body, the `&mut` reference allows mutating the value, and the
function can spend rides.

A mutable reference can be used anywhere an immutable one is expected: passing `&mut card` to the
`is_valid` function is perfectly fine, the function will simply not be able to modify the value.
The reverse is not true - an immutable reference can never be turned into a mutable one.

## The Borrow Checker

References are compiled with the help of the _borrow checker_ - the part of the compiler that
tracks every borrow and rejects programs which could use references unsafely. The rules it
enforces are:

- While a value is borrowed, it cannot be moved, passed by value, or destroyed;
- There can be either a single mutable reference to a value, or any number of immutable
  references - never both at the same time;
- A reference cannot outlive the value it points to.

To see the borrow checker in action, let's try to break the first rule and recycle the card while
the inspector is still looking at it:

```move
let card = purchase();
let card_ref = &card;

recycle(card); // ERROR! Invalid move of the local `card`:
               // the value is still being borrowed by `card_ref`.

is_valid(card_ref);
```

The compiler rejects this program: as long as `card_ref` is alive and used, the value it points to
must stay in place. The same mechanism prevents two mutable references from existing at once, or a
value from being modified while it is immutably borrowed. Thanks to these rules, a reference in
Move can never point at destroyed or moved-away data, and functions can trust their arguments
without any runtime checks.

## Passing by Value

Lastly, let's illustrate what happens when we pass the value itself to the function. In this case,
the function takes the ownership of the value, making it inaccessible in the original scope. The
owner of the Card can recycle it and thereby relinquish ownership to the function.

```move file=packages/samples/sources/move-basics/references.move anchor=move

```

In the `recycle` function, the Card is passed by value, transferring ownership to the function. This
allows it to be [unpacked](./struct#unpacking-a-struct) and destroyed.

## Returning References

A function can not only take references - it can also return them. This is exactly how _getters_,
which we mentioned in the [struct section](./struct#getters-and-setters), provide access to the
fields of a struct from other modules. Let's add one to the metro pass application:

```move file=packages/samples/sources/move-basics/references.move anchor=getter

```

A returned reference must point into a value that the caller owns - in other words, it must be
_derived_ from one of the reference parameters of the function. Returning a reference to a local
value is impossible, since the local is destroyed when the function returns:

```move
// Won't compile!
public fun dangling(): &u8 {
    let x = 10;
    &x // ERROR! The local `x` is destroyed at the end of the function.
}
```

Returning a mutable reference to a field is also possible - and it is a decision to make carefully,
as it allows any caller to modify the field directly. The borrow checker rules apply to returned
references just as they do to local borrows: while the returned reference is alive, the value it
was derived from stays borrowed.

## References Cannot Be Stored

References in Move are _ephemeral_: they exist as function arguments, local variables, and return
values, but they can never be put into a struct. A field of a reference type is a compilation
error, so no value can carry a reference beyond the end of a function call. If a struct needs to
refer to another value long-term, it stores a copy of the data or an identifier of it, never a
reference.

This restriction has consequences you will meet throughout the book. It is why references have only
the `copy` and `drop` [abilities](./abilities-introduction) and can never be stored; and why
collection types hand out a fresh reference on every `borrow` call instead of keeping one. It is
also the reason Move needs no _lifetime_ annotations for references - a reference can never escape
the call in which it was created.

## Dereferencing

A reference gives access to a value, but sometimes the code holding a reference needs a copy of the
value itself. The _dereference operator_ `*` reads the value behind a reference and produces a copy
of it - the original value stays where it was, untouched:

```move file=packages/samples/sources/move-basics/references.move anchor=deref

```

Because dereferencing copies, it is only allowed for types with the
[copy ability](./copy-ability) - a unique asset cannot be duplicated by taking a reference to it
and dereferencing. The `*(&mut ...) = value` form in the example is the flip side of the same
operator: assigning through a mutable reference replaces the value behind it.

You may also encounter the `*&` combination - borrow and immediately dereference - which is the
idiomatic way to write an explicit copy of a field or variable.

## Borrowing in Practice: Method Calls

To illustrate the full flow of the application, let's put all the pieces together in a test. This
time we will use the [method syntax](./struct-methods) instead of plain function calls:

```move file=packages/samples/sources/move-basics/references.move anchor=move_2024

```

Notice that not a single `&` appears in the test, yet references are doing all the work. When a
function is called with the method syntax, the compiler borrows the receiver _automatically_,
based on the signature of the function: `card.is_valid()` borrows `card` immutably as `&Card`,
`card.enter_metro()` borrows it mutably as `&mut Card`, and `card.recycle()` passes the value as
is, by value. This is why everyday Move code rarely spells out the borrow operator - most borrows
happen implicitly at method call sites, following the same borrow checker rules described above.

## Summary

- References allow showing a value to a function without giving up ownership: `&` for read-only
  access, `&mut` for read-write access.
- The borrow checker enforces the safety rules: no moving of borrowed values, a single `&mut` _or_
  any number of `&`, and no reference may outlive its value.
- Functions can return references derived from their reference parameters - the basis of getters.
- References cannot be stored in structs - they never outlive the function call.
- Method calls borrow the receiver automatically, based on the function signature.

## Further Reading

- [References](./../../reference/primitive-types/references) in the Move Reference.
