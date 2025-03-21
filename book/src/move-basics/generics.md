# Generics

Generics are a way to define a type or function that can work with any type. This is useful when you
want to write a function which can be used with different types, or when you want to define a type
that can hold any other type. Generics are the foundation of many advanced features in Move including
collections, abstract implementations, and more.

## In the Standard Library

In this chapter we already mentioned the [vector](./vector.md) type, which is a generic type that
can hold any other type. Another example of a generic type in the standard library is the
[Option](./option.md) type, which is used to represent a value that may or may not be present.

## Generic Syntax

To define a generic type or function, a type signature needs to have a list of generic parameters
enclosed in angle brackets (`<` and `>`). The generic parameters are separated by commas.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:container}}
```

In the example above, `Container` is a generic type with a single type parameter `T`, the `value`
field of the container stores the `T`. The `new` function is a generic function with a single type
parameter `T`, and it returns a `Container` with the given value. Generic types must be initialized
with a concrete type, and generic functions must be called with a concrete type, although in some cases
the Move compiler can infer the correct type.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:test_container}}
```

In the test function `test_generic`, we demonstrate three equivalent ways to
create a new `Container` with a `u8` value. Because numeric constants have
ambiguous types, we must specify the type of the number literal somewhere (in
the type of the container, the parameter to `new`, or the number literal
itself); once we specify one of these the compiler can infer the others.

## Multiple Type Parameters

You can define a type or function with multiple type parameters. The type parameters are
separated by commas.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:pair}}
```

In the example above, `Pair` is a generic type with two type parameters `T` and `U`, and the
`new_pair` function is a generic function with two type parameters `T` and `U`. The function returns
a `Pair` with the given values. The order of the type parameters is important, and should match
the order of the type parameters in the type signature.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:test_pair}}
```

If we added another instance where we swapped type parameters in the `new_pair` function, and tried
to compare two types, we'd see that the type signatures are different, and cannot be compared.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:test_pair_swap}}
```

Since the types for `pair1` and `pair2` are different, the comparison `pair1 == pair2` will not compile.

## Why Generics?

In the examples above we focused on instantiating generic types and calling generic functions to
create instances of these types. However, the real power of generics lies in their ability to define shared
behavior for the base, generic type, and then use it independently of the concrete types. This is
especially useful when working with collections, abstract implementations, and other advanced
features in Move.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:user}}
```

In the example above, `User` is a generic type with a single type parameter `T`, with shared fields
`name`, `age`, and the generic `metadata` field, which can store any type. No matter what
`metadata` is, all instances of `User` will contain the same fields and methods.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:update_user}}
```

## Phantom Type Parameters

In some cases, you may want to define a generic type with a type parameter that is not used in the
fields or methods of the type. This is called a _phantom type parameter_. Phantom type parameters
are useful when you want to define a type that can hold any other type, but you want to enforce some
constraints on the type parameter.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:phantom}}
```

The `Coin` type here does not contain any fields or methods that use the type parameter `T`. It is
used to differentiate between different types of coins, and to enforce some constraints on the type
parameter `T`.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:test_phantom}}
```

In the example above, we demonstrate how to create two different instances of `Coin` with different
phantom type parameters `USD` and `EUR`. The type parameter `T` is not used in the fields or methods
of the `Coin` type, but it is used to differentiate between different types of coins. This helps ensure
that the `USD` and `EUR` coins are not mistakenly mixed up.

## Constraints on Type Parameters

Type parameters can be constrained to have certain abilities. This is useful when you need the inner
type to allow certain behaviors, such as _copy_ or _drop_. The syntax for constraining a type
parameter is `T: <ability> + <ability>`.

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:constraints}}
```

The Move Compiler will enforce that the type parameter `T` has the specified abilities. If the type
parameter does not have the specified abilities, the code will not compile.

<!-- TODO: failure case -->

```move
{{#include ../../../packages/samples/sources/move-basics/generics.move:test_constraints}}
```

## Further Reading

- [Generics](/reference/generics.html) in the Move Reference.
