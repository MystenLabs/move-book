# Vector

Vectors are a native way to store collections of elements in Move. They are similar to arrays in
other programming languages, but with a few differences. In this section, we introduce
the `vector` type and its operations.

## Vector syntax

The `vector` type is written using the `vector` keyword followed by the type of the elements in
angle brackets. The type of the elements can be any valid Move type, including other vectors.

Move
has a vector literal syntax that allows you to create vectors using the `vector` keyword followed by
square brackets containing the elements (or no elements for an empty vector).

```move
{{#include ../../../packages/samples/sources/move-basics/vector.move:literal}}
```

The `vector` type is a built-in type in Move, and does not need to be imported from a module.
However, vector operations are defined in the `std::vector` module, and you need to import the
module to use them.

## Vector operations

The standard library provides methods to manipulate vectors. The following are some of the most
commonly used operations:

- `push_back`: Adds an element to the end of the vector.
- `pop_back`: Removes the last element from the vector.
- `length`: Returns the number of elements in the vector.
- `is_empty`: Returns true if the vector is empty.
- `remove`: Removes an element at a given index.

```move
{{#include ../../../packages/samples/sources/move-basics/vector.move:methods}}
```

## Destroying a Vector of non-droppable types

A vector of non-droppable types cannot be discarded. If you define a vector of types without the `drop`
ability, the vector value cannot be ignored. If the vector is empty, the compiler requires an
explicit call to the `destroy_empty` function.

```move
{{#include ../../../packages/samples/sources/move-basics/vector.move:no_drop}}
```

The `destroy_empty` function will fail at runtime if you call it on a non-empty vector.

## Further reading

- [Vector](/reference/primitive-types/vector.html) in the Move Reference.
