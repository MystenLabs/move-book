> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

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

```move
// An empty vector of bool elements.
let empty: vector<bool> = vector[];

// A vector of u8 elements.
let v: vector<u8> = vector[10, 20, 30];

// A vector of vector<u8> elements.
let vv: vector<vector<u8>> = vector[
    vector[10, 20],
    vector[30, 40]
];
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

```move
let v: vector<u8> = vector[10, 20, 30];

// `length` returns the number of elements.
assert_eq!(v.length(), 3);
assert_eq!(v.is_empty(), false);

// The index syntax borrows an element; for copyable
// types the borrowed value can be read directly.
assert_eq!(v[0], 10);

// Accessing an index outside of bounds aborts:
// v[3]; // ABORTS!
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

```move
let mut v = vector[10u8, 20, 30];

// `push_back` adds an element to the end of the vector.
v.push_back(40); // [10, 20, 30, 40]

// `pop_back` removes the last element and returns it.
let last = v.pop_back(); // [10, 20, 30]
assert_eq!(last, 40);

// `insert` places an element at the given index, shifting
// the elements after it to the right.
v.insert(15, 1); // [10, 15, 20, 30]

// `remove` takes an element out at the given index, shifting
// the elements after it to the left.
let removed = v.remove(2); // [10, 15, 30]
assert_eq!(removed, 20);

// The index syntax can also modify an element in place; the `&mut`
// and `*` in this expression are explained in the References section.
*(&mut v[0]) = 5; // [5, 15, 30]
assert_eq!(v[0], 5);
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

```move
let v = vector[1u64, 2, 3, 4];

// `count!` returns the number of elements matching the condition.
let even_count = v.count!(|n| *n % 2 == 0);
assert_eq!(even_count, 2);

// `map!` transforms each element, returning a new vector.
let doubled = v.map!(|n| n * 2);
assert_eq!(doubled, vector[2, 4, 6, 8]);

// `fold!` collapses the vector into a single value,
// in this case - the sum of all elements.
let sum = v.fold!(0, |acc, n| acc + n);
assert_eq!(sum, 10);

// `do!` calls the function on each element of the vector.
let mut total = 0u64;
v.do!(|n| total = total + n);
assert_eq!(total, 10);
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

```move
/// A struct without `drop` ability.
public struct NoDrop {}

#[test]
fun test_destroy_empty() {
    // Initialize a vector of `NoDrop` elements.
    let v = vector<NoDrop>[];

    // While we know that `v` is empty, we still need to call
    // the explicit `destroy_empty` function to discard the vector.
    v.destroy_empty();
}
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
