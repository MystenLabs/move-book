---
description:
  'Vector-based collections in the Sui Framework: VecSet and VecMap, their operations and
  constraints, and when to reach for dynamic collections instead.'
---

# Collections

Storing groups of values is one of the most common needs in a program. The
[`vector`](./../move-basics/vector) type, covered in the Move Basics chapter, is the base building
block for it, and the [Sui Framework](./sui-framework) extends it with two collection types that
add structure on top: `VecSet`, which keeps its elements unique, and `VecMap`, which associates
keys with values. In this section we introduce all three in their most common role - as fields of
an object - and show the operations and constraints of each.

## Vector

While the [vector section](./../move-basics/vector) presents the `vector` type as a standalone
value, in a real application it usually lives inside an object. A store that owns a list of books
is a vector in a field:

```move file=packages/samples/sources/programmability/collections.move anchor=vector

```

Everything from the vector section applies here unchanged; the collection types below follow the
same pattern - plain struct values that can be placed in a field, passed around, and, unlike
[dynamic fields](./dynamic-fields) introduced later in this chapter, fully described by the type of
the object that holds them.

## VecSet

`VecSet` is a collection that stores _unique_ items. Inserting a value that is already present
aborts, so the set is a natural fit for collections that must not contain duplicates, such as a
list of IDs or addresses.

```move file=packages/samples/sources/programmability/collections-2.move anchor=vec_set

```

The `contains` function answers membership questions, and the contents can be read back either by
reference, with `keys`, or taken out as a plain `vector` with `into_keys` - for example, to iterate
over them with the [vector macros](./../move-basics/vector#vector-macros).

> The element type of a `VecSet` must have the [`copy`](./../move-basics/copy-ability) and
> [`drop`](./../move-basics/drop-ability) abilities. This is true for primitive types and simple
> data structs, but rules out storing assets in a set.

## VecMap

`VecMap` is a collection of key-value pairs, where each key is unique and maps to a single value.
Reading a value back is the everyday operation of a map, and there are two ways to do it: the index
syntax `map[&key]` borrows a value and aborts if the key is missing, while `try_get` returns an
[`Option`](./../move-basics/option) and never aborts.

```move file=packages/samples/sources/programmability/collections-3.move anchor=vec_map

```

Like `VecSet`, a `VecMap` aborts on an attempt to `insert` a key that is already present - it does
_not_ silently overwrite the old value. Replacing a value requires going through a mutable
reference, as the example above shows, or removing the old entry first. Keys of a `VecMap` must
have the [`copy`](./../move-basics/copy-ability) ability, while the value can be any type.

## Limitations

Vector-based collections are strictly typed: a `VecSet<address>` holds addresses and nothing else,
which is exactly what you want most of the time, but makes them unsuitable for heterogeneous data.
They are also plain values stored inside the object, so they count toward the object size limit of
256KB, described in the [Building Against Limits](./../guides/building-against-limits) guide.

In practice, a different limit matters sooner: every operation - `insert`, `contains`, `get` -
scans the underlying vector element by element, so the cost of each access grows with the size of
the collection. Vector-based collections shine when the number of elements is small and bounded -
tens or hundreds of entries. For large or unbounded collections, the Sui Framework provides
`Table`, `Bag`, and other object-backed types, which we cover in the
[Dynamic Collections](./dynamic-collections) section later in this chapter.

Lastly, vector-based collections do not support equality comparison the way one might expect.
`VecSet` and `VecMap` keep their contents in insertion order, and the `==` operator compares the
underlying vectors element by element. As a result, two sets that contain the same elements, but
received them in a different order, are _not_ equal.

> This behavior is caught by the linter and will emit a warning: _Comparing collections of type
> 'sui::vec_set::VecSet' may yield unexpected result_

```move file=packages/samples/sources/programmability/collections-4.move anchor=vec_set_comparison

```

In the example above, both sets contain the same elements - `1` and `2` - but they were inserted in
a different order. Since the comparison is order-sensitive, `set1 == set2` evaluates to `false`, and
the assertion aborts. Do not rely on `==` to compare vector-based collections, unless you can
guarantee that the elements were inserted in the same order.

## Summary

- Vector is a native type that allows storing a list of items; inside an object it appears as a
  regular field.
- VecSet is built on top of vector and stores unique items; inserting a duplicate aborts.
- VecMap stores key-value pairs with unique keys; inserting an existing key aborts, and values are
  read with the index syntax or `try_get`.
- Vector-based collections are strictly typed, scan their contents linearly on every operation, and
  are best suited for small, bounded sets and lists; larger collections call for
  [dynamic collections](./dynamic-collections).

## Next Steps

In the next section we will cover the [Wrapper Type Pattern](./wrapper-type-pattern) - a design
pattern often used with collection types to extend or restrict their behavior.

## Further Reading

- [sui::vec_set][vec-set-framework] module documentation.
- [sui::vec_map][vec-map-framework] module documentation.

[vec-set-framework]: https://docs.sui.io/references/framework/sui/vec_set
[vec-map-framework]: https://docs.sui.io/references/framework/sui/vec_map
