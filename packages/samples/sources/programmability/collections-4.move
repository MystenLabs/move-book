// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field, unused_variable, lint(collection_equality))]
module book::collections_compare_vec_set;

use sui::vec_set;

#[test, expected_failure]
fun test_compare() {
// ANCHOR: vec_set_comparison
let mut set1 = vec_set::empty();
set1.insert(1);
set1.insert(2);

let mut set2 = vec_set::empty();
set2.insert(2);
set2.insert(1);

assert!(set1 == set2); // aborts!
// ANCHOR_END: vec_set_comparison
}
