---
description: "The key ability in Move makes a struct an object that can be stored, owned, and transferred on the Sui blockchain."
---

# Ability: Key

In the [Move Basics][basic-syntax] chapter, we covered two of the four abilities -
[Drop][drop-ability] and [Copy][copy-ability]. They affect the behavior of a value within a scope,
and are not related to storage. Now it is time to cover the `key` ability - the ability that
allows a struct to become a unit of storage.

Historically, the `key` ability was created to mark a type as a _key in global storage_. A type
with the `key` ability could be stored at the top level and could be _owned_ by an account or
address. With the introduction of the [Object Model][object-model], the `key` ability became the
defining ability for _objects_.

> Throughout the book, we refer to any struct with the `key` ability as an _object_.

## Object Definition

A struct with the `key` ability is an object, and can be used in
[storage functions](./storage-functions). Two layers of rules apply to its definition:

- The Move language requires every field of a `key` struct to have the [`store`][store-ability]
  ability - we explore `store` on the next page;
- The Sui Verifier additionally requires the first field of the struct to be named `id` and to
  have the type `UID`.

```move file=packages/samples/sources/storage/key-ability.move anchor=user

```

The `new` function creates the object. A fresh `UID` can only be produced by `object::new`, which
takes a mutable reference to the [transaction context](./../programmability/transaction-context) -
so every newly created object gets an identifier that has never existed on the network before. We
look closer at the `UID` type and its guarantees in the [UID and ID](./uid-and-id) section.

## Relation to `copy` and `drop`

`UID` is a type that has neither [`drop`][drop-ability] nor [`copy`][copy-ability]. Since every
object is required to have a `UID` field, and a struct can only have an ability its fields
support, this means that objects can never have `drop` or `copy`. Every object is
non-discardable and non-copyable by construction - which is exactly what the
[asset properties](./../object/digital-assets) demand.

This property can be leveraged in [ability constraints][generics]: requiring `drop` or `copy`
automatically excludes objects, and conversely, requiring `key` excludes types with `drop` or
`copy`.

## Types with the `key` Ability

Due to the `UID` requirement, none of the native types in Move can have the `key` ability, nor can
any of the types in the [Standard Library][standard-library]. The `key` ability is present only in
some [Sui Framework][sui-framework] types and in custom types.

## Summary

- The `key` ability defines an object.
- The Sui Verifier requires the first field of an object to be `id` of type `UID`.
- The Move language requires all fields of a `key` struct to have [`store`][store-ability].
- Objects can never have [`drop`][drop-ability] or [`copy`][copy-ability].

## Next Steps

The `key` ability defines objects and forces all fields to have `store`. In the next section, we
look at the `store` ability itself - and at the second, less obvious role it plays for objects.

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.

[drop-ability]: ./../move-basics/drop-ability
[copy-ability]: ./../move-basics/copy-ability
[store-ability]: ./store-ability
[generics]: ./../move-basics/generics#constraints-on-type-parameters
[sui-framework]: ./../programmability/sui-framework
[standard-library]: ./../move-basics/standard-library
[object-model]: ./../object
[basic-syntax]: ./../move-basics
