// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_function, unused_let_mut)]
// ANCHOR: math
module book::math;

/// Function takes two arguments of type `u64` and returns their sum.
/// The `public` visibility modifier makes the function accessible from
/// outside the module.
public fun add(a: u64, b: u64): u64 {
    a + b
}

#[test]
fun test_add() {
    let sum = add(1, 2);
    assert!(sum == 3);
}
// ANCHOR_END: math

// ANCHOR: return_nothing
fun return_nothing() {
    // empty expression, function returns `()`
}
// ANCHOR_END: return_nothing

// ANCHOR: tuple_return
fun get_name_and_age(): (vector<u8>, u8) {
    (b"John", 25)
}
// ANCHOR_END: tuple_return

#[test] fun test_get_name_and_age() {
// ANCHOR: tuple_return_imm
// Tuple must be destructured to access its elements.
// Name and age are declared as immutable variables.
let (name, age) = get_name_and_age();
assert!(name == b"John");
assert!(age == 25);
// ANCHOR_END: tuple_return_imm

// ANCHOR: tuple_return_mut
// declare name as mutable, age as immutable
let (mut name, age) = get_name_and_age();
// ANCHOR_END: tuple_return_mut

// ANCHOR: tuple_return_ignore
// ignore the name, only use the age
let (_, age) = get_name_and_age();
// ANCHOR_END: tuple_return_ignore
}
