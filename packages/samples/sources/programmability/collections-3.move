// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field, unused_variable, unused_use)]
// ANCHOR: vec_map
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
// ANCHOR_END: vec_map
