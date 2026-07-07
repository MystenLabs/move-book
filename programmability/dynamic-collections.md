> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Dynamic Collections

The [Sui Framework](./sui-framework) offers a variety of collection types that build on the
[dynamic fields](./dynamic-fields) and [dynamic object fields](./dynamic-object-fields) concepts.
These collections are designed to be a safer and more understandable way to store and manage dynamic
fields and objects.

For each collection type we will specify the primitive they use, and the specific features they
offer.

> Unlike dynamic (object) fields which operate on UID, collection types have their own type and
> allow calling [associated functions](./../move-basics/struct-methods).

## Common Concepts

All five collections follow the same shape: a struct with the `key` and `store` abilities, holding
its own `UID` and a `size` counter. The entries are attached to that `UID` as dynamic fields. This
is why creating a collection requires a mutable reference to the
[transaction context](./transaction-context) - a fresh `UID` has to be derived from it - and why a
collection is typically stored as a field of another object, as the examples below show.

All of the collection types share the same set of core methods:

- `new` - creates a new, empty collection
- `add` - adds a field to the collection ([LinkedTable](#linkedtable) uses `push_front` and
  `push_back` instead)
- `remove` - removes a field from the collection and returns the value
- `borrow` - borrows a field from the collection
- `borrow_mut` - borrows a mutable reference to a field from the collection
- `contains` - checks if a field exists in the collection
- `length` - returns the number of fields in the collection
- `is_empty` - checks if the `length` is 0
- `destroy_empty` - destroys the collection, aborting if it still contains fields

The last method is what makes collections safer than raw dynamic fields: because collections track
their size, they cannot be destroyed while non-empty, which rules out
[orphaned fields](./dynamic-fields#orphaned-dynamic-fields). The flip side of this protection is
that a collection whose values cannot be dropped has to be emptied entry by entry before it can be
destroyed - and since the number of dynamic fields accessed per transaction is
[limited](./../guides/building-against-limits), dismantling a large collection may take more than
one transaction.

Another property, inherited from dynamic fields, is that the keys are not discoverable onchain:
to access an entry, the code has to know its key. Offchain tooling can still list all entries, as
they are stored as dynamic fields on the collection's `UID`. The only collection that can be
iterated onchain is [LinkedTable](#linkedtable).

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

Bag, as the name suggests, acts as a "bag" of heterogeneous values. It is a simple, non-generic
type built on [dynamic fields](./dynamic-fields), and it can store any data. Bag is the right
choice when a single container has to hold values of different types - for example, a game
character carrying items of various kinds, or a user profile storing unrelated settings side by
side.

```move
module sui::bag;

public struct Bag has key, store {
    /// the ID of this bag
    id: UID,
    /// the number of key-value pairs in the bag
    size: u64,
}
```

_See [full documentation for sui::bag][bag-framework] module._

Since Bag stores values of any type, it offers one extra method:

- `contains_with_type` - checks if a field exists with a specific type

Used as a struct field:

```move
/// Imported from the `sui::bag` module.
use sui::bag::{Self, Bag};

/// An example of a `Bag` as a struct field.
public struct Carrier has key {
    id: UID,
    bag: Bag
}
```

Using the Bag:

```move
let mut bag = bag::new(ctx);

// bag has the `length` function to get the number of elements
assert_eq!(bag.length(), 0);

// the type of the value is defined at insertion; here it is a `String`
let value: String = "my_value";
bag.add(b"my_key", value);

// length has changed to 1
assert_eq!(bag.length(), 1);

// in order: `borrow`, `borrow_mut` and `remove`
// the value type must be specified
let field_ref: &String = &bag[b"my_key"];
let field_mut: &mut String = &mut bag[b"my_key"];
let field: String = bag.remove(b"my_key");

// length is back to 0 - we can unpack
bag.destroy_empty();
```

## ObjectBag

Defined in the `sui::object_bag` module. Identical to [Bag](#bag), but uses
[dynamic object fields](./dynamic-object-fields) internally. Can only store objects as values, and
in exchange keeps them discoverable by their IDs in offchain tooling. Use it for the same
heterogeneous scenarios as Bag when the stored values are assets that should remain visible in
wallets and explorers - such as an inventory of NFTs of different types.

Like dynamic object fields, ObjectBag offers the `value_id` function, which returns the `ID` of a
stored object without specifying its type.

_See [full documentation for sui::object_bag][object-bag-framework] module._

## Table

Table is a typed dynamic collection that has a fixed type for keys and values. It is built on
[dynamic fields](./dynamic-fields) and defined in the `sui::table` module. Table is the go-to
collection for large uniform registries: user records, balances, or configuration entries keyed by
an address or a name - like the `UserRegistry` in the example below.

```move
module sui::table;

public struct Table<phantom K: copy + drop + store, phantom V: store> has key, store {
    /// the ID of this table
    id: UID,
    /// the number of key-value pairs in the table
    size: u64,
}
```

_See [full documentation for sui::table][table-framework] module._

Since the type of the values is fixed, Table offers one extra method:

- `drop` - destroys the table even if it is not empty; only available when the value type has the
  [drop](./../move-basics/drop-ability) ability

Used as a struct field:

```move
/// Imported from the `sui::table` module.
use sui::table::{Self, Table};

/// Some record type with `store`
public struct Record has store { /* ... */ }

/// An example of a `Table` as a struct field.
public struct UserRegistry has key {
    id: UID,
    table: Table<address, Record>
}
```

Using the Table:

```move
// Table requires explicit type parameters for the key and value
// ...but does it only once in initialization.
let mut table = table::new<address, String>(ctx);

// table has the `length` function to get the number of elements
assert_eq!(table.length(), 0);

table.add(@0xa11ce, "my_value");
table.add(@0xb0b, "another_value");

// length has changed to 2
assert_eq!(table.length(), 2);

// in order: `borrow`, `borrow_mut` and `remove`
let value_ref = &table[@0xa11ce];
let value_mut = &mut table[@0xa11ce];

// removing both values
let _value = table.remove(@0xa11ce);
let _another_value = table.remove(@0xb0b);

// length is back to 0 - we can unpack
table.destroy_empty();
```

## ObjectTable

Defined in the `sui::object_table` module. Identical to [Table](#table), but uses
[dynamic object fields](./dynamic-object-fields) internally. Can only store objects as values, and
in exchange keeps them discoverable by their IDs in offchain tooling. Use it when a registry
stores whole objects of the same type - for example, user profile objects keyed by the owner's
address - and each of them should stay individually discoverable.

Like dynamic object fields, ObjectTable offers the `value_id` function, which returns the `ID` of
a stored object without specifying its type.

_See [full documentation for sui::object_table][object-table-framework] module._

Storing objects requires the value type to have the `key` and `store` abilities:

```move
/// Imported from the `sui::object_table` module.
use sui::object_table::{Self, ObjectTable};

/// A profile is an object - it has the `key` and `store` abilities.
public struct Profile has key, store {
    id: UID,
    name: String,
}

/// An example of an `ObjectTable` as a struct field.
public struct ProfileRegistry has key {
    id: UID,
    profiles: ObjectTable<address, Profile>
}
```

Using the ObjectTable:

```move
let mut profiles = object_table::new<address, Profile>(ctx);

// the interface is the same as the regular `Table`
profiles.add(@0xa11ce, Profile {
    id: object::new(ctx),
    name: "Alice",
});

// the stored object keeps its `ID` and can be looked up without its type
let profile_id = profiles.value_id(@0xa11ce); // Option<ID>

// objects cannot be dropped - remove the entry before destroying the table
let profile = profiles.remove(@0xa11ce);
profiles.destroy_empty();
```

## LinkedTable

Defined in the `sui::linked_table` module. Built on [dynamic fields](./dynamic-fields), similar to
[Table](#table), but the entries are linked together, allowing insertion at either end, ordered
removal, and onchain iteration. This makes it the choice
for anything that must be enumerated or processed in order onchain: queues and waitlists,
leaderboards, or registries whose entries have to be listed - like the `AdminRegistry` in the
example below.

```move
module sui::linked_table;

public struct LinkedTable<K: copy + drop + store, phantom V: store> has key, store {
    /// the ID of this table
    id: UID,
    /// the number of key-value pairs in the table
    size: u64,
    /// the front of the table, i.e. the key of the first entry
    head: Option<K>,
    /// the back of the table, i.e. the key of the last entry
    tail: Option<K>,
}
```

_See [full documentation for sui::linked_table][linked-table-framework] module._

Since the entries in LinkedTable are linked together, adding an entry requires stating where it
goes, so instead of `add` it has:

- `push_front` - inserts a key-value pair at the front of the table
- `push_back` - inserts a key-value pair at the back of the table
- `pop_front` - removes the front of the table, returns the key and value
- `pop_back` - removes the back of the table, returns the key and value

Additionally, the `front`, `back`, `prev`, and `next` methods return the keys of neighboring
entries, making it possible to iterate over the table onchain. Like [Table](#table), LinkedTable
offers the `drop` method for value types with the [drop](./../move-basics/drop-ability) ability.

Used as a struct field:

```move
/// Imported from the `sui::linked_table` module.
use sui::linked_table::{Self, LinkedTable};

/// Some record type with `store`
public struct Permissions has store { /* ... */ }

/// An example of a `LinkedTable` as a struct field.
public struct AdminRegistry has key {
    id: UID,
    linked_table: LinkedTable<address, Permissions>
}
```

Using the LinkedTable:

```move
// LinkedTable requires explicit type parameters for the key and value
// ...but does it only once in initialization.
let mut linked_table = linked_table::new<address, String>(ctx);

// linked_table has the `length` function to get the number of elements
assert_eq!(linked_table.length(), 0);

linked_table.push_front(@0xa0a, "first_value");
linked_table.push_back(@0xb1b, "second_value");
linked_table.push_back(@0xc2c, "third_value");

// length has changed to 3
assert_eq!(linked_table.length(), 3);

// in order: `borrow`, `borrow_mut` and `remove`
let first_value_ref = &linked_table[@0xa0a];
let second_value_mut = &mut linked_table[@0xb1b];

// remove by key, from the beginning or from the end
let _second_value = linked_table.remove(@0xb1b);
let (_first_addr, _first_value) = linked_table.pop_front();
let (_third_addr, _third_value) = linked_table.pop_back();

// length is back to 0 - we can unpack
linked_table.destroy_empty();
```

## Pricing

Collections inherit the pricing of the primitives they are built on. Creating a collection adds an
object with a `UID` to storage; each entry is priced as a
[dynamic field](./dynamic-fields#dynamic-fields-vs-fields), or - in the Object-variants - as a
[dynamic object field](./dynamic-object-fields#pricing-differences), with its higher, two-object
cost per entry.

## Choosing a Collection Type

A short decision guide:

- The key and value types are fixed and known - use [Table](#table); if the values vary in type,
  use [Bag](#bag);
- The values are objects that should stay visible to wallets and explorers - take the
  [ObjectTable](#objecttable) / [ObjectBag](#objectbag) variant;
- The collection has to be iterated onchain or preserve insertion order - use
  [LinkedTable](#linkedtable), the only one of the five that links its entries;
- The collection is small, bounded, and needs to be embedded or compared as a plain value - the
  vector-based [collections](./collections) from the earlier section may be a better fit than a
  dynamic one.

> One more thing to keep in mind: the entries of a dynamic collection live outside of the struct
> itself. Serializing a `Table` (for example, with [BCS](./bcs)) or comparing two tables only
> takes the `id` and `size` fields into account - never the contents.

## Summary

- [Bag](#bag) - a simple collection that can store any type of data; fits containers of
  heterogeneous values, such as inventories.
- [ObjectBag](#objectbag) - same as Bag, but can only store objects; fits heterogeneous assets
  that should stay visible in wallets and explorers.
- [Table](#table) - a typed dynamic collection that has a fixed type for keys and values; fits
  large uniform registries.
- [ObjectTable](#objecttable) - same as Table, but can only store objects; fits registries of
  same-type objects that should stay individually discoverable.
- [LinkedTable](#linkedtable) - similar to Table but the entries are linked together; fits queues
  and anything iterated onchain.

## Next Steps

This section concludes the tour of dynamic fields and the collections built on top of them. In the
next section we will move on to design patterns, starting with the
[Witness](./witness-pattern) pattern.

## Further Reading

- [sui::table][table-framework] module documentation.
- [sui::object_table][object-table-framework] module documentation.
- [sui::linked_table][linked-table-framework] module documentation.
- [sui::bag][bag-framework] module documentation.
- [sui::object_bag][object-bag-framework] module documentation.

[table-framework]: https://docs.sui.io/references/framework/sui/table
[object-table-framework]: https://docs.sui.io/references/framework/sui/object_table
[linked-table-framework]: https://docs.sui.io/references/framework/sui/linked_table
[bag-framework]: https://docs.sui.io/references/framework/sui/bag
[object-bag-framework]: https://docs.sui.io/references/framework/sui/object_bag
