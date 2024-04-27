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

module book::string_ascii {
    // use std::ascii::String;

    #[allow(unused_variable)]
    #[test]
    fun using_strings() {
// ANCHOR: ascii
// the module is `std::ascii` and the type is `String`
use std::ascii::{Self, String};

// strings can be created using the `string` function
// type declaration is not necessary, we put it here for clarity
let hey: String = ascii::string(b"Hey");

// there is a handy alias `.to_ascii_string()` on the `vector<u8>` type
let hey = b"Hey".to_ascii_string();

// ANCHOR_END: ascii
    }
}

module book::string_safe_utf {

}

#[allow(unused_variable)]
module book::string_utf {
    #[test]
    fun using_strings() {
// ANCHOR: utf8
// the module is `std::string` and the type is `String`
use std::string::{Self, String};

// strings are normally created using the `utf8` function
// type declaration is not necessary, we put it here for clarity
let hello: String = string::utf8(b"Hello");

// The `.to_string()` alias on the `vector<u8>` is more convenient
let hello = b"Hello".to_string();
// ANCHOR_END: utf8
    }

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
