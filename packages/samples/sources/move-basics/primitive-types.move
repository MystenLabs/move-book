// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::primitive_types;

#[test, allow(unused_variable, unused_let_mut, unused_assignment)]
fun variables_and_assignment() {
// ANCHOR: variables_and_assignment
// The type annotation is optional when it can be inferred.
let x: bool = true;
let y = 10u8;

// A `mut` variable can be reassigned with the `=` operator.
let mut z: u8 = 42;
z = 43;
// ANCHOR_END: variables_and_assignment

// ANCHOR: shadowing
let x: u8 = 42;

// The new `x` replaces the previous one, and may
// even have a different type.
let x: u16 = (x as u16) + 1;
// ANCHOR_END: shadowing
}

#[test, allow(unused_variable)]
fun booleans() {
// ANCHOR: boolean
// The type of a boolean is always inferred.
let is_ready = true;
let is_done = false;

// Logical operators: `&&` (and), `||` (or), and `!` (not).
let in_progress = is_ready && !is_done;
// ANCHOR_END: boolean
}

#[test, allow(unused_variable)]
fun integers() {
// ANCHOR: integers
let small: u8 = 42;
let medium: u16 = 1_000; // underscores improve readability
let large: u256 = 100_000_000_000;
let hex: u64 = 0x2A; // hexadecimal literal, 42
// ANCHOR_END: integers

// ANCHOR: integer_explicit_type
// Both are equivalent.
let x: u8 = 42;
let x = 42u8;
// ANCHOR_END: integer_explicit_type

// ANCHOR: comparison
let a = 10u8;
let b = 20u8;

// Comparison produces a `bool`; the operands must be of the same type.
let is_less = a < b; // true
let is_equal = a == b; // false
// ANCHOR_END: comparison
}

#[test, allow(unused_variable)]
fun casting() {
// ANCHOR: cast_as
let x: u8 = 42;
let y: u16 = x as u16;
let z = 2 * (x as u16); // ambiguity requires parentheses
// ANCHOR_END: cast_as

// ANCHOR: overflow
// The same values that would overflow `u8` arithmetic
// fit comfortably once upcast to `u16`.
let x: u8 = 255;
let y: u8 = 255;
let z: u16 = (x as u16) + ((y as u16) * 2);
// ANCHOR_END: overflow
}

#[test, expected_failure(arithmetic_error, location = Self)]
fun downcast_abort() {
// ANCHOR: downcast
let x: u16 = 300;
let y = x as u8; // ABORTS! 300 does not fit into `u8`
// ANCHOR_END: downcast
}

#[test, expected_failure(arithmetic_error, location = Self)]
fun overflow_abort() {
// ANCHOR: overflow_abort
let x = 255u8;
let y = 1u8;
let z = x + y; // ABORTS! The result does not fit into `u8`
// ANCHOR_END: overflow_abort
}
