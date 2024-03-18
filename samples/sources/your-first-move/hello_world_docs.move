// Copyright (c) Damir Shamanaev 2023
// Licensed under the MIT License - https://opensource.org/licenses/MIT

/// This module contains a function that returns a string "Hello, World!".
module book::hello_world_docs {
    use std::string::{Self, String};

    /// As the name says: returns a string "Hello, World!".
    public fun hello_world(): String {
        string::utf8(b"Hello, World!")
    }

    #[test]
    /// This is a test for the `hello_world` function.
    fun test_is_hello_world() {
        let expected = string::utf8(b"Hello, World!");
        let actual = hello_world();

        assert!(actual == expected, 0)
    }
}
