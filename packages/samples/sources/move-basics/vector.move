// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::vector_syntax {
#[test_only]
use std::unit_test::assert_eq;

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

#[test] fun vector_access() {
// ANCHOR: access
let v: vector<u8> = vector[10, 20, 30];

// `length` returns the number of elements.
assert_eq!(v.length(), 3);
assert_eq!(v.is_empty(), false);

// The index syntax borrows an element; for copyable
// types the borrowed value can be read directly.
assert_eq!(v[0], 10);

// Accessing an index outside of bounds aborts:
// v[3]; // ABORTS!
// ANCHOR_END: access
}

#[test] fun vector_methods() {
// ANCHOR: methods
let mut v = vector[10u8, 20, 30];

// `push_back` adds an element to the end of the vector.
v.push_back(40); // [10, 20, 30, 40]

// `pop_back` removes the last element and returns it.
let last = v.pop_back(); // [10, 20, 30]
assert_eq!(last, 40);

// `insert` places an element at the given index, shifting
// the elements after it to the right.
v.insert(15, 1); // [10, 15, 20, 30]

// `remove` takes an element out at the given index, shifting
// the elements after it to the left.
let removed = v.remove(2); // [10, 15, 30]
assert_eq!(removed, 20);

// The index syntax can also modify an element in place; the `&mut`
// and `*` in this expression are explained in the References section.
*(&mut v[0]) = 5; // [5, 15, 30]
assert_eq!(v[0], 5);
// ANCHOR_END: methods
}

#[test] fun vector_macros() {
// ANCHOR: macros
let v = vector[1u64, 2, 3, 4];

// `count!` returns the number of elements matching the condition.
let even_count = v.count!(|n| *n % 2 == 0);
assert_eq!(even_count, 2);

// `map!` transforms each element, returning a new vector.
let doubled = v.map!(|n| n * 2);
assert_eq!(doubled, vector[2, 4, 6, 8]);

// `fold!` collapses the vector into a single value,
// in this case - the sum of all elements.
let sum = v.fold!(0, |acc, n| acc + n);
assert_eq!(sum, 10);

// `do!` calls the function on each element of the vector.
let mut total = 0u64;
v.do!(|n| total = total + n);
assert_eq!(total, 10);
// ANCHOR_END: macros
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
