---
description: "Introduction to Move abilities: copy, drop, key, and store — the system that controls how types behave in smart contracts."
---

# Abilities: Introduction

Move has a unique type system in which each type declares what its values are allowed to do. In the
[previous section](./struct), every instance of `Artist` and `Record` had to be used: stored,
passed on, or unpacked - discarding a value, or copying it, was not an option. This is not
accidental strictness. By default, a Move value can only be created, moved around, and taken apart;
everything beyond that is a privilege the type must be granted explicitly. These privileges are
called _abilities_.

## What are Abilities?

Abilities are permissions on a type. They are declared as a part of the struct definition, and the
compiler rejects any operation the type is not permitted to perform. An ability does not add any
functionality to the type itself - it unlocks behavior that is otherwise a compile error.

There are four abilities in Move. Two of them control what can happen to a value during execution:

- `copy` - the value can be _duplicated_;
- `drop` - the value can be _discarded_;

and two control storage:

- `key` - the value can be a unit of storage - on Sui, an _object_;
- `store` - the value can be stored _inside_ other values in storage.

This "deny by default" design is what allows Move types to model assets faithfully: a type without
`copy` cannot be duplicated, and a type without `drop` cannot be lost - guarantees that a language
with ordinary, freely copyable values cannot give.

> Throughout the book you will see sections named `Ability: <name>`, each covering one ability in
> detail: how it works, and when to use it.

## Abilities Syntax

Abilities are set in the struct definition using the `has` keyword followed by a comma-separated
list of abilities:

```move file=packages/samples/sources/move-basics/abilities-introduction.move anchor=definition

```

The two declared abilities change how instances of `VeryAble` behave. Compare the following code to
the pack-and-unpack ceremony from the [previous section](./struct):

```move file=packages/samples/sources/move-basics/abilities-introduction.move anchor=use

```

Now, let's take a quick tour of all four abilities, one at a time.

## `drop`: Discarding Values

The `drop` ability allows an instance to be _discarded_: assigned to an unused variable, ignored
with the `_` wildcard, or simply left behind when the scope ends. In other words, `drop` makes a
type behave the way values behave in most other programming languages. It belongs on types that
represent plain _data_, and its absence protects types that represent _assets_. The
[next section](./drop-ability) is dedicated to it.

## `copy`: Duplicating Values

The `copy` ability allows an instance to be _duplicated_, implicitly by the compiler or explicitly
with the `copy` keyword. All the primitive types - integers, `bool`, `address` - behave as if they
have it. Note that `copy` almost always comes together with `drop`: a value that can be duplicated
but not discarded would force every one of its copies to be used. The details are covered in the
[Ability: Copy](./copy-ability) section.

## `key`: Objects and Storage

The `key` ability marks a type as a _unit of storage_: an instance can be written to the blockchain
state and later found by its unique identifier - its "key". On Sui, a struct with the `key` ability
is called an _object_, and it is required to have an `id: UID` as its first field. Objects are the
heart of the Sui programming model, and the whole [Object Model](./../object/) chapter is dedicated
to them, followed by [Ability: Key](./../storage/key-ability) covering the ability itself.

## `store`: Storing Inside Objects

The `store` ability allows an instance to be stored _inside_ other structs that end up in storage.
While `key` makes a type a top-level record in the blockchain state, `store` permits a type to be a
_part_ of one. It is explained in the [Ability: Store](./../storage/store-ability) section.

## Abilities Come from Fields

An ability is a promise about the whole value, including its contents - so a struct can only be
granted an ability that all of its field types support. A struct with `copy` requires every field to
have `copy`, and the same holds for `drop` and `store`; `key` requires every field to have `store`.
The compiler enforces this at the definition site, and the following code will not compile:

```move
public struct NoAbilities {}

public struct Wrapper has copy, drop {
    inner: NoAbilities,
    //     ^ error! The struct was declared with the ability 'copy'
    //       so all fields require the ability 'copy'
}
```

> All of the built-in types except [references](./references) have the `copy`, `drop`, and `store`
> abilities, and references have `copy` and `drop`. Container types like [`vector`](./vector) and
> [`Option`](./option) support `copy`, `drop`, and `store` _conditionally_ - a vector can only be
> copied if its elements can.

## No Abilities

A struct without abilities cannot be discarded, copied, or stored in storage. We call such a struct
a _Hot Potato_. A lighthearted name, but it is a good way to remember that a struct without
abilities is like a hot potato - it can only be passed around and requires special handling. The Hot
Potato is one of the most powerful patterns in Move, and we go into more detail about it in the
[Hot Potato Pattern](./../programmability/hot-potato-pattern) chapter.

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.
