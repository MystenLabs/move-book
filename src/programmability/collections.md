# Collections

Collection types are a fundamental part of any programming language. They are used to store a collection of data, such as a list of items. The `vector` type has already been covered in the [vector section](../basic-syntax/standard-library.md), and in this chapter we will cover the collection types offered by the Sui Framework.

- [VecSet](#VecSet)
- [VecMap](#VecMap)

## VecSet

`VecSet` is a collection type that stores a set of unique items. It is similar to a `vector`, but it does not allow duplicate items. This makes it useful for storing a collection of unique items, such as a list of unique IDs or addresses.

```move
module book::collections {
    use sui::vec_set::{Self, VecSet};

    struct App has drop {
        /// `VecSet` used in the struct definition
        subscribers: VecSet<address>
    }

    #[test]
    fun vec_set_playground() {
        let set = vec_set::empty(); // create an empty set
        let set = vec_set::sigleton(1); // create a set with a single item

        set.insert(2); // add an item to the set
        set.insert(3);

        assert!(set.contains(1), 0); // check if an item is in the set
        assert!(set.size() == 3, 1); // get the number of items in the set
        assert!(!set.is_empty(), 2); // check if the set is empty

        set.remove(2); // remove an item from the set
    }
}
```

## VecMap

`VecMap` is a collection type that stores a map of key-value pairs. It is similar to a `VecSet`, but it allows you to associate a value with each item in the set. This makes it useful for storing a collection of key-value pairs, such as a list of addresses and their balances, or a list of user IDs and their associated data.

Keys in a `VecMap` are unique, and each key can only be associated with a single value. If you try to insert a key-value pair with a key that already exists in the map, the old value will be replaced with the new value.

```move
module book::collections {
    use std::string::String;
    use sui::vec_map::{Self, VecMap};

    struct Metadata has drop {
        name: String
        /// `VecMap` used in the struct definition
        attributes: VecMap<String, String>
    }

    #[test]
    fun vec_map_playground() {
        let mut map = vec_map::empty(); // create an empty map

        map.insert(2, b"two".to_string()); // add a key-value pair to the map
        map.insert(3, b"three".to_string());

        assert!(map.contains(1), 0); // check if a key is in the map

        map.remove(&2); // remove a key-value pair from the map
    }
}
```
