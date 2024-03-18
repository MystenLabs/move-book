# Dynamic Fields

Sui Object model allows objects to be attached to other objects as *dynamic fields*. The behavior is similar to how a `Map` works in other programming languages, however, the types of attached objects can be any. This allows for a wide range of use cases, such as attaching an accessory to a character, or storing large, non-heterogeneous collections in a single object.

## Structure

Dynamic fields are attached to an object via a *key*, which can be any type with the *store*, *copy* and *drop* abilities. The key is used to access the attached object, and can be used to update or remove it. The attached object can be any type, if it has the *store* ability.

<!-- In practice, the representation of an object is its UID, so dynamic fields are attached not to the object itself, but to its UID. This means two things: first, dynamic fields can be attached to an object, and second - they can be attached to a UID directly. -->

## Usage

Dynamic fields are defined in the `sui::dynamic_field` module.

```move
module book::accessories {

    struct Character has key {
        id: UID,
        name: String
    }

    /// An accessory that can be attached to a character.
    struct Accessory has store {
        type: String,
        name: String,
    }
}
```

## Dynamic Object Fields

TODO:
- dynamic object fields
- discoverability benefits of DOFs

## Custom Fields for Keys

TODO: explain how custom fields ca

## Applications

Dynamic fields are used for:

- Heterogeneous collections
- Storing large data that does not fit into the object limit size
- Attaching objects to other objects as a part of application logic
- Extending existing types with additional data
- Storing data that is not always present
