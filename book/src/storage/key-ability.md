# Ability: Key

In the [Basic Syntax](./../move-basics) chapter we already covered two out of four abilities -
[Drop](./drop-ability.md) and [Copy](./copy-ability.md). They affect the behaviour of the value in a
scope and are not directly related to storage. Here, we introduce the `key` ability, which defines
the storage behaviour of a type.

Historically, the `key` ability was created to mark the type as a _key in the storage_. A type with
the `key` ability could be stored at top-level in the storage, and could be _directly owned_ by an
account or an address. With the introduction of the [Object Model](./../object), the `key` ability
naturally became the defining ability for the object.

<!-- TODO: What is Sui Verifier - link, later -->

## Object Definition

A struct with the `key` ability is considered an object and can be used in storage functions. The
Sui Verifier will require the first field of the struct to be named `id` and have the type `UID`.

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

A struct with the `key` ability is still a struct, and can have any number of fields and associated
functions. There is no special handling or syntax for packing, accessing or unpacking the struct.

However, because the first field of an object struct must be of type `UID` - a non-copyable and
non-droppable type (we will get to it very soon!), the struct transitively cannot have `drop` and
`copy` abilities. Thus, the object is non-discardable by design.

## Object Creation

New UID is generated using the `object::new` function as shown in the example above. The
`object::new` takes a mutable reference to the transaction context and returns a new UID. The UID is
unique within the scope of the transaction and is used as the `id` field of the object. The
`TxContext` is an argument that is passed to the function automatically by the execution layer. We
will cover them in more detail in the following chapters: [UID](./uid-and-id.md) and
[Transaction Context](./../storage/transaction-context.html).

> Both, the `sui::object` and `sui::tx_context` modules are implicitly imported by the compiler, so
> there is no need to import them explicitly. We explain it in more detail in the
> [Sui Framework](./../programmability/sui-framework.md) chapter.

## Types with the `key` Ability

Due to the `UID` requirement for types with `key`, none of the native types in Move can have the
`key` ability, nor can any of the [Standard Library](./../move-basics/standard-library.md) types.
The `key` ability is only present in the [Sui Framework](./../programmability/sui-framework.md) and
custom types.

## Next Steps

Key ability defines the object in Move, and objects are intended to be _stored_. In the next section
we present the `sui::transfer` module, which provides native storage functions for objects.

## Further reading

- [Type Abilities](/reference/type-abilities.html) in the Move Reference.
