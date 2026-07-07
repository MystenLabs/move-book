---
description: "Define custom types with struct in Move: pack, unpack, access fields, and control field visibility with getters and setters in Sui smart contracts."
---

# Custom Types with Struct

A _struct_ is a user-defined type that groups related values into a single unit, giving a name to
both the group and each value inside it. If you are familiar with object-oriented languages, a
struct is similar to an object's data attributes. Instead of passing around a loose title, artist,
and release year, an application can define a `Record` type and handle all three as one value.

Custom types are the backbone of a Move program: they describe the application's data, and - as
later sections will show - the module that defines a type controls everything that can be done with
its values. In this section we introduce the struct definition and how to use it.

## Defining a Struct

To define a custom type, use the `public struct` keywords followed by the name of the type, and a
block of fields. Each field is defined with the `field_name: field_type` syntax, and field
definitions must be separated by commas. The fields can be of any type, including other structs.

> Move does not support recursive structs, meaning a struct cannot contain itself as a field.

```move file=packages/samples/sources/move-basics/struct.move anchor=def

```

In the example above, we define an `Artist` struct with a single field, and a `Record` struct with
five fields. The `title` field is of type [`String`](./string), the `artist` field uses the custom
`Artist` type we just defined, the `year` field is of type `u16`, the `is_debut` field is of type
`bool`, and the `edition` field is of type [`Option<u16>`](./option) to represent that the edition
is optional.

The `String` type is not built into the language - it is defined in the
[Standard Library](./standard-library) and brought into scope with the `use` statement at the top of
the example; imports are covered in the [Importing Modules](./importing-modules) section. The angle
brackets in `Option<u16>` denote a _type parameter_: `Option<u16>` is an `Option` that holds a
`u16`. Type parameters are covered in the [Generics](./generics) section.

> A struct definition can also declare _abilities_ - properties that relax the default restrictions
> on values of the type. They are listed with the `has` keyword, either before the fields -
> `public struct Foo has copy, drop { ... }` - or after them, terminated with a semicolon -
> `public struct Foo { ... } has copy, drop;`. Abilities are introduced in the
> [Abilities Introduction](./abilities-introduction) section.

## Creating an Instance

We described the _definition_ of a struct. Now let's see how to create an instance of one. Creating
an instance of a struct is called _packing_, and it is done with the
`StructName { field1: value1, field2: value2, ... }` syntax. The fields can be set in any order, but
all of them must be set - a struct cannot be partially initialized.

> The examples on this page live inside a [test function](./testing) in the same module that defines
> the structs - as we are about to see, structs can only be created and taken apart within their
> module. The `assert_eq!` used throughout is a _macro_ - hence the `!` in the name - that compares
> two values and fails if they differ; it is covered in the [Testing](./testing) section.

```move file=packages/samples/sources/move-basics/struct.move anchor=pack

```

In the example above, we create an instance of the `Artist` struct and set the `name` field to the
string "The Beatles". The value `"The Beatles"` is a _string literal_: the compiler sees that the
`name` field expects a `String` and infers the type of the literal automatically. Strings are
covered in more detail in the [String](./string) section.

Move also offers a shorthand: if a local variable has the same name as the field, the field name can
be given just once. This is called _field name punning_.

```move file=packages/samples/sources/move-basics/struct.move anchor=pack_shorthand

```

## Accessing Fields

To access the fields of a struct, use the `.` (dot) operator followed by the field name. Fields can
be read, and, if the variable is declared as `mut`, assigned a new value.

```move file=packages/samples/sources/move-basics/struct.move anchor=access

```

Accessing fields this way works only in the module that defines the struct. To understand why,
let's take a closer look at struct visibility.

## Field Visibility

As you may have noticed, every struct is declared with the `public` modifier - it is required, and
declaring a struct without it is a compilation error. The `public` modifier makes the struct _type_
visible to other modules: it can be [imported](./importing-modules), used in type definitions, and
in function signatures.

However, the _contents_ of a struct always stay internal to the module that defines it. Unlike some
languages, Move has no per-field visibility modifiers - there is no way to mark a field public.
Outside of the defining module it is impossible to:

- read or write the fields of a struct;
- create ("pack") an instance of a struct;
- destroy ("unpack") an instance of a struct.

This is a feature, not a limitation. It means the module has full control over how its types are
created, used, and destroyed, and no external code can violate the rules the module sets. In the
[Object Model](./../object/) chapter, we show how this property is used to model assets and enforce
guarantees on them.

