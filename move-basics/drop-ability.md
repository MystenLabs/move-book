> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Abilities: Drop

The `drop` ability - the simplest of them - allows the instance of a struct to be _ignored_ or
_discarded_. In many programming languages this behavior is considered default. However, in Move, a
struct without the `drop` ability is not allowed to be ignored. This is a safety feature of the Move
language, which ensures that all assets are properly handled. An attempt to ignore a struct without
the `drop` ability will result in a compilation error.

```move
module book::drop_ability;

/// This struct has the `drop` ability.
public struct IgnoreMe has drop {
    a: u8,
    b: u8,
}

/// This struct does not have the `drop` ability.
public struct NoDrop {}

#[test]
// Create an instance of the `IgnoreMe` struct and ignore it.
// Even though we constructed the instance, we don't need to unpack it.
fun test_ignore() {
    let no_drop = NoDrop {};
    let _ = IgnoreMe { a: 1, b: 2 }; // no need to unpack

    // The value must be unpacked for the code to compile.
    let NoDrop {} = no_drop; // OK
}
```

The `drop` ability is often used on custom collection types to eliminate the need for special
handling of the collection when it is no longer needed. For example, a `vector` type has the `drop`
ability, which allows the vector to be ignored when it is no longer needed. However, the biggest
feature of Move's type system is the ability to not have `drop`. This ensures that the assets are
properly handled and not ignored.

A struct with a single `drop` ability is called a _Witness_. We explain the concept of a _Witness_
in the [Witness and Abstract Implementation](./../programmability/witness-pattern) section.

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

## Further Reading

- [Type Abilities](./../../reference/abilities) in the Move Reference.
