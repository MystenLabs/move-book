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

#[test] fun use_option() {

// ANCHOR: usage
// `option::some` creates an `Option` value with a value.
let mut opt = option::some(b"Alice");

// `option::none` creates an `Option` without a value. We need to specify the
// type since it can't be inferred from context.
let empty : Option<u64> = option::none();

// `option.is_some()` returns true if option contains a value.
assert_eq!(opt.is_some(), true);
assert_eq!(empty.is_none(), true);

// internal value can be `borrow`ed and `borrow_mut`ed.
assert_ref_eq!(opt.borrow(), &b"Alice");

// `option.extract` takes the value out of the option, leaving the option empty.
let inner = opt.extract();

// `option.is_none()` returns true if option is None.
assert_eq!(opt.is_none(), true);
// ANCHOR_END: usage
}
