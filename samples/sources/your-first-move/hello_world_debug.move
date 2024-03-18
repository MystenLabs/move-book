// Copyright (c) Damir Shamanaev 2023
// Licensed under the MIT License - https://opensource.org/licenses/MIT

module book::hello_world_debug {
    use std::string::{Self, String};
    use std::debug;

    public fun hello_world(): String {
        let result = string::utf8(b"Hello, World!");
        debug::print(&result);
        result
    }

    #[test]
    fun test_is_hello_world() {
        let expected = string::utf8(b"Hello, World!");
        let actual = hello_world();

        assert!(actual == expected, 0)
    }
}
