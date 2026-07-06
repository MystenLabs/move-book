---
description: "The store ability in Move allows types to be used as fields in objects and enables public transfer and storage operations on Sui."
---

# Ability: Store

The [`key` ability][key-ability] requires all fields to have `store`, and that requirement is the
best way to understand what `store` means: it is the ability to be _stored_ - to end up inside an
object in the blockchain state. A struct with [`copy`][copy-ability] or [`drop`][drop-ability] but
without `store` can live only during the transaction that creates it; it can never be persisted.

## Definition

The `store` ability allows a type to be used as a field of a struct with the `key` ability -
directly, or nested any number of levels deep. Like with other abilities, the rule applies
recursively: a struct can only have `store` if all of its fields have `store`.

```move file=packages/samples/sources/storage/store-ability.move anchor=definition

```

## Relation to `copy` and `drop`

`store` is independent of `copy` and `drop`: the three non-`key` abilities can be combined freely,
and none of them implies another. A type may be copyable but not storable, storable but neither
copyable nor droppable, and so on - each combination is valid and has its uses.

## Relation to `key`

An _object_ can also have the `store` ability, and for objects it plays a double role:

- An object with `store` can be _wrapped_: used as a field of another object. An object without
  `store` is constrained to always remain at the top level of storage.
- `store` acts as a _public_ modifier on the object: it permits calling the public
  [storage functions](./storage-functions) - `public_transfer`, `public_share_object`, and
  `public_freeze_object` - from _any_ module. Without `store`, storage operations on the object
  are reserved for its defining module, which keeps full control over how the object moves.

The second role is not a language feature but a convention of the [Sui Framework][sui-framework],
enforced through the [internal constraint](./internal-constraint) - the topic of the next section.
Whether to give an object `store` is one of the most consequential design decisions in a Sui
application, and we return to it in [Storage Functions](./storage-functions#internal-rule-in-transfer-functions).

## Types with the `store` Ability

All native types (except references) in Move have the `store` ability. This includes:

- [bool](./../move-basics/primitive-types#booleans)
- [unsigned integers](./../move-basics/primitive-types#integer-types)
- [`vector<T>`](./../move-basics/vector) when `T` has `store`
- [address](./../move-basics/address)

All of the types defined in the standard library have the `store` ability as well. This includes:

- [`Option<T>`](./../move-basics/option) when `T` has `store`
- [String](./../move-basics/string) and [ASCII String](./../move-basics/string#ascii-strings)
- [TypeName](./../move-basics/type-reflection)

## Summary

- `store` allows a type to be persisted - used as a field of an object, at any nesting depth.
- For objects, `store` additionally unlocks _wrapping_ and the public storage functions.
- `store` is independent of `copy` and `drop`; container types have it conditionally on their
  contents.

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.

[key-ability]: ./key-ability
[drop-ability]: ./../move-basics/drop-ability
[copy-ability]: ./../move-basics/copy-ability
[sui-framework]: ./../programmability/sui-framework
