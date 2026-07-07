// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::hello_world;

use std::string::String;

public fun hello_world(): String {
    "Hello, World!"
}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_is_hello_world() {
    let expected: String = "Hello, World!";
    assert_eq!(hello_world(), expected);
}
