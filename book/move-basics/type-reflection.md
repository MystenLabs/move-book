# Type Reflection

In programming languages, _reflection_ is the ability of a program to examine and modify its own
structure and behavior. Move has a limited form of reflection that allows you to inspect the type of
a value at runtime. This is useful when you need to store type information in a homogeneous
collection, or when you need to check if a type belongs to a package.

Type reflection is implemented in the [Standard Library](./standard-library) module
[`std::type_name`][type-name-stdlib]. Expressed very roughly, it gives a single function `get<T>()`
which returns the name of the type `T`.

## In practice

The module is straightforward, and operations allowed on the result are limited to getting a string
representation and extracting the module and address of the type.

```move file=packages/samples/sources/move-basics/type-reflection.move anchor=main

```

## Further Reading

- [std::type_name][type-name-stdlib] module documentation.

[type-name-stdlib]: https://docs.sui.io/references/framework/std/type_name
