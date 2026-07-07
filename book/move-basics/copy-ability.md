---
description: "The copy ability in Move enables value duplication. Learn how to add copy to custom types and understand its role in resource safety."
---

# Abilities: Copy

In the [Ownership and Scope](./ownership-and-scope) section, we saw that primitive values are
_copied_ rather than moved: assigning a number to a new variable leaves both variables usable.
The `copy` ability is precisely what enables this behavior - and while it is built into the
primitive types, it is _not_ the default for custom types. Move is designed to express digital
assets and resources, and a resource that could be freely duplicated would not be much of a
resource. Duplication is therefore something a type must explicitly opt into:

```move file=packages/samples/sources/move-basics/copy-ability.move anchor=copyable

```

Once a type has the `copy` ability, its values are copied wherever a move would otherwise happen
and the original is still needed - implicitly, without any special syntax. The `copy` keyword can
be used to spell the copy out explicitly:

```move file=packages/samples/sources/move-basics/copy-ability.move anchor=copyable_test

```

In the example above, `a` is copied into `b` implicitly - the compiler sees that `a` is used again
afterwards, and copies the value instead of moving it. Then `a` is copied into `c` explicitly with
the `copy` keyword. After the three assignments, there are three independent instances of
`Copyable` - and each of them has to be dealt with separately.

> Note the unpacking at the end of the example: `Copyable` has `copy`, but not `drop`, so every
> instance - including each copy - must be used, and the test unpacks all three. Copying a value
> never bypasses the usage rules; it just creates more values to which those rules apply.

## Copying and Drop

As the example shows, `copy` without `drop` is a rather inconvenient combination: duplication is
allowed, but every duplicate still demands explicit handling. This is why the two abilities almost
always go together - a value that is cheap to duplicate is, in practice, always fine to discard.
Types that carry plain data, rather than assets, typically declare both:

```move file=packages/samples/sources/move-basics/copy-ability.move anchor=copy_drop

```

All of the primitive types behave as if they have `copy` and `drop`: they are copied on
assignment and discarded without a second thought - with the compiler managing all of it.

Copying is not the only way to let several parts of a program read the same value. In the
[References](./references) section, we show how a value can be _borrowed_ instead, avoiding the
duplication altogether; and how the [dereference operator](./references#dereferencing) `*` turns a
reference back into a copy, which is only permitted for types with the `copy` ability.

## Types with the `copy` Ability

All native types in Move have the `copy` ability. This includes:

- [`bool`](./../move-basics/primitive-types#booleans)
- [unsigned integers](./../move-basics/primitive-types#integer-types)
- [`vector<T>`](./../move-basics/vector) when `T` has `copy`
- [`address`](./../move-basics/address)

All of the types defined in the standard library have the `copy` ability as well. This includes:

- [`Option<T>`](./../move-basics/option) when `T` has `copy`
- [`String`](./../move-basics/string)
- [`TypeName`](./../move-basics/type-reflection)

Just like with [`drop`](./drop-ability#types-with-the-drop-ability), container types are only
copyable when their contents are: a `vector<T>` can be duplicated only if duplicating `T` is
allowed in the first place.

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.
