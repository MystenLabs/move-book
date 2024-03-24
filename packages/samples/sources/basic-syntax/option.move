// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: registry
module book::user_registry {
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
}
// ANCHOR_END: registry

#[allow(unused_variable)]
module book::option_usage {
#[test] fun use_option() {

// ANCHOR: usage
// `option::some` creates an `Option` value with a value.
let mut opt = option::some(b"Alice");

// `option.is_some()` returns true if option contains a value.
assert!(opt.is_some(), 1);

// internal value can be `borrow`ed and `borrow_mut`ed.
assert!(opt.borrow() == &b"Alice", 0);

// `option.extract` takes the value out of the option, leaving the option empty.
let inner = opt.extract();

// `option.is_none()` returns true if option is None.
assert!(opt.is_none(), 2);
// ANCHOR_END: usage
}
}
