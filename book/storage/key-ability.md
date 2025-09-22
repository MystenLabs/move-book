# Ability: Key

In the [Basic Syntax][basic-syntax] chapter, we already covered two out of four abilities:
[Drop][drop-ability] and [Copy][copy-ability]. They affect the behavior of a value in a scope and
are not directly related to storage. Now it is time to cover the `key` ability, which allows a
struct to be _stored_.

Historically, the `key` ability was created to mark a type as a _key in storage_. A type with the
`key` ability could be stored at the top level in global storage and could be _owned_ by an account
or address. With the introduction of the [Object Model][object-model], the `key` ability became the
defining ability for _objects_.

> Later in the book, we will refer to any struct with the `key` ability as an Object.

## Object Definition

A struct with the `key` ability is considered _an object_ and can be used in storage functions. The
Sui Verifier requires the first field of the struct to be named `id` and to have the type `UID`.
Additionally, it requires all fields to have the `store` ability — we’ll explore it in detail [on
the next page][store-ability].

```move
/// `User` object definition.
public struct User has key {
    id: UID, // required by Sui Bytecode Verifier
    name: String, // field types must have `store`
}

/// Creates a new instance of the `User` type.
/// Uses the special struct `TxContext` to derive a Unique ID (UID).
public fun new(name: String, ctx: &mut TxContext): User {
    User {
        id: object::new(ctx), // creates a new UID
        name,
    }
}
```

## Relation to `copy` and `drop`

`UID` is a type that does not have the [`drop`][drop-ability] or [`copy`][copy-ability] abilities.
Since it is required as a field of any type with the `key` ability, this means that types with `key`
can never have `drop` or `copy`.

This property can be leveraged in [ability constraints][generics]: requiring `drop` or `copy`
automatically excludes `key`, and conversely, requiring `key` excludes types with `drop` or `copy`.

## Types with the `key` Ability

Due to the `UID` requirement for types with `key`, none of the native types in Move can have the
`key` ability, nor can any of the types in the [Standard Library][standard-library]. The `key`
ability is present only in some [Sui Framework][sui-framework] types and in custom types.

## Summary

- The `key` ability defines an object
- The first field of an object must be `id` with type `UID`
- Fields of a `key` type must the have [`store`][store-ability] ability
- Objects cannot have [`drop`][drop-ability] or [`copy`][copy-ability]

## Next Steps

The `key` ability defines objects in Move and forces the fields to have `store`. In the next section
we cover the `store` ability to later explain how [storage operations](./storage-functions.md) work.

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.

[drop-ability]: ./../move-basics/drop-ability
[copy-ability]: ./../move-basics/copy-ability
[store-ability]: ./store-ability.md
[generics]: ./../move-basics/generics#constraints-on-type-parameters
[sui-framework]: ./../programmability/sui-framework
[standard-library]: ./../move-basics/standard-library
[object-model]: ./../object
[basic-syntax]: ./../move-basics
