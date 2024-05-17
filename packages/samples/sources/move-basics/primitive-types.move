// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::primitive_types {

#[test, allow(unused_variable, unused_let_mut)]
fun test_primitive_types() {

// ANCHOR: variables_and_assignment
let x: bool = true;
let mut y: u8 = 42;
// ANCHOR_END: variables_and_assignment

// ANCHOR: shadowing
let x: u8 = 42;
let x: u16 = 42;
// ANCHOR_END: shadowing

// ANCHOR: boolean
let x = true;
let y = false;
// ANCHOR_END: boolean

// ANCHOR: integers
let x: u8 = 42;
let y: u16 = 42;
// ...
let z: u256 = 42;
// ANCHOR_END: integers

// ANCHOR: integer_explicit_type
// Both are equivalent
let x: u8 = 42;
let x = 42u8;
// ANCHOR_END: integer_explicit_type

// ANCHOR: cast_as
let x: u8 = 42;
let y: u16 = x as u16;
let z = 2 * (x as u16); // ambiguous, requires parentheses
// ANCHOR_END: cast_as

// ANCHOR: overflow
let x: u8 = 255;
let y: u8 = 255;
let z: u16 = (x as u16) + ((y as u16) * 2);
// ANCHOR_END: overflow
}
}
