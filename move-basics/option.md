> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Option

Some data is optional by nature: a user may or may not have a middle name, a lookup may or may not
find a match. Move has no `null` or `undefined` value - a variable of type `String` always holds a
string - so the absence of a value has to be expressed some other way.

A first instinct might be to reserve a special value as a marker: an empty string for a missing
middle name, a zero for a missing number. This works - until an empty string becomes valid input,
and every function has to remember which values are "real" and which are placeholders. The standard
library offers a better tool: the `Option` type, a concept Move borrows from Rust.

## The Option Type

`Option<Element>` is a wrapper around a value of type `Element`, and it is always in one of two
states, conventionally called `Some` and `None`:

- `Some` - the option contains a value;
- `None` - the option is empty.

An option cannot be mistaken for the value it wraps: an `Option<String>` is not a `String`, and the
value has to be checked for and taken out before it can be used. The possibility of absence becomes
part of the type, visible in every signature, instead of a convention every caller must remember.

`Option` is defined in the [Standard Library](./standard-library) and, like `vector`, is
[implicitly imported](./standard-library#implicit-imports) - it can be used in any module without a
`use` statement. The `Element` type parameter makes it [generic](./generics): the same definition
serves `Option<u64>`, `Option<String>`, and any other element type.

Here is the user record from the problem above, with the optional field expressed as an
`Option<String>`:

```move
module book::user_registry;

use std::string::String;

/// A struct representing a user record.
public struct User has drop {
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
```

The type of the `middle_name` field says exactly what the special-value approach could not: the
value may be absent, and no `String` - empty or otherwise - is reserved as a marker. The two cases
are constructed with `option::some(value)` and `option::none()`:

```move
// A user with a middle name...
let ada = register(
    "Ada",
    option::some("King"),
    "Lovelace",
);

// ...and a user without one. No reserved values, no guesswork.
let grace = register(
    "Grace",
    option::none(),
    "Hopper",
);
```

## Creating and Using an Option

Once created, an option can be checked for a value, read, and emptied:

```move
// `option::some` creates an option holding a value.
let mut opt: Option<String> = option::some("Alice");

// `option::none` creates an empty option. The element type has to
// be specified when it cannot be inferred from use.
let empty: Option<u64> = option::none();

// Checking the state of an option.
assert_eq!(opt.is_some(), true);
assert_eq!(empty.is_none(), true);

// `borrow` reads the value without taking it out of the option.
assert_ref_eq!(opt.borrow(), &"Alice");

// `extract` takes the value out, leaving the option empty.
let inner = opt.extract();
assert_eq!(inner, "Alice");
assert_eq!(opt.is_none(), true);
```

> The `borrow` function yields a _reference_ to the value - a way to read it without taking it out
> of the option. References are covered in the [References](./references#immutable-references)
> section later in this chapter.

The table below lists the most commonly used functions of the `std::option` module; see the
[module documentation][option-stdlib] for the full list:

<div class="modules-table">

| Function               | Description                                            | Aborts If                |
| ---------------------- | ------------------------------------------------------ | ------------------------ |
| `is_some`              | Returns `true` if the option holds a value             | -                        |
| `is_none`              | Returns `true` if the option is empty                  | -                        |
| `contains`             | Returns `true` if the option holds the given value     | -                        |
| `borrow`               | Returns a reference to the value                       | The option is empty      |
| `borrow_mut`           | Returns a mutable reference to the value               | The option is empty      |
| `fill`                 | Places a value into an empty option                    | The option holds a value |
| `extract`              | Takes the value out, leaving the option empty          | The option is empty      |
| `swap`                 | Replaces the value, returning the old one              | The option is empty      |
| `destroy_some`         | Destroys the option, returning the value               | The option is empty      |
| `destroy_none`         | Destroys an empty option                               | The option holds a value |
| `destroy_with_default` | Destroys the option, returning the value or a default  | -                        |

</div>

Like a `vector`, an `Option` inherits its abilities from the element type: an option of a
non-[droppable](./drop-ability) type cannot be ignored, and must be destroyed explicitly with one of
the `destroy_*` functions above.

## Option Macros

Like the [vector macros](./vector#vector-macros), option macros replace the common
check-then-extract sequences with a single expression:

```move
// `destroy_or!` consumes the option, returning a default when empty.
let value = option::some(10u8).destroy_or!(0);
assert_eq!(value, 10);

let missing = option::none<u8>().destroy_or!(0);
assert_eq!(missing, 0);

// `is_some_and!` tests the value against a condition.
let is_big = option::some(10u8).is_some_and!(|n| *n > 5);
assert_eq!(is_big, true);

// `do!` runs the lambda only when there is a value.
option::some(10u8).do!(|n| assert_eq!(n, 10));
```

Other commonly used macros include `map!`, `filter!`, `extract_or!`, and `do_ref!` - the full list
is available in the [module documentation][option-stdlib], and macros in general are covered later
in this chapter, in the [Macro Functions](./macros) section.

## Under the Hood

`Option` is defined as a struct with a single field: a `vector` of `Element`, which is always
either empty (`None`) or holds exactly one value (`Some`):

```move
module std::option;

/// Abstraction of a value that may or may not be present.
public struct Option<Element> has copy, drop, store {
    vec: vector<Element>
}
```

> You might be surprised that `Option` is a struct containing a `vector` rather than an
> [enum][enum-reference]. This is for historical reasons: `Option` was added to Move before the
> language had support for enums. In Rust, where the type originates, `Option` _is_ an enum with
> the `Some` and `None` _variants_ - Move keeps the terminology.

The representation is an implementation detail: the functions and macros above cover regular use,
and the `vec` field is never accessed directly.

## Further Reading

- [std::option][option-stdlib] module documentation.

[enum-reference]: ./../../reference/enums
[option-stdlib]: https://docs.sui.io/references/framework/std/option
