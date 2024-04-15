# Type Reflection

In programming languages _reflection_ is the ability of a program to examine and modify its own
structure and behavior. In Move, there's a limited form of reflection that allows you to inspect the
type of a value at runtime. This is useful when you need to store type information in a homogeneous
collection, or when you need to check if a type belongs to a package.

Type reflection is implemented in the [Standard Library](./standard-library.md) module
`std::type_name`. Expressed very roughly, it gives a single function `get<T>()` which returns the
name of the type `T`.

## In practice

The module is pretty straightforward, and operations allowed on the result are limited to getting a
string representation and extracting the module and address of the type.

```move
{{#include ../../../packages/samples/sources/move-basics/type-reflection.move:main}}
```

## Further reading

Type reflection is an important part of the language, and it is a crucial part of some of the more
advanced patterns.
