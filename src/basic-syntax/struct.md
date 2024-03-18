# Custom Types with Struct

Move type system shines when it comes to defining custom types. User defined types can be custom tailored to the specific needs of the application. Not just on the data level, but also in its behavior. In this section we introduce the struct definition and how to use it.

## Struct

To define a custom type, you can use the `struct` keyword followed by the name of the type. After the name, you can define the fields of the struct. Each field is defined with the `field_name: field_type` syntax. Field definitions must be separated by commas. The fields can be of any type, including other structs.

> Note: Move does not support recursive structs, meaning a struct cannot contain itself as a field.

```move
/// A struct representing an artist.
public struct Artist {
    /// The name of the artist.
    name: String,
}

/// A struct representing a music record.
public struct Record {
    /// The title of the record.
    title: String,
    /// The artist of the record. Uses the `Artist` type.
    artist: Artist,
    /// The year the record was released.
    year: u16,
    /// Whether the record is a debut album.
    is_debut: bool,
    /// The edition of the record.
    edition: Option<u16>,
}
```

In the example above, we define a `Record` struct with five fields. The `title` field is of type `String`, the `artist` field is of type `Artist`, the `year` field is of type `u16`, the `is_debut` field is of type `bool`, and the `edition` field is of type `Option<u16>`. The `edition` field is of type `Option<u16>` to represent that the edition is optional.

Structs are private by default, meaning they cannot be imported and used outside of the module they are defined in. Their fields are also private and can't be accessed from outside the module. See [visibility](./visibility.md) for more information on different visibility modifiers.

> A struct by default is *internal* to the module it is defined in.

## Create and use an instance

We described how struct *definition* works. Now let's see how to initialize a struct and use it. A struct can be initialized using the `struct_name { field1: value1, field2: value2, ... }` syntax. The fields can be initialized in any order, and all of the fields must be set.

```move
// Create an instance of the `Artist` struct.
let artist = Artist {
    name: string::utf8(b"The Beatles"),
};
```

In the example above, we create an instance of the `Artist` struct and set the `name` field to a string "The Beatles".

To access the fields of a struct, you can use the `.` operator followed by the field name.

```move
// Access the `name` field of the `Artist` struct.
let artist_name = artist.name;

// Access a field of the `Artist` struct.
assert!(artist.name == string::utf8(b"The Beatles"), 0);

// Mutate the `name` field of the `Artist` struct.
artist.name = string::utf8(b"Led Zeppelin");

// Check that the `name` field has been mutated.
assert!(artist.name == string::utf8(b"Led Zeppelin"), 1);
```

Only module defining the struct can access its fields (both mutably and immutably). So the above code should be in the same module as the `Artist` struct.

## Unpacking a struct

Structs are non-discardable by default, meaning that the initiated struct value must be used: either stored or *unpacked*. Unpacking a struct means deconstructing it into its fields. This is done using the `let` keyword followed by the struct name and the field names.

```move
// Unpack the `Artist` struct and create a new variable `name`
// with the value of the `name` field.
let Artist { name } = artist;
```

In the example above we unpack the `Artist` struct and create a new variable `name` with the value of the `name` field. Because the variable is not used, the compiler will raise a warning. To suppress the warning, you can use the underscore `_` to indicate that the variable is intentionally unused.

```move
// Unpack the `Artist` struct and create a new variable `name`
// with the value of the `name` field. The variable is intentionally unused.
let Artist { name: _ } = artist;
```
