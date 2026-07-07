// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
// ANCHOR: registry
module book::user_registry;

use std::string::String;

/// A struct representing a user record.
public struct User has drop {
    first_name: String,
    middle_name: Option<String>,
    last_name: String,
}

/// Create a new `User` struct with the given fields.
public fun register(
    first_name: String,
    middle_name: Option<String>,
    last_name: String,
): User {
    User { first_name, middle_name, last_name }
}
// ANCHOR_END: registry

#[test_only]
use std::unit_test::{assert_eq, assert_ref_eq};

#[test] fun register_users() {
// ANCHOR: registry_use
// A user with a middle name...
let ada = register(
    "Ada",
    option::some("King"),
    "Lovelace",
);

// ...and a user without one. No reserved values, no guesswork.
let grace = register(
    "Grace",
    option::none(),
    "Hopper",
);
// ANCHOR_END: registry_use
}

#[test] fun use_option() {
// ANCHOR: usage
// `option::some` creates an option holding a value.
let mut opt: Option<String> = option::some("Alice");

// `option::none` creates an empty option. The element type has to
// be specified when it cannot be inferred from use.
let empty: Option<u64> = option::none();

// Checking the state of an option.
assert_eq!(opt.is_some(), true);
assert_eq!(empty.is_none(), true);

// `borrow` reads the value without taking it out of the option.
assert_ref_eq!(opt.borrow(), &"Alice");

// `extract` takes the value out, leaving the option empty.
let inner = opt.extract();
assert_eq!(inner, "Alice");
assert_eq!(opt.is_none(), true);
// ANCHOR_END: usage
}

#[test] fun option_macros() {
// ANCHOR: macros
// `destroy_or!` consumes the option, returning a default when empty.
let value = option::some(10u8).destroy_or!(0);
assert_eq!(value, 10);

let missing = option::none<u8>().destroy_or!(0);
assert_eq!(missing, 0);

// `is_some_and!` tests the value against a condition.
let is_big = option::some(10u8).is_some_and!(|n| *n > 5);
assert_eq!(is_big, true);

// `do!` runs the lambda only when there is a value.
option::some(10u8).do!(|n| assert_eq!(n, 10));
// ANCHOR_END: macros
}
