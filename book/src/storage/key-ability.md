# The Key Ability

In the [Basic Syntax](./../basic-syntax) chapter we already covered two out of four abilities - [Drop](./drop-ability.md) and [Copy](./copy-ability.md). They affect the behaviour of the value in a scope and are not directly related to storage. It is time to cover the `key` ability, which allows the struct to be stored.

Historically, the `key` ability was created to mark the type as a *key in the storage*. A type with the `key` ability could be stored at top-level in the storage, and could be *directly owned* by an account or address. With the introduction of the [Object Model](./../object), the `key` ability naturally became the defining ability for the object.

<!-- TODO: What is Sui Verifier - link, later -->

## Object Definition

A struct with the `key` ability is considered an object and can be used in the storage functions. The Sui Verifier will require the first field of the struct to be named `id` and have the type `UID`.

```move
public struct Object has key {
    id: UID, // required
    name: String,
}

/// Creates a new Object with a Unique ID
public fun new(name: String, ctx: &mut TxContext): Object {
    Object {
        id: object::new(ctx), // creates a new UID
        name,
    }
}
```

A struct with the `key` ability is still a struct, and can have any number of fields and associated functions. There is no special handling or syntax for packing, accessing or unpacking the struct.

However, because the first field of an object struct must be of type `UID` - a non-copyable and non-droppable type, the struct transitively cannot have `drop` and `copy` abilities. Thus, the object is non-discardable by design.

## Asset Definition

In the context of the [Object Model](./../object/digital-assets.md), an object with the `key` ability can be considered an asset. It is non-discardable, unique, and can be *owned*.

## Next Steps

In the next chapter, we will cover the [UID](./uid-and-id.md) - the most important type in the Sui storage model.
