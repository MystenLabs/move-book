# Abilities: Introduction

Move has a unique type system which allows customizing _type abilities_.
[In the previous section](./struct.md), we introduced the `struct` definition and how to use it.
However, the instances of the `Artist` and `Record` structs had to be unpacked for the code to
compile. This is default behavior of a struct without _abilities_.

> Throughout the book you will see chapters with name `Ability: <name>`, where `<name>` is the name
> of the ability. These chapters will cover the ability in detail, how it works, and how to use it
> in Move.

## What are Abilities?

Abilities are a way to allow certain behaviors for a type. They are a part of the struct declaration
and define which behaviors are allowed for the instances of the struct.

## Abilities syntax

Abilities are set in the struct definition using the `has` keyword followed by a list of abilities.
The abilities are separated by commas. Move supports 4 abilities: `copy`, `drop`, `key`, and
`store`. Each ability defines a specific behavior for the struct instances.

```move
/// This struct has the `copy` and `drop` abilities.
struct VeryAble has copy, drop {
    // field: Type1,
    // field2: Type2,
    // ...
}
```

## Overview

A quick overview of the abilities:

> All of the built-in types except [references](references.md) have `copy`, `drop` and `store` abilities.
> References have `copy` and `drop`.

- `copy` - allows the struct to be _copied_. Explained in the [Ability: Copy](./copy-ability.md)
  chapter.
- `drop` - allows the struct to be _dropped_ or _discarded_. Explained in the
  [Ability: Drop](./drop-ability.md) chapter.
- `key` - allows the struct to be used as a _key_ in a storage. Explained in the
  [Ability: Key](./../storage/key-ability.md) chapter.
- `store` - allows the struct to be _stored_ in structs that have the _key_ ability. Explained in the
  [Ability: Store](./../storage/store-ability.md) chapter.

While it is important to briefly mention them here, we will go into more detail about each ability in the following
chapters and give proper context on how to use them.

## No abilities

A struct without abilities cannot be discarded, copied, or stored in storage. We call such a
struct a _Hot Potato_. It is a joke, but it is also a good way to remember that a struct without
abilities is like a hot potato - it can only be passed around and requires special handling. The Hot
Potato is one of the most powerful patterns in Move, and we go into more detail about it in the
[Hot Potato Pattern](./../programmability/hot-potato-pattern.md) chapter.

## Further reading

- [Type Abilities](/reference/abilities.html) in the Move Reference.
