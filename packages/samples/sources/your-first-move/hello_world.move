// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::hello_world;

use std::string::String;

public fun hello_world(): String {
    b"Hello, World!".to_string()
}

#[test]
fun test_is_hello_world() {
    let expected = b"Hello, World!".to_string();
    assert!(hello_world() == expected)
}
