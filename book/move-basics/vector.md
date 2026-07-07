---
description:
  'Vectors in Move: create dynamic collections, read, add and remove elements, iterate with vector
  macros, and destroy vectors of non-droppable types.'
---

# Vector

A `vector` is the built-in way to store collections of elements in Move. It is an ordered, growable
collection, similar to arrays or lists in other programming languages, and it is a building block
for other types: the [`Option`](./option) and [`String`](./string) types introduced in the sections
that follow are both backed by a vector. In this section, we introduce the `vector` type, its
operations, and the macros that make working with it convenient.

## Vector Syntax

The `vector` type is written using the `vector` keyword followed by the type of the elements in
angle brackets. The type of the elements can be any valid Move type, including other vectors.

Move also has a vector literal syntax that allows you to create vectors using the `vector` keyword
followed by square brackets containing the elements (or no elements for an empty vector).

```move file=packages/samples/sources/move-basics/vector.move anchor=literal

```

The `vector` type is a built-in type in Move, and does not need to be imported from a module. Vector
operations are defined in the `std::vector` module of the [Standard Library](./standard-library),
which is implicitly imported and can be used directly without an explicit `use` statement.

> In this section we call vector functions with the dot syntax, for example `v.length()` instead of
> `vector::length(&v)`. This is the _receiver syntax_, available for standard library types out of
> the box; we explain how it works in the [Struct Methods](./struct-methods) section.

## Reading Elements

The most basic things to ask of a collection are its size and its elements. The `length` function
returns the number of elements, `is_empty` tells whether there are none, and the index syntax `v[i]`
accesses a single element. Indices start at zero, and accessing an index outside of bounds aborts
execution:

```move file=packages/samples/sources/move-basics/vector.move anchor=access

```

> The `v[i]` syntax is a shorthand for calling the `borrow` function - it yields a
> [reference](./references) to the element, not the element itself. For copyable types, like the
> integers above, the difference is invisible; for types that cannot be copied, taking an element
> _out_ of a vector requires `pop_back`, `remove`, or `swap_remove` described below. The details of
> this syntax are described in [Index Syntax](./../../reference/index-syntax) in the Move Reference.

## Adding and Removing Elements

A mutable vector can grow and shrink. The most efficient operations work on the _end_ of the
vector - `push_back` and `pop_back` - while `insert` and `remove` work at an arbitrary index and
shift all of the elements after it:

```move file=packages/samples/sources/move-basics/vector.move anchor=methods

```

The table below lists the most commonly used functions of the `std::vector` module; see the [module
documentation][vector-stdlib] for the full list:

<div class="modules-table">

| Function        | Description                                        | Aborts If                  |
| --------------- | -------------------------------------------------- | -------------------------- |
| `length`        | Returns the number of elements                     | -                          |
| `is_empty`      | Returns `true` if the vector has no elements       | -                          |
| `push_back`     | Adds an element to the end                         | -                          |
| `pop_back`      | Removes and returns the last element               | The vector is empty        |
| `insert`        | Inserts an element at the index, shifting the rest | The index is out of bounds |
| `remove`        | Removes and returns the element at the index       | The index is out of bounds |
| `swap_remove`   | Swaps the element with the last one and removes it | The index is out of bounds |
| `swap`          | Swaps the elements at two indices                  | An index is out of bounds  |
| `contains`      | Returns `true` if the vector contains the element  | -                          |
| `index_of`      | Returns `(true, index)` if the element is found    | -                          |
| `append`        | Moves all elements from another vector to the end  | -                          |
| `reverse`       | Reverses the order of the elements                 | -                          |
| `destroy_empty` | Destroys an empty vector                           | The vector is not empty    |

</div>

> Note that `remove` shifts every element after the removed one, which makes it more expensive the
> longer the vector is. If the order of elements does not matter, `swap_remove` does the same job in
> constant time.

## Vector Macros

Reading, transforming, or aggregating every element of a vector is such a common task that the
standard library provides a set of _macros_ for it. Macro names end with a `!` and take a _lambda_
(an inline function written as `|argument| expression`) which the macro applies to the elements.
Under the hood a macro expands into a regular loop at compilation time, so using one costs nothing
extra at runtime:

```move file=packages/samples/sources/move-basics/vector.move anchor=macros

```

Other commonly used macros include `filter!`, `any!`, `all!`, `find_index!`, and `tabulate!` - each
of them replaces a hand-written loop with a single expressive line. The full list is available in
the [module documentation][vector-stdlib], and macros in general are covered later in this chapter,
in the [Macro Functions](./macros) section.

## Destroying a Vector of Non-Droppable Types

The `vector` type inherits its [abilities](./abilities-introduction) from its elements: a
`vector<T>` can only be [dropped](./drop-ability) if `T` can. A vector of types without the `drop`
ability cannot be ignored, even when it is empty, and the compiler requires an explicit call to the
`destroy_empty` function:

```move file=packages/samples/sources/move-basics/vector.move anchor=no_drop

```

The `destroy_empty` function will fail at runtime if you call it on a non-empty vector. This is the
resource model at work: if the elements of a vector represent assets, neither the assets nor the
vector holding them can silently disappear - every element must be taken out and handled before the
vector itself is destroyed.

## Further Reading

- [Vector](./../../reference/primitive-types/vector) in the Move Reference.
- [Index Syntax](./../../reference/index-syntax) in the Move Reference.
- [Macro Functions](./../../reference/functions/macros) in the Move Reference.
- [std::vector][vector-stdlib] module documentation.

[vector-stdlib]: https://docs.sui.io/references/framework/std/vector
