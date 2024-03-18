# Option

Option is a type that represents an optional value which may or may not exist. The concept of Option in Move is borrowed from Rust, and it is a very useful primitive in Move. `Option` is defined in the Standard Library, and is defined as follows:

```move
/// Abstraction of a value that may or may not be present.
struct Option<Element> has copy, drop, store {
    vec: vector<Element>
}
```

The `Option` is a generic type which takes a type parameter `Element`. It has a single field `vec` which is a `vector` of `Element`. Vector can have length 0 or 1, and this is used to represent the presence or absence of a value.

Option type has two variants: `Some` and `None`. `Some` variant contains a value and `None` variant represents the absence of a value. The `Option` type is used to represent the absence of a value in a type-safe way, and it is used to avoid the need for empty or `undefined` values.

## In Practice

To showcase why Option type is necessary, let's look at an example. Consider an application which takes a user input and stores it in a variable. Some fields are required, and some are optional. For example, a user's middle name is optional. While we could use an empty string to represent the absence of a middle name, it would require extra checks to differentiate between an empty string and a missing middle name. Instead, we can use the `Option` type to represent the middle name.

```move
module book::user_registry {
    use std::string::String;
    use std::option::Option;

    /// A struct representing a user record.
    struct User has copy, drop {
        first_name: String,
        middle_name: Option<String>,
        last_name: String,
    }

    /// Create a new `User` struct with the given fields.
    public fun register(
        first_name: String,
        middle_name: Option<String>,
        last_name: String,
    ): User {
        User { first_name, middle_name, last_name }
    }
}
```

In the example above, the `middle_name` field is of type `Option<String>`. This means that the `middle_name` field can either contain a `String` value or be empty. This makes it clear that the middle name is optional, and it avoids the need for extra checks to differentiate between an empty string and a missing middle name.

## Using Option

To use the `Option` type, you need to import the `std::option` module and use the `Option` type. You can then create an `Option` value using the `some` or `none` methods.

```move
use std::option;

// `option::some` creates an `Option` value with a value.
let opt_name = option::some(b"Alice");

// `option.is_some()` returns true if option contains a value.
assert!(opt_name.is_some(), 1);

// internal value can be `borrow`ed and `borrow_mut`ed.
assert!(option.borrow() == &b"Alice", 0);

// `option.extract` takes the value out of the option.
let inner = opt_name.extract();

// `option.is_none()` returns true if option is None.
assert!(opt_name.is_none(), 2);
```
