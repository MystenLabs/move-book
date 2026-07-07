> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Generics

Generics are a way to define a type or function that can work with any type, instead of one
specific type. You have already used generics in this chapter, perhaps without noticing: the
[vector](./vector) type is generic - a single definition can hold elements of any type - and so is
[Option](./option), which can wrap any value. Generics are the foundation of collections, abstract
implementations, and many advanced features of Move.

## The Problem Generics Solve

Suppose we need a type that wraps a single `u64` value. Simple enough:

```move
public struct U64Container has drop {
    value: u64,
}
```

But what if we also need to wrap a `bool`? And a `String`? And a struct of our own? Each version
would be identical except for the type of the `value` field, and every function that works with
containers would need to be duplicated for each version:

```move
public struct BoolContainer has drop { value: bool }
public struct StringContainer has drop { value: String }
// ...a new struct for every type we want to store
```

Generics solve exactly this problem: we define the container _once_, with a placeholder instead of
a concrete type, and the placeholder is filled in when the type is used.

## Generic Syntax

To define a generic type or function, add a list of _type parameters_ enclosed in angle brackets
(`<` and `>`) after the name. Multiple type parameters are separated by commas.

```move
/// Container for any type `T`.
public struct Container<T> has drop {
    value: T,
}

/// Function that creates a new `Container` with a generic value `T`.
public fun new<T>(value: T): Container<T> {
    Container { value }
}
```

In the example above, `Container` is a generic type with a single type parameter `T`, and the
`value` field of the container stores a value of type `T`. `T` is not a real type - it is a
placeholder that stands for "some type, to be specified later". The `new` function is a generic
function with the same type parameter, and it returns a `Container<T>` with the given value.

> By convention, type parameters are named with single capital letters - `T`, `U`, `K`, `V`.
> However, any valid name can be used: the standard library, for example, names the type parameter
> of `vector` `Element`.

## Using Generic Types

When we create an instance of a generic type, the placeholder is replaced with a concrete type.
Each replacement produces a distinct type: `Container<u8>`, `Container<bool>`, and
`Container<String>` all come from the same definition, but they are three different types.

The concrete type can be spelled out explicitly, or, in most cases, inferred by the compiler:

```move
#[test]
fun test_container() {
    // these three lines are equivalent
    let container: Container<u8> = new(10); // type inference
    let container = new<u8>(10); // create a new `Container` with a `u8` value
    let container = new(10u8);

    assert_eq!(container.value, 10);

    // Value can be ignored only if it has the `drop` ability.
    let Container { value: _ } = container;
}
```

The first three lines of the test are equivalent - each creates a `Container<u8>`. Because numeric
literals have ambiguous types, we have to specify the type of the number somewhere: in the type
annotation of the variable, in the explicit type argument of `new`, or in the literal itself. Once
one of these is given, the compiler infers the rest. For values with unambiguous types, such as
`bool` or `String`, no annotations are needed at all.

## Multiple Type Parameters

A type or function can have more than one type parameter, separated by commas:

```move
/// A pair of values of any type `T` and `U`.
public struct Pair<T, U> {
    first: T,
    second: U,
}

/// Function that creates a new `Pair` with two generic values `T` and `U`.
public fun new_pair<T, U>(first: T, second: U): Pair<T, U> {
    Pair { first, second }
}
```

In the example above, `Pair` is a generic type with two type parameters `T` and `U`, and the
`new_pair` function creates a `Pair` with the given values.

```move
#[test]
fun test_generic() {
    // these three lines are equivalent
    let pair_1: Pair<u8, bool> = new_pair(10, true); // type inference
    let pair_2 = new_pair<u8, bool>(10, true); // create a new `Pair` with a `u8` and `bool` values
    let pair_3 = new_pair(10u8, true);

    assert_eq!(pair_1.first, 10);
    assert_eq!(pair_1.second, true);

    // Unpacking is identical.
    let Pair { first: _, second: _ } = pair_1;
    let Pair { first: _, second: _ } = pair_2;
    let Pair { first: _, second: _ } = pair_3;

}
```

The order of type parameters matters. A `Pair<u8, bool>` and a `Pair<bool, u8>` are two different,
incompatible types - even though they are built from the same definition and store the same data:

```move
#[test]
fun test_swap_type_params() {
    let pair1: Pair<u8, bool> = new_pair(10u8, true);
    let pair2: Pair<bool, u8> = new_pair(true, 10u8);

    // this line will not compile
    // assert_eq!(pair1, pair2);

    let Pair { first: pf1, second: ps1 } = pair1; // first1: u8, second1: bool
    let Pair { first: pf2, second: ps2 } = pair2; // first2: bool, second2: u8

    assert_eq!(pf1, ps2); // 10 == 10
    assert_eq!(ps1, pf2); // true == true
}
```

