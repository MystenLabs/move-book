// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field)]
// ANCHOR: vec_set
module book::collections_vec_set;

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

    assert!(set.contains(&1)); // check if an item is in the set
    assert!(set.size() == 3); // get the number of items in the set
    assert!(!set.is_empty()); // check if the set is empty

    set.remove(&2); // remove an item from the set
}
// ANCHOR_END: vec_set
