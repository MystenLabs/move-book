# Ability: Store

The [`key` ability][key-ability] requires all fields to have `store`, which defines what the `store`
ability means: it is the ability to serve as a field of an object. A struct with
[`copy`][copy-ability] or [`drop`][drop-ability] but without `store` can never be _stored_. A type
with `key` but without `store` cannot be wrapped - used as a field—in another object, and is
constrained to always remain at the top level.

## Definition

The `store` ability allows a type to be used as a field in a struct with the `key` ability.

```move
// hidden-block-start
use std::string::String;

// hidden-block-end
/// Extra metadata with `store`; all fields must have `store` as well!
public struct Metadata has store {
    bio: String,
}

/// An object for a single user record.
public struct User has key {
    id: UID,
    name: String,       // String has `store`
    age: u8,            // All integers have `store`
    metadata: Metadata, // Another type with the `store` ability
}
```

## Relation to `copy` and `drop`

All three non-`key` abilities can be used in any combination.

## Relation to `key`

An object with the `store` ability can be _stored_ in other objects.

> While not a language or verifier feature, `store` acts as a _public_ modifier on a struct,
> allowing calling _public_ [transfer functions](./storage-functions.md) which do not have an
> [internal constraint](./internal-constraint.md).

## Types with the `store` Ability

All native types (except references) in Move have the `store` ability. This includes:

- [bool](./../move-basics/primitive-types#booleans)
- [unsigned integers](./../move-basics/primitive-types#integer-types)
- [vector](./../move-basics/vector)
- [address](./../move-basics/address)

All of the types defined in the standard library have the `store` ability as well. This includes:

- [Option](./../move-basics/option)
- [String](./../move-basics/string) and [ASCII String](./../move-basics/string)
- [TypeName](./../move-basics/type-reflection)

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.

[key-ability]: ./key-ability.md
[drop-ability]: ./../move-basics/drop-ability
[copy-ability]: ./../move-basics/copy-ability
