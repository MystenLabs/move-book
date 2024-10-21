// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// This module contains a function that returns a string "Hello, World!".
module book::hello_world_docs;

use std::string::String;

/// As the name says: returns a string "Hello, World!".
public fun hello_world(): String {
    b"Hello, World!".to_string()
}

#[test]
/// This is a test for the `hello_world` function.
fun test_is_hello_world() {
    let expected = b"Hello, World!".to_string();
    let actual = hello_world();

    assert!(actual == expected)
}
