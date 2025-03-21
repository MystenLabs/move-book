# Abilities: Drop

<!-- TODO: reiterate, given that we introduce abilities one by one -->

<!-- TODO:

- introduce abilities first
- mention them all
- then do one by one

consistency: we / I / you ?
who is we? I am alone, there's no one else here


-->

<!--

// Shall we only talk about `drop` ?
// So that we don't explain scopes and `copy` / `move` semantics just yet?

Chapter: Basic Syntax
Goal: Introduce Copy and Drop abilities of Move. Follows the `struct` section
Notes:
    - compare them to primitive types introduces before;
    - what is an ability without drop
    - drop is not necessary for unpacking
    - make a joke about a bacteria pattern in the code
    - mention that a struct with only `drop` ability is called a Witness
    - mention that a struct without abilities is called a Hot Potato
    - mention that there are two more abilities which are covered in a later chapter

Links:
    - language reference (abilities)
    - authorization patterns (or witness)
    - hot potato pattern
    - key and store abilities (later chapter)

 -->

The `drop` ability - the simplest of them - allows the instance of a struct to be _ignored_ or
_discarded_. In many programming languages this behavior is considered default. However, in Move, a
struct without the `drop` ability is not allowed to be ignored. This is a safety feature of the Move
language, which ensures that all assets are properly handled. An attempt to ignore a struct without
the `drop` ability will result in a compilation error.

```move
{{#include ../../../packages/samples/sources/move-basics/drop-ability.move:main}}
```

The `drop` ability is often used on custom collection types to eliminate the need for special
handling of the collection when it is no longer needed. For example, a `vector` type has the `drop`
ability, which allows the vector to be ignored when it is no longer needed. However, the biggest
feature of Move's type system is the ability to not have `drop`. This ensures that the assets are
properly handled and not ignored.

A struct with a single `drop` ability is called a _Witness_. We explain the concept of a _Witness_
in the
[Witness and Abstract Implementation](./../programmability/witness-pattern.md)
section.

## Types with the `drop` Ability

All native types in Move have the `drop` ability. This includes:

- [`bool`](./../move-basics/primitive-types.md#booleans)
- [unsigned integers](./../move-basics/primitive-types.md#integer-types)
- [`vector<T>`](./../move-basics/vector.md) when `T` has `drop`
- [`address`](./../move-basics/address.md)

All of the types defined in the standard library have the `drop` ability as well. This includes:

- [`Option<T>`](./../move-basics/option.md) when `T` has `drop`
- [`String`](./../move-basics/string.md)
- [`TypeName`](./../move-basics/type-reflection.md#typename)

## Further reading

- [Type Abilities](/reference/abilities.html) in the Move Reference.
