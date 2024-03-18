// Copyright (c) Damir Shamanaev 2023
// Licensed under the MIT License - https://opensource.org/licenses/MIT

module book::hello_world {
    use std::string::{Self, String};

    public fun hello_world(): String {
        string::utf8(b"Hello, World!")
    }

    #[test]
    fun test_is_hello_world() {
        let expected = string::utf8(b"Hello, World!");
        assert!(hello_world() == expected, 0)
    }
}
