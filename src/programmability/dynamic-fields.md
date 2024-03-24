# Dynamic Fields

Sui Object model allows objects to be attached to other objects as *dynamic fields*. The behavior is similar to how a `Map` works in other programming languages. However, unlike a `Map` which in Move would be strictly typed (we have covered it in the [Collections](./collections.md) section), dynamic fields allow attaching objects of any type.

> There's no limit to the number of dynamic fields that can be attached to an object. Thus, dynamic fields can be used to store large amounts of data that don't fit into the object limit size.

Dynamic Fields allow for a wide range of applications, from splitting data into smaller parts to avoid [object size limit](./../guides/building-against-limits.md) to attaching objects as a part of application logic.

## Definition

Dynamic Fields are defined in the `sui::dynamic_field` module of the [Sui Framework](./sui-framework.md). They are attached to object's `UID` via a *name*, and can be accessed using that name. There can be only one field with a given name attached to an object.

File: sui-framework/sources/dynamic_field.move
```move
/// Internal object used for storing the field and value
public struct Field<Name: copy + drop + store, Value: store> has key {
    /// Determined by the hash of the object ID, the field name
    /// value and it's type, i.e. hash(parent.id || name || Name)
    id: UID,
    /// The value for the name of this field
    name: Name,
    /// The value bound to this field
    value: Value,
}
```

As the definition shows, dynamic fields are stored in an internal `Field` object, which has the `UID` generated in a deterministic way based on the object ID, the field name, and the field type. The `Field` object contains the field name and the value bound to it. The constraints on the `Name` and `Value` type parameters define the abilities that the key and value must have.

## Usage

The methods available for dynamic fields are straightforward: a field can be added with `add`, removed with `remove`, and read with `borrow` and `borrow_mut`. Additionally, the `exists_` method can be used to check if a field exists (for stricter checks with type, there is an `exists_with_type` method).

```move
module book::dynamic_collection {
    // a very common alias for `dynamic_field` is `df` since the
    // module name is quite long
    use sui::dynamic_field as df;

    /// The object that we will attach dynamic fields to.
    public struct Character has key {
        id: UID
    }

    // List of different accessories that can be attached to a character.
    // They must have the `store` ability.
    public struct Hat has key, store { id: UID, color: u32 }
    public struct Mustache has key, store { id: UID }

    #[test]
    fun test_character_and_accessories() {
        let ctx = &mut tx_context::dummy();
        let character = Character { id: object::new(ctx) };

        // Attach a hat to the character's UID
        df::add(
            &mut character.id,
            b"hat_key",
            Hat { id: object::new(ctx), color: 0xFF0000 }
        );

        // Similarly, attach a mustache to the character's UID
        df::add(
            &mut character.id,
            b"mustache_key",
            Mustache { id: object::new(ctx) }
        );

        // Check that the hat and mustache are attached to the character
        //
        assert!(df::exists_(&character.id, b"hat_key"), 0);
        assert!(df::exists_(&character.id, b"mustache_key"), 1);

        // Modify the color of the hat
        let hat: &mut Hat = df::borrow_mut(&mut character.id, b"hat_key");
        hat.color = 0x00FF00;

        // Remove the hat and mustache from the character
        let hat = df::remove(&mut character.id, b"hat_key");
        let mustache = df::remove(&mut character.id, b"mustache_key");

        // Check that the hat and mustache are no longer attached to the character
        assert!(!df::exists_(&character.id, b"hat_key"), 0);
        assert!(!df::exists_(&character.id, b"mustache_key"), 1);

        sui::test_utils::destroy(character);
        sui::test_utils::destroy(mustache);
        sui::test_utils::destroy(hat);
    }
}
```

In the example above, we define a `Character` object and two different types of accessories that could never be put together in a vector. However, dynamic fields allow us to store them together in a single object. Both objects are attached to the `Character` via a `vector<u8>` (bytestring literal), and can be accessed using their respective keys.

As you can see, when we attached the accessories to the Character, we passed them *by value*. In other words, both values were moved to a new scope, and their ownership was transferred to the `Character` object. If we changed the ownership of `Character` object, the accessories would have been moved with it.

And the last important property of dynamic fields we should highlight is that they are *accessed through their parent*. This means that the `Hat` and `Mustache` objects are not directly accessible and follow the same rules as the parent object.

## Foreign Types as Dynamic Fields

Dynamic fields allow objects to carry data of any type, including those defined in other modules. This is possible due to their generic nature and relatively weak constraints on the type parameters. Let's illustrate this by attaching a few different values to a `Character` object.

```move
let ctx = tx_context::dummy();
let character = Character { id: object::new(ctx) };

// Attach a `String` via a `vector<u8>` name
df::add(&mut character.id, b"string_key", b"Hello, World!".to_string());

// Attach a `u64` via a `u32` name
df::add(&mut character.id, 1000u32, 1_000_000_000u64);

// Attach a `bool` via a `bool` name
df::add(&mut character.id, true, false);
```

