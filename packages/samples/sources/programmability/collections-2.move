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
// ANCHOR_END: vec_set
