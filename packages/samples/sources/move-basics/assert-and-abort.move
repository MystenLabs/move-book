// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::assert_abort;

#[test, expected_failure(abort_code = 1, location=Self)]
fun test_abort() {

// ANCHOR: abort
let user_has_access = true;

// abort with a predefined constant if `user_has_access` is false
if (user_has_access) {
    abort 1
};
// ANCHOR_END: abort
}

#[test]
fun show_assert() {
let user_has_access = true;
// ANCHOR: assert
// aborts if `user_has_access` is `false` with abort code 0
assert!(user_has_access, 0);

// expands into:
if (!user_has_access) {
    abort 0
};
// ANCHOR_END: assert
}

// ANCHOR: error_const
/// Error code for when the user has no access.
const ENoAccess: u64 = 0;
/// Trying to access a field that does not exist.
const ENoField: u64 = 1;

/// Updates a record.
public fun update_record(/* ... , */ user_has_access: bool, field_exists: bool) {
    // asserts are way more readable now
    assert!(user_has_access, ENoAccess);
    assert!(field_exists, ENoField);

    /* ... */
}
// ANCHOR_END: error_const

public struct User { is_authorized: bool, value: u64 }

// ANCHOR: error_attribute
#[error]
const ENotAuthorized: vector<u8> = b"The user is not authorized to perform this action";

#[error]
const EValueTooLow: vector<u8> = b"The value is too low, it should be at least 10";

/// Performs an action on behalf of the user.
public fun update_value(user: &mut User, value: u64) {
    assert!(user.is_authorized, ENotAuthorized);
    assert!(value >= 10, EValueTooLow);

    user.value = value;
}
// ANCHOR_END: error_attribute
}
