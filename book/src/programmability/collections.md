# Collections

Collection types are a fundamental part of any programming language. They are used to store a
collection of data, such as a list of items. The `vector` type has already been covered in the
[vector section](./../move-basics/vector.md), and in this chapter we will cover the vector-based
collection types offered by the [Sui Framework](./sui-framework.md).

## Vector

While we have previously covered the `vector` type in the
[vector section](./../move-basics/vector.md), it is worth going over it again in a new context. This
time we will cover the usage of the `vector` type in objects and how it can be used in an
application.

```move
{{#include ../../../packages/samples/sources/programmability/collections.move:vector}}
```

## VecSet

`VecSet` is a collection type that stores a set of unique items. It is similar to a `vector`, but it
does not allow duplicate items. This makes it useful for storing a collection of unique items, such
as a list of unique IDs or addresses.

```move
{{#include ../../../packages/samples/sources/programmability/collections-2.move:vec_set}}
```

VecSet will fail on attempt to insert an item that already exists in the set.

## VecMap

`VecMap` is a collection type that stores a map of key-value pairs. It is similar to a `VecSet`, but
it allows you to associate a value with each item in the set. This makes it useful for storing a
collection of key-value pairs, such as a list of addresses and their balances, or a list of user IDs
and their associated data.

Keys in a `VecMap` are unique, and each key can only be associated with a single value. If you try
to insert a key-value pair with a key that already exists in the map, the old value will be replaced
with the new value.

```move
{{#include ../../../packages/samples/sources/programmability/collections-3.move:vec_map}}
```

## Limitations

Standard collection types are a great way to store typed data with guaranteed safety and
consistency. However, they are limited by the type of data they can store - the type system won't
allow you to store a wrong type in a collection; and they're limited in size - by the object size
limit. They will work for relatively small-sized sets and lists, but for larger collections you may
need to use a different approach.

Another limitations on collection types is inability to compare them. Because the order of insertion
is not guaranteed, an attempt to compare a `VecSet` to another `VecSet` may not yield the expected
results.

> This behavior is caught by the linter and will emit a warning: _Comparing collections of type
> 'sui::vec_set::VecSet' may yield unexpected result_

```move
{{#include ../../../packages/samples/sources/programmability/collections-4.move:vec_set_comparison}}
```

In the example above, the comparison will fail because the order of insertion is not guaranteed, and
the two `VecSet` instances may have different orders of elements. And the comparison will fail even
if the two `VecSet` instances contain the same elements.

## Summary

- Vector is a native type that allows storing a list of items.
- VecSet is built on top of vector and allows storing sets of unique items.
- VecMap is used to store key-value pairs in a map-like structure.
- Vector-based collections are strictly typed and limited by the object size limit and are best
  suited for small-sized sets and lists.

## Next Steps

In the next section we will cover the [Wrapper Type Pattern](./wrapper-type-pattern.md) - a design pattern
often used with collection types to extend or restrict their behavior. 
