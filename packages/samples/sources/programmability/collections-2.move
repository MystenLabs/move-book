// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field, unused_use)]
// ANCHOR: vec_set
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
    let set = vec_set::empty<u8>(); // create an empty set
    let mut set = vec_set::singleton(1); // create a set with a single item

    set.insert(2); // add an item to the set
    set.insert(3);

    assert_eq!(set.contains(&1), true); // check if an item is in the set
    assert_eq!(set.size(), 3); // get the number of items in the set
    assert_eq!(set.is_empty(), false); // check if the set is empty

    set.remove(&2); // remove an item from the set
}
// ANCHOR_END: vec_set
