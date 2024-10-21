// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::vector_syntax {
#[test] fun test_vector() {
// ANCHOR: literal
// An empty vector of bool elements.
let empty: vector<bool> = vector[];

// A vector of u8 elements.
let v: vector<u8> = vector[10, 20, 30];

// A vector of vector<u8> elements.
let vv: vector<vector<u8>> = vector[
    vector[10, 20],
    vector[30, 40]
];
// ANCHOR_END: literal
}

#[test] fun vector_methods() {
// ANCHOR: methods
let mut v = vector[10u8, 20, 30];

assert!(v.length() == 3);
assert!(!v.is_empty());

v.push_back(40);
let last_value = v.pop_back();

assert!(last_value == 40);
// ANCHOR_END: methods
}
}


module book::non_droppable_vec {

// ANCHOR: no_drop
/// A struct without `drop` ability.
public struct NoDrop {}

#[test]
fun test_destroy_empty() {
    // Initialize a vector of `NoDrop` elements.
    let v = vector<NoDrop>[];

    // While we know that `v` is empty, we still need to call
    // the explicit `destroy_empty` function to discard the vector.
    v.destroy_empty();
}
// ANCHOR_END: no_drop
}