Since the types of `pair1` and `pair2` differ, the comparison `pair1 == pair2` would not compile.
The values can only be compared field-by-field, after unpacking.

## Why Generics?

So far we have focused on the mechanics: how to define generic types and create their instances.
The real power of generics is in defining shared data and behavior once, and letting a part of the
type vary. Consider a `User` type where the `name` and `age` fields are always the same, but
different applications need to attach different extra data:

```move
/// A user record with name, age, and some generic metadata
public struct User<T> {
    name: String,
    age: u8,
    /// Varies depending on application.
    metadata: T,
}
```

Functions defined for `User<T>` work no matter what `metadata` is - they operate on the shared
fields and don't need to know the concrete type of `T`:

```move
/// Updates the name of the user.
public fun update_name<T>(user: &mut User<T>, name: String) {
    user.name = name;
}

/// Updates the age of the user.
public fun update_age<T>(user: &mut User<T>, age: u8) {
    user.age = age;
}
```

```move
#[test]
fun test_user() {
    // In this instance, the `metadata` field is a `u64`...
    let mut user1 = User {
        name: "Alice",
        age: 30,
        metadata: 1000u64,
    };

    // ...and in this instance, it is a `bool`.
    let mut user2 = User {
        name: "Bob",
        age: 40,
        metadata: true,
    };

    // The same functions work for both instances.
    user1.update_name("Alice II");
    user2.update_name("Bob II");

    assert_eq!(user1.name, "Alice II");
    assert_eq!(user2.name, "Bob II");

    let User { .. } = user1;
    let User { .. } = user2;
}
```

In the test above, one `User` instance stores a `u64` as its metadata, and the other stores a
`bool`, yet both are updated with the same `update_name` function, defined once.

## Phantom Type Parameters

Sometimes a type parameter is needed only as a _label_, without storing any value of that type.
Consider a `Coin` type: the actual data is just a numeric `value`, the same for every currency.
However, a US Dollar coin and a Euro coin must never be mixed up - they should be different types
in the eyes of the compiler. To express this, the type parameter is declared `phantom` - a
parameter that does not appear in any field:

```move
/// A generic type with a phantom type parameter.
public struct Coin<phantom T> {
    value: u64
}
```

> Move requires every regular type parameter to be used in the fields of the struct. Since `T` is
> not stored anywhere in `Coin`, it must be marked with the `phantom` keyword.

Currencies can then be defined as empty structs - they carry no data and exist only to be used as
labels:

```move
public struct USD {}
public struct EUR {}

#[test]
fun test_phantom_type() {
    let coin1: Coin<USD> = Coin { value: 10 };
    let coin2: Coin<EUR> = Coin { value: 20 };

    // This line will not compile: `Coin<USD>` and `Coin<EUR>`
    // are different types and cannot be mixed up.
    // let mixed: Coin<USD> = coin2;

    // Unpacking is identical because the phantom type parameter is not used.
    let Coin { value: _ } = coin1;
    let Coin { value: _ } = coin2;
}
```

Even though `Coin<USD>` and `Coin<EUR>` store identical data, they are different types, and a
function expecting one will not accept the other. This pattern is used extensively in real
applications: the `Coin` type in the [Sui Framework](./../programmability/sui-framework) is defined
in exactly this way.

## Constraints on Type Parameters

By default, a type parameter accepts _any_ type. However, sometimes the inner type must allow
certain behaviors, such as being copied or discarded, and for that the type parameter can be
constrained to have certain [abilities](./abilities-introduction). The syntax is
`T: <ability> + <ability>`:

```move
/// A generic type with a type parameter that has the `drop` ability.
public struct Droppable<T: drop> {
    value: T,
}

/// A generic struct with a type parameter that has the `copy` and `drop` abilities.
public struct CopyableDroppable<T: copy + drop> {
    value: T, // T must have the `copy` and `drop` abilities
}
```

A constraint is a promise the concrete type must keep: the Move compiler only allows instantiating
`Droppable<T>` with types that have the [drop](./drop-ability) ability, and `CopyableDroppable<T>`
with types that have both [copy](./copy-ability) and `drop`. A type without those abilities does
not compile:

```move
/// Type without any abilities.
public struct NoAbilities {}

#[test]
fun test_constraints() {
    // Fails - `NoAbilities` does not have the `drop` ability
    // let droppable = Droppable<NoAbilities> { value: 10 };

    // Fails - `NoAbilities` does not have the `copy` and `drop` abilities
    // let copyable_droppable = CopyableDroppable<NoAbilities> { value: 10 };
}
```

## Further Reading

- [Generics](./../../reference/generics) in the Move Reference.
