// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field)]
// ANCHOR: vec_set
module book::collections_vec_set {
    use sui::vec_set::{Self, VecSet};

    public struct App has drop {
        /// `VecSet` used in the struct definition
        subscribers: VecSet<address>
    }

    #[test]
    fun vec_set_playground() {
        let set = vec_set::empty<u8>(); // create an empty set
        let mut set = vec_set::singleton(1); // create a set with a single item

        set.insert(2); // add an item to the set
        set.insert(3);

        assert!(set.contains(&1), 0); // check if an item is in the set
        assert!(set.size() == 3, 1); // get the number of items in the set
        assert!(!set.is_empty(), 2); // check if the set is empty

        set.remove(&2); // remove an item from the set
    }
}
// ANCHOR_END: vec_set

#[allow(unused_field, unused_variable)]
// ANCHOR: vec_map
module book::collections {
    use std::string::String;
    use sui::vec_map::{Self, VecMap};

    use fun std::string::utf8 as vector.to_string;

    public struct Metadata has drop {
        name: String,
        /// `VecMap` used in the struct definition
        attributes: VecMap<String, String>
    }

    #[test]
    fun vec_map_playground() {
        let mut map = vec_map::empty(); // create an empty map

        map.insert(2, b"two".to_string()); // add a key-value pair to the map
        map.insert(3, b"three".to_string());

        assert!(map.contains(&2), 0); // check if a key is in the map

        map.remove(&2); // remove a key-value pair from the map
    }
}
// ANCHOR_END: vec_map
