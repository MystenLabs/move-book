# Option

Option is a type that represents an optional value which may or may not exist. The concept of Option
in Move is borrowed from Rust, and it is a very useful primitive in Move. `Option` is defined in the
[Standard Library](./standard-library.md), and is defined as follows:

File: move-stdlib/source/option.move

```move
// File: move-stdlib/source/option.move
/// Abstraction of a value that may or may not be present.
struct Option<Element> has copy, drop, store {
    vec: vector<Element>
}
```

> The 'std::option' module is implicitly imported in every module, and you don't need to add an
> import.

The `Option` is a generic type which takes a type parameter `Element`. It has a single field `vec`
which is a `vector` of `Element`. Vector can have length 0 or 1, and this is used to represent the
presence or absence of a value.

Option type has two variants: `Some` and `None`. `Some` variant contains a value and `None` variant
represents the absence of a value. The `Option` type is used to represent the absence of a value in
a type-safe way, and it is used to avoid the need for empty or `undefined` values.

## In Practice

To showcase why Option type is necessary, let's look at an example. Consider an application which
takes a user input and stores it in a variable. Some fields are required, and some are optional. For
example, a user's middle name is optional. While we could use an empty string to represent the
absence of a middle name, it would require extra checks to differentiate between an empty string and
a missing middle name. Instead, we can use the `Option` type to represent the middle name.

```move
{{#include ../../../packages/samples/sources/move-basics/option.move:registry}}
```

In the example above, the `middle_name` field is of type `Option<String>`. This means that the
`middle_name` field can either contain a `String` value or be empty. This makes it clear that the
middle name is optional, and it avoids the need for extra checks to differentiate between an empty
string and a missing middle name.

## Using Option

To use the `Option` type, you need to import the `std::option` module and use the `Option` type. You
can then create an `Option` value using the `some` or `none` methods.

```move
{{#include ../../../packages/samples/sources/move-basics/option.move:usage}}
```
