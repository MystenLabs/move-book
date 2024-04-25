# Dynamic Collections

[Sui Framework](./sui-framework.md) offers a variety of collection types that build on the
[dynamic fields](./dynamic-fields.md) and [dynamic object fields](./dynamic-object-fields.md)
concepts. These collections are designed to be a safer and more understandable way to store and
manage dynamic fields and objects.

For each collection type we will specify the primitive they use, and the specific features they
offer.

> Unlike dynamic (object) fields which operate on UID, collection types have their own type and
> allow calling [associated functions](./../move-basics/struct-methods.md).

## Common Concepts

All of the collection types share the same set of methods, which are:

- `add` - adds a field to the collection
- `remove` - removes a field from the collection
- `borrow` - borrows a field from the collection
- `borrow_mut` - borrows a mutable reference to a field from the collection
- `contains` - checks if a field exists in the collection
- `length` - returns the number of fields in the collection
- `is_empty` - checks if the `length` is 0

All collection types support index syntax for `borrow` and `borrow_mut` methods. If you see square
brackets in the examples, they are translated into `borrow` and `borrow_mut` calls.

```move
let hat: &Hat = &bag[b"key"];
let hat_mut: &mut Hat = &mut bag[b"key"];

// is equivalent to
let hat: &Hat = bag.borrow(b"key");
let hat_mut: &mut Hat = bag.borrow_mut(b"key");
```

In the examples we won't focus on these functions, but rather on the differences between the
collection types.

## Bag

Bag, as the name suggests, acts as a "bag" of heterogeneous values. It is a simple, non-generic type
that can store any data. Bag will never allow orphaned fields, as it tracks the number of fields and
can't be destroyed if it's not empty.

```move
// File: sui-framework/sources/bag.move
public struct Bag has key, store {
    /// the ID of this bag
    id: UID,
    /// the number of key-value pairs in the bag
    size: u64,
}
```

Due to Bag storing any types, the extra methods it offers is:

- `contains_with_type` - checks if a field exists with a specific type

Used as a struct field:

```move
{{#include ../../../packages/samples/sources/programmability/dynamic-collections.move:bag_struct}}
```

Using the Bag:

```move
{{#include ../../../packages/samples/sources/programmability/dynamic-collections.move:bag_usage}}
```

## ObjectBag

Defined in the `sui::object_bag` module. Identical to [Bag](#bag), but uses
[dynamic object fields](./dynamic-object-fields.md) internally. Can only store objects as values.

## Table

Table is a typed dynamic collection that has a fixed type for keys and values. It is defined in the
`sui::table` module.

```move
// File: sui-framework/sources/table.move
public struct Table<phantom K: copy + drop + store, phantom V: store> has key, store {
    /// the ID of this table
    id: UID,
    /// the number of key-value pairs in the table
    size: u64,
}
```

Used as a struct field:

```move
{{#include ../../../packages/samples/sources/programmability/dynamic-collections.move:table_struct}}
```

Using the Table:

```move
{{#include ../../../packages/samples/sources/programmability/dynamic-collections.move:table_usage}}
```

## ObjectTable

Defined in the `sui::object_table` module. Identical to [Table](#table), but uses
[dynamic object fields](./dynamic-object-fields.md) internally. Can only store objects as values.

## Summary

- [Bag](#bag) - a simple collection that can store any type of data
- [ObjectBag](#objectbag) - a collection that can store only objects
- [Table](#table) - a typed dynamic collection that has a fixed type for keys and values
- [ObjectTable](#objecttable) - same as Table, but can only store objects
<!-- [Linked Table](#linkedtable) -->

## LinkedTable

This section is coming soon!

<!-- TODO! -->

<!-- ## Choosing a Collection Type

Depending on the needs of your project, you may choose to -->

<!-- ## LinkedTable

TODO: ... -->
