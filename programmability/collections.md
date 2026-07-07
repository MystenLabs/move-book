> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

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

```move
module book::collections_vector;

use std::string::String;

/// The Book that can be sold by a `BookStore`
public struct Book has key, store {
    id: UID,
    name: String
}

/// The BookStore that sells `Book`s
public struct BookStore has key, store {
    id: UID,
    books: vector<Book>
}
```

Everything from the vector section applies here unchanged; the collection types below follow the
same pattern - plain struct values that can be placed in a field, passed around, and, unlike
[dynamic fields](./dynamic-fields) introduced later in this chapter, fully described by the type of
the object that holds them.

## VecSet

`VecSet` is a collection that stores _unique_ items. Inserting a value that is already present
aborts, so the set is a natural fit for collections that must not contain duplicates, such as a
list of IDs or addresses.

```move
module book::collections_vec_set;

use sui::vec_set::{Self, VecSet};

public struct App has drop {
    /// `VecSet` used in the struct definition
    subscribers: VecSet<address>
}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun vec_set_playground() {
    let mut set = vec_set::empty(); // create an empty set

    set.insert(1u8); // add items to the set
    set.insert(2);
    set.insert(3);

    assert_eq!(set.contains(&1), true); // check if an item is in the set
    assert_eq!(set.length(), 3); // get the number of items in the set
    assert_eq!(set.is_empty(), false); // check if the set is empty

    set.remove(&2); // remove an item from the set
    assert_eq!(set.contains(&2), false);

    // the contents can be taken out as a plain vector, e.g. for iteration
    let items = set.into_keys();
    assert_eq!(items, vector[1, 3]);
}
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

```move
module book::collections_vec_map;

use std::string::String;
use sui::vec_map::{Self, VecMap};

public struct Metadata has drop {
    name: String,
    /// `VecMap` used in the struct definition
    attributes: VecMap<String, String>
}

#[test_only]
use std::unit_test::{assert_eq, assert_ref_eq};

#[test]
fun vec_map_playground() {
    let mut map: VecMap<u64, String> = vec_map::empty(); // create an empty map

    map.insert(2, "two"); // add a key-value pair to the map
    map.insert(3, "three");

    assert_eq!(map.contains(&2), true); // check if a key is in the map
    assert_eq!(map.length(), 2); // get the number of entries

    // index syntax borrows a value by key, aborts if the key is missing
    assert_ref_eq!(&map[&2], &"two");

    // `try_get` copies the value, returns `none` if the key is missing
    assert_eq!(map.try_get(&2), option::some("two"));
    assert_eq!(map.try_get(&4), option::none());

    // an existing value can be replaced through a mutable reference
    *(&mut map[&3]) = "III";

    // `remove` returns the key-value pair
    let (key, value) = map.remove(&2);
    assert_eq!(key, 2);
    assert_eq!(value, "two");
}
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

```move
let mut set1 = vec_set::empty();
set1.insert(1u8);
set1.insert(2);

let mut set2 = vec_set::empty();
set2.insert(2);
set2.insert(1);

assert_eq!(set1, set2); // aborts!
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
