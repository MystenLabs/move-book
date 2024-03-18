# Abilities: Drop

<!-- TODO: reiterate, given that we introduce abilities one by one -->

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

Move has a unique type system which allows defining *type abilities*. [In the previous section](./struct.md), we introduced the `struct` definition and how to use it. However, the instances of the `Artist` and `Record` structs had to be unpacked for the code to compile. This is default behavior of a struct without *abilities*. In this section, we introduce the first ability - `drop`.

## Abilities syntax

Abilities are set in the struct definition using the `has` keyword followed by a list of abilities. The abilities are separated by commas. Move supports 4 abilities: `copy`, `drop`, `key`, and `store`. In this section, we cover the first two abilities: `copy` and `drop`. The last two abilities are covered [in the programmability chapter](./../programmability/README.md), when we introduce Objects and storage operations.

```move
/// This struct has the `copy` and `drop` abilities.
struct VeryAble has copy, drop {
    // field: Type1,
    // field2: Type2,
    // ...
}
```

## No abilities

A struct without abilities cannot be discarded, or copied, or stored in the storage. We call such a struct a *Hot Potato*. It is a joke, but it is also a good way to remember that a struct without abilities is like a hot potato - it needs to be passed around and handled properly. Hot Potato is one of the most powerful patterns in Move, we go in detail about it in the [TODO: authorization patterns](./../programmability/authorization-patterns.md) chapter.

## Drop ability

The `drop` ability - the simplest of them - allows the instance of a struct to be *ignored* or *discarded*. In many programming languages this behavior is considered default. However, in Move, a struct without the `drop` ability is not allowed to be ignored. This is a safety feature of the Move language, which ensures that all assets are properly handled. An attempt to ignore a struct without the `drop` ability will result in a compilation error.

```move
module book::drop_ability {

    /// This struct has the `drop` ability.
    struct IgnoreMe has drop {
        a: u8,
        b: u8,
    }

    /// This struct does not have the `drop` ability.
    struct NoDrop {}

    #[test]
    // Create an instance of the `IgnoreMe` struct and ignore it.
    // Even though we constructed the instance, we don't need to unpack it.
    fun test_ignore() {
        let no_drop = NoDrop {};
        let _ = IgnoreMe { a: 1, b: 2 }; // no need to unpack

        // The value must be unpacked for the code to compile.
        let NoDrop {} = no_drop; // OK
    }
}
```

The `drop` ability is often used on custom collection types to eliminate the need for special handling of the collection when it is no longer needed. For example, a `vector` type has the `drop` ability, which allows the vector to be ignored when it is no longer needed. However, the biggest feature of Move's type system is the ability to not have `drop`. This ensures that the assets are properly handled and not ignored.

A struct with a single `drop` ability is called a *Witness*. We explain the concept of a *Witness* in the [Witness and Abstract Implementation](./../programmability/witness-and-abstract-implementation.md) section.
