# Ability: Store

Now that you have an understanding of the [top-level storage functions](./storage-functions.md)
which are enabled by the [`key`](./key-ability.md) ability, we can talk about the last ability in
the list - `store`.

## Definition

The `store` is an ability that allows a type to be _stored_ inside other objects. This ability is
required for the type to be used as a field in a struct that has the `key` ability. Another way to
put it is that the `store` ability allows the value to be _wrapped_ in an object.

> The `store` ability also relaxes restrictions on transfer operations. We talk about it more in the
> [Restricted and Public Transfer](./restricted-and-public-transfer.md) section.

## Example

In previous sections we already used types with the `store` ability: all objects must have a `UID`
field, which we used in examples; we also used the `String` type as a part of the `Config` struct.
The `String` type also has the `store` ability.

```move
{{#include ../../../packages/samples/sources/storage/store-ability.move:store}}
```

## Types with the `store` Ability

All native types (except for references) in Move have the `store` ability. This includes:

- [bool](./../move-basics/primitive-types.md#booleans)
- [unsigned integers](./../move-basics/primitive-types.md#integers)
- [vector](./../move-basics/vector.md)
- [address](./../move-basics/address.md)

All of the types defined in the standard library have the `store` ability as well. This includes:

- [Option](./../move-basics/option.md)
- [String](./../move-basics/string.md) (both ASCII and UTF-8)
- [TypeName](./../move-basics/type-reflection.md#typename)

## Further reading

- [Type Abilities](/reference/type-abilities.html) in the Move Reference.
