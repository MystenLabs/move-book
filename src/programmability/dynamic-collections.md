# Dynamic Collections

[Sui Framework](./sui-framework.md) offers a variety of collection types that build on the [dynamic fields](./dynamic-fields.md) and [dynamic object fields](./dynamic-object-fields.md) concepts. These collections are designed to be a safer and more understandable way to store and manage dynamic fields and objects.

For each collection type we will specify the primitive they use, and the specific features they offer.

> Unlike dynamic (object) fields which operate on UID, collection types have their own type and allow calling associated methods.

## Common Concepts

All of the collection types more or less share the same set of methods, which are:

- `add` - adds a field to the collection
- `remove` - removes a field from the collection
- `borrow` - borrows a field from the collection
- `borrow_mut` - borrows a mutable reference to a field from the collection
- `contains` - checks if a field exists in the collection
- `contains_with_type` - checks if a field exists in the collection with a specific type

In the examples we won't focus on these functions, rather
<!-- - `size` - returns the number of fields in the collection -->

## Bag

Bag is a collection type which acts as a heterogeneous container for dynamic fields. It is a simple, non-generic type that can store any data. Bag prevents its fields from being orphaned by disallowing unpacking if there are attached fields.

File: sui-framework/sources/bag.move
```move
public struct Bag has key, store {
    /// the ID of this bag
    id: UID,
    /// the number of key-value pairs in the bag
    size: u64,
}
```

```move
use sui::bag::{Self, Bag};

let ctx = &mut tx_context::dummy();
let mut bag = bag::new(ctx);

bag.add(b"key", 42u64);

// Bag size can always be checked.
assert!(bag.size() == 1, 0);

// Bag provides a way to borrow a field both mut and immutably.
let magic_mut: &mut u64 = bag.borrow_mut(b"key");

assert!(*magic_mut == 42, 1);
*magic_mut = 100;

// Fields can be removed.
let magic: u64 = bag.remove(b"key");

assert!(magic == 100, 1);
assert!(bag.size() == 0, 2);

// Bag can be destroyed only if it's empty!
bag.destroy_empty();
```



- Bag
- ObjectBag
- Linked Table
- Table
- ObjectTable