In this example we showed how different types can be used for both *name* and the *value* of a dynamic field. The `String` is attached via a `vector<u8>` name, the `u64` is attached via a `u32` name, and the `bool` is attached via a `bool` name. Anything is possible with dynamic fields!

## Orphaned Dynamic Fields

> To prevent orphaned dynamic fields, please, use [Dynamic Collection Types](./dynamic-collections.md) such as `Bag` as they track the dynamic fields and won't allow unpacking if there are attached fields.

The `object::delete()` function, which is used to delete a UID, does not track the dynamic fields, and cannot prevent dynamic fields from becoming orphaned. Once the parent UID is deleted, the dynamic fields are not automatically deleted, and they become orphaned. This means that the dynamic fields are still stored in the blockchain, but they will never become accessible again.

```move
// ! DO NOT do this in your code:
let ctx = tx_context::dummy();
let hat = Hat { id: object::new(ctx), color: 0xFF0000 };
let character = Character { id: object::new(ctx) };

// Attach a `Hat` via a `vector<u8>` name
df::add(&mut character.id, b"hat_key", hat);

// ! Danger - deleting the parent object
let Character { id } = character;
id.delete();

// ...`Hat` is now stuck in a limbo, it will never be accessible again
```

Orphaned objects are not a subject to storage rebate, and the storage fees will remain unclaimed.

## Exposing UID

Because dynamic fields are attached to `UID`s, their usage in other modules depends on whether the `UID` is exposed as a reference or a mutable reference. By default struct visibility protects the `id` field and won't let other modules access it directly. However, if there's a public accessor method that returns a reference to `UID` (or a mutable reference), dynamic fields can be accessed from other modules.

> Please, remember, that `&mut UID` access affects not only dynamic fields, but also [Transfer to Object](./object/transfer-to-object.md) and [Dynamic Object Fields](#dynamic-object-fields). Should you decide to expose the `UID` as a mutable reference, make sure to understand the implications.

```move
/// Exposes the UID of the character, so that other modules can add, remove
/// and modify dynamic fields.
public fun uid_mut(c: &mut Character): &mut UID {
    &mut c.id
}

/// Exposes the UID of the character, so that other modules can read
/// dynamic fields.
public fun uid(c: &Character): &UID {
    &c.id
}
```

In the example above, we show how to expose the `UID` of a `Character` object. This solution may work for some applications, however, it is imporant to remember that the exposed `UID` can be a security risk. Especially, if the object's dynamic fields are not supposed to be modified by other modules.

If you need to expose the `UID` within the package, consider using a more restrictive access control, like `public(package)`, or even better - use more specific accessor methods that would allow only reading specific fields.

## Custom Type as a Field Name

In the examples above, we used primitive types as field names since they have the required set of abilities. But dynamic fields get even more interesting when we use custom types as field names. This allows for a more structured way of storing data, and also allows for protecting the field names from being accessed by other modules.

```move
/// A custom type with fields in it.
public struct AccessoryKey has copy, drop, store { name: String }

/// An empty key, can be attached only once.
public struct MetadataKey has copy, drop, store {}
```

Two field names that we defined above are `AccessoryKey` and `MetadataKey`. The `AccessoryKey` has a `String` field in it, hence it can be used multiple times with different `name` values. The `MetadataKey` is an empty key, and can be attached only once.

```move
let ctx = tx_context::dummy();
let character = Character { id: object::new(ctx) };

// Attaching via an `AccessoryKey { name: "hat" }`
df::add(
    &mut character.id,
    AccessoryKey { name: "hat".to_string() },
    Hat { id: object::new(ctx), color: 0xFF0000 }
);
// Attaching via an `AccessoryKey { name: "mustache" }`
df::add(
    &mut character.id,
    AccessoryKey { name: "mustache".to_string() },
    Mustache { id: object::new(ctx) }
);

// Attaching via a `MetadataKey`
df::add(&mut character.id, MetadataKey {}, 42);
```

As you can see, custom types do work as field names but as long as they can be *packed* by the module, in other words - if they are *internal* to the module and defined in it. This limitation on struct packing can play an important role in the design of the application, as the keys attached to the object can *never* be accessed from other modules.

This approach is used in the [Object Capability]() pattern, where an application can authorize a foreign object to perform operations in it while not exposing the capabilities to other modules.

## Applications

Dynamic Fields play a crucial role in the design of applications of any complexity. They allow storing heterogeneous data in a single object, so a marketplace of different objects can be built on top of a single object. Another important use case is the ability to define them *later*, which allows for extendable design patterns and more flexible applications. This last point allows for certain [upgradeability practices](./../guides/upgradeability-practices.md) to be implemented.

## Next Steps

In the next section we will cover [Dynamic Object Fields](./dynamic-object-fields.md) and explain how they differ from dynamic fields, and what are the implications of using them.
