// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::hello_world_debug;

use std::string::String;
use std::debug;

public fun hello_world(): String {
    let result = b"Hello, World!".to_string();
    debug::print(&result);
    result
}

#[test]
fun test_is_hello_world() {
    let expected = b"Hello, World!".to_string();
    let actual = hello_world();

    assert!(actual == expected)
}
