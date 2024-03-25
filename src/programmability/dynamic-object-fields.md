# Dynamic Object Fields

> This section expands on the [Dynamic Fields](./dynamic-fields.md). Please, read it first to understand the basics of dynamic fields.

Another variation of dynamic fields is *dynamic object fields*, which have certain differences from regular dynamic fields. In this section, we will cover the specifics of dynamic object fields and explain how they differ from regular dynamic fields.

> General recommendation is to avoid using dynamic object fields in favor of (just) dynamic fields, especially if there's no need for direct discovery through the ID. The extra costs of dynamic object fields may not be justified by the benefits they provide.

## Definition

Dynamic Object Fields are defined in the `sui::dynamic_object_fields` module in the [Sui Framework](./sui-framework.md). They are similar to dynamic fields in many ways, but unlike them, dynamic object fields have an extra constraint on the `Value` type. The `Value` must have a combination of `key` and `store`, not just `store` as in the case of dynamic fields.

They're less explicit in their framework definition, as the concept itself is more abstract:

File: sui-framework/sources/dynamic_object_fields.move
```move
/// Internal object used for storing the field and the name associated with the
/// value. The separate type is necessary to prevent key collision with direct
/// usage of dynamic_field
public struct Wrapper<Name> has copy, drop, store {
    name: Name,
}
```

Unlike `Field` type in the [Dynamic Fields](./dynamic-fields.md#definition) section, the `Wrapper` type only stores the name of the field. The value is the object itself, and is *not wrapped*.

The constraints on the `Value` type become visible in the methods available for dynamic object fields. Here's the signature for the `add` function:

```move
/// Adds a dynamic object field to the object `object: &mut UID` at field
/// specified by `name: Name`. Aborts with `EFieldAlreadyExists` if the object
/// already has that field with that name.
public fun add<Name: copy + drop + store, Value: key + store>(
    // we use &mut UID in several spots for access control
    object: &mut UID,
    name: Name,
    value: Value,
) { /* implementation omitted */ }
```

The rest of the methods which are identical to the ones in the [Dynamic Fields](./dynamic-fields.md#usage) section have the same constraints on the `Value` type. Let's list them for reference:

- `add` - adds a dynamic object field to the object
- `remove` - removes a dynamic object field from the object
- `borrow` - borrows a dynamic object field from the object
- `borrow_mut` - borrows a mutable reference to a dynamic object field from the object
- `exists_` - checks if a dynamic object field exists
- `exists_with_type` - checks if a dynamic object field exists with a specific type

Additionally, there is an `id` method which returns the `ID` of the `Value` object without specifying its type.

## Usage & Differences with Dynamic Fields

The main difference between dynamic fields and dynamic object fields is that the latter allows storing *only objects* as values. This means that you can't store primitive types like `u64` or `bool`. It may be considered a limitation, if not for the fact that dynamic object fields are *not wrapped* into a separate object.

> The relaxed requirement for wrapping keeps the object available for off-chain discovery via its ID. However, this property may not be outstanding if wrapped object indexing is implemented, making the dynamic object fields a redundant feature.

```move
module book::dynamic_object_field {
    // there are two common aliases for the long module name: `dof` and
    // `ofield`. Both are commonly used and met in different projects.
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;

    /// The `Character` that we will use for the example
    struct Character has key { id: UID }

    /// Metadata that doesn't have the `key` ability
    struct Metadata has store, drop { name: String }

    /// Accessory that has the `key` ability - an object.
    struct Accessory has key, store { id: UID }

    #[test]
    fun equip_accessory() {
        let ctx = &mut tx_context::dummy();
        let mut character = Character { id: object::new(ctx) };

        // Create an accessory and attach it to the character
        let hat = Accessory { id: object::new(ctx) };

        // Add the hat to the character. Just like with `dynamic_fields`
        dof::add(&mut character.id, b"hat_key", hat);

        // However for non-key structs we can only use `dynamic_field`
        df::add(&mut character.id, b"metadata_key", Metadata {
            name: b"John".to_string()
        });

        // Borrow the hat from the character
        let hat_id = dof::id(&character.id, b"hat_key").extract(); // Option<ID>
        let hat_ref: &Hat = dof::borrow(&character.id, b"hat_key");
        let hat_mut: &mut Hat = dof::borrow_mut(&mut character.id, b"hat_key");
        let hat: Hat = dof::remove(&mut character.id, b"hat_key");

        // Clean up, Metadata is an orphan now.
        sui::test_utils::destroy(hat);
        sui::test_utils::destroy(character);
    }
}
```

## Pricing Differences

Dynamic Object Fields come a little more exensive than dynamic fields. Because of their internal structure, they require 2 objects: the Wraper for Name and the Value. Because of this, the cost of adding and accessing object fields (loading 2 objects compared to 1 for dynamic fields) is higher.

## Next Steps

Both dynamic field and dynamic object fields are powerful features which allow for innovative solutions in applications. However, they are relatively low-level and require careful handling to avoid orphaned fields. In the next section, we will introduce a higher-level abstraction - [Dynamic Collections](./dynamic-collections.md) - which can help with managing dynamic fields and objects more effectively.
