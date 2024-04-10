// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: custom
module book::custom_string {
    /// Anyone can implement a custom string-like type by wrapping a vector.
    public struct MyString {
        bytes: vector<u8>,
    }

    /// Implement a `from_bytes` function to convert a vector of bytes to a string.
    public fun from_bytes(bytes: vector<u8>): MyString {
        MyString { bytes }
    }

    /// Implement a `bytes` function to convert a string to a vector of bytes.
    public fun bytes(self: &MyString): &vector<u8> {
        &self.bytes
    }
}
// ANCHOR_END: custom

// ANCHOR: ascii
module book::string_ascii {
    // use std::ascii::String;

    #[test]
    fun using_strings() {
        // strings are normally created using the `utf8` function
        // let mut hello = string::utf8(b"Hello");
        // let world = string::utf8(b", World!");

        // // strings can be concatenated using the `append_utf8` function
        // let hello_world = hello.append_utf8(*world.bytes());

        // // just like any other type, strings can be compared
        // assert!(hello_world == string::utf8(b"Hello, World!"), 0x0);
    }
}
// ANCHOR_END: ascii

module book::string_safe_utf {
    #[test]
    fun safe_strings() {
// ANCHOR: safe_utf8
// this is a valid UTF-8 string
let hello = b"Hello".try_to_string();

assert!(hello.is_some(), 0); // abort if the value is not valid UTF-8

// this is not a valid UTF-8 string
let invalid = b"\xFF".try_to_string();

assert!(invalid.is_none(), 0); // abort if the value is valid UTF-8
// ANCHOR_END: safe_utf8
    }
}

module book::string_utf {
    #[test]
    fun using_strings() {
// ANCHOR: utf8
// strings are normally created using the `utf8` function
let mut hello = b"Hello".to_string();
let world = b", World!".to_string();

// strings can be concatenated using the `append_utf8` function
hello.append_utf8(*world.bytes()); // mutates the value

// just like any other type, strings can be compared
assert!(hello == b"Hello, World!".to_string(), 0x0);
// ANCHOR_END: utf8
    }
}
