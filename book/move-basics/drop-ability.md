---
description: "The drop ability in Move allows struct instances to be discarded. Learn how it works and when to use it in Sui smart contracts."
---

# Abilities: Drop

In most programming languages, doing nothing with a value is not a problem: an unused variable may
trigger a warning at most, and is forgotten the moment it goes out of scope. In Move, as we saw in
the [Struct](./struct#unpacking-a-struct) section, the default is the opposite: a struct value
must be _used_ - stored somewhere, passed on, or unpacked - and a program that silently discards a
value does not compile.

The `drop` ability - the simplest ability of the four - is the opt-out from this rule. A struct
with `drop` is allowed to be _ignored_ or _discarded_: bound to a variable that is never read,
ignored with the `_` wildcard, or simply left behind when its scope ends. In other words, `drop`
makes a Move type behave the way values behave in most other languages:

```move file=packages/samples/sources/move-basics/drop-ability.move anchor=main

```

In the example above, the `IgnoreMe` instance is assigned to `_` and never unpacked - the code
compiles because `IgnoreMe` has the `drop` ability. The `NoDrop` instance cannot be treated this
way: the only two options are to keep it or to unpack it, and the test unpacks it in the last
line.

> The `drop` ability only permits _discarding_ a value. It does not permit copying it or storing
> it - those are governed by the separate [`copy`](./copy-ability) and
> [`store`](./../storage/store-ability) abilities.

## When to Use `drop`

A good rule of thumb: `drop` belongs on types that represent _data_, and its absence protects
types that represent _assets_ or _obligations_.

Configuration values, metadata, intermediate results of a computation - none of these are worth
protecting, and forcing the programmer to explicitly destroy each one would be pure ceremony.
Giving such types the `drop` ability keeps the code clean. Collection types are a good example:
because `vector` has `drop` (when its contents do), a vector of numbers can simply be forgotten
when it is no longer needed.

The absence of `drop`, on the other hand, is one of the defining features of Move's type system.
A coin, a ticket, a receipt, an obligation to repay - a value like this must never silently
vanish, and a type without `drop` gives that guarantee at the compiler level: whoever holds the
value is _forced_ to do something meaningful with it. The compiler-enforced handling of values is
the foundation of the [Hot Potato pattern](./../programmability/hot-potato-pattern) mentioned in
the [previous section](./abilities-introduction#no-abilities), and we explore the full rules of
how values move between scopes in the [Ownership and Scope](./ownership-and-scope) section.

> A struct with `drop` as its single ability is called a _Witness_. We explain the concept of a
> _Witness_ in the [Witness and Abstract Implementation](./../programmability/witness-pattern)
> section.

## Types with the `drop` Ability

All native types in Move have the `drop` ability. This includes:

- [`bool`](./../move-basics/primitive-types#booleans)
- [unsigned integers](./../move-basics/primitive-types#integer-types)
- [`vector<T>`](./../move-basics/vector) when `T` has `drop`
- [`address`](./../move-basics/address)

All of the types defined in the standard library have the `drop` ability as well. This includes:

- [`Option<T>`](./../move-basics/option) when `T` has `drop`
- [`String`](./../move-basics/string)
- [`TypeName`](./../move-basics/type-reflection)

Note the pattern in the list: a container type like `vector` or `Option` can only be dropped when
its contents can. If the elements of a vector are protected from being discarded, the vector
holding them is protected too - otherwise dropping the container would be a loophole for dropping
the contents.

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.
