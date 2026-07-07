// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: string_alias
module book::string_alias;

use std::string::String;

/// Alias `std::string::length` as `String.num_bytes`.
/// A local alias can be declared for any type, even an external one.
use fun std::string::length as String.num_bytes;

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_string_alias() {
    let s: String = "Hello";

    // Same function, two names: the built-in method and our alias.
    assert_eq!(s.length(), 5);
    assert_eq!(s.num_bytes(), 5);
}
// ANCHOR_END: string_alias