> Note that just because a struct field is not accessible from other modules does not mean its value
> is confidential - it is always possible to read the contents of an onchain object from outside of
> Move. You should never store unencrypted secrets inside of objects.

## Getters and Setters

Because fields are only accessible inside the defining module, the module needs to expose public
functions if other modules should read or update them. A function that returns the value of a field
is conventionally called a _getter_, and a function that updates a field is called a _setter_.

A getter typically takes a [reference](./references) to the struct and returns the field value:

```move file=packages/samples/sources/move-basics/struct.move anchor=getter

```

A setter takes a mutable reference to the struct and the new value:

```move file=packages/samples/sources/move-basics/struct.move anchor=setter

```

Both functions can then be called with the `.` operator, just like field access:

```move file=packages/samples/sources/move-basics/struct.move anchor=getter_setter_use

```

Because these functions are `public`, any module that imports `Artist` can call them. Note the
parentheses: `artist.name()` is a function call and works anywhere the function is visible, while
the field access `artist.name` would not compile outside the defining module.

> The `public fun` syntax defines a public function; functions are covered in detail in the
> [Functions](./function) section. The `&` and `&mut` in the signatures are references - they allow
> a function to read or modify a value without taking ownership of it. We cover them in the
> [References](./references) section, and the dot-call syntax in the
> [Struct Methods](./struct-methods) section.

While getters are very common, setters are defined less often, and usually with extra checks. The
choice of which functions to expose is what defines the interface of the type - the module decides
what external code can and cannot do with its structs.

## Unpacking a Struct

Structs are non-discardable by default: a struct value cannot simply be left behind at the end of a
function - code that does so will not compile. Every created value must be used: either stored (for
example, placed inside another struct, or kept in onchain storage, as shown in the
[Using Objects](./../storage/) chapter) or _unpacked_. Unpacking a struct means deconstructing it
into its fields, and it is the mirror image of packing: the `let` keyword, followed by the struct
name and the field names to bind.

```move file=packages/samples/sources/move-basics/struct.move anchor=unpack

```

In the example above we unpack the `Artist` struct and create a new variable `name` with the value
of the `name` field. The struct value no longer exists after this line - it has been broken up into
its parts.

If a field is not needed, it can be ignored by binding it to the underscore `_`. However, since the
struct itself cannot be discarded, all of its fields must still be listed in the pattern:

```move file=packages/samples/sources/move-basics/struct.move anchor=unpack_ignore

```

For structs with many fields, listing every ignored field gets verbose. The `..` pattern - the
_rest_ pattern - matches all of the remaining fields at once:

```move file=packages/samples/sources/move-basics/struct.move anchor=unpack_rest

```

In the example above, we pack a full `Record` - the `option::none()` call creates an empty `Option`
value, see the [Option](./option) section - and then unpack it, keeping the `title` and `artist`
fields and ignoring the rest with `..`.

Note that ignoring a field - whether with `_` or `..` - discards its value, which is only allowed
for values that can be discarded. Simple values like `String`, `u16`, and `bool` can be discarded
freely, but `Artist` cannot - which is why the example unpacks the `artist` binding as well instead
of ignoring it. Which values can be discarded and which cannot is determined by _abilities_,
explained in the next sections - [Abilities Introduction](./abilities-introduction) and
[Ability: Drop](./drop-ability).

## Positional Structs

So far, every struct on this page had named fields. Move also supports _positional_ structs, whose
fields have no names and are identified by their position instead. A positional struct is defined
with parentheses instead of curly braces, and the definition has no body - it ends right after the
field list:

```move file=packages/samples/sources/move-basics/struct.move anchor=positional_def

```

Abilities can be placed before or after the fields here as well; in the post-fix form they follow
the parentheses: `public struct Duration(u64, u64) has copy, drop;`.

Positional structs are packed and unpacked with parentheses as well, and their fields are accessed
with the `.` operator followed by the field index, starting at zero:

```move file=packages/samples/sources/move-basics/struct.move anchor=positional_use

```

Positional structs are a good fit when field names would not add anything to what the type name
already says - typically in small wrapper types with one or two fields. All of the rules described
on this page still apply to them: fields are only accessible within the defining module, and a
value must be used - stored or unpacked. For structs with more fields, named fields are usually the
better choice.

## Further Reading

- [Structs](./../../reference/structs) in the Move Reference.
