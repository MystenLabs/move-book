// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
// ANCHOR: custom
module book::custom_string;

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
// ANCHOR_END: custom

#[test_only]
use std::unit_test::assert_eq;

#[test] fun string_literals() {
// ANCHOR: literals
// The type of a string literal is inferred from the context:
// it can be a UTF-8 `String`...
let hello: std::string::String = "Hello";

// ...an ASCII `String`...
let ascii: std::ascii::String = "ASCII";

// ...or a plain vector of bytes.
let bytes: vector<u8> = "Hello";

// A byte string literal always yields a `vector<u8>`.
let bytes = b"Hello";

// So does a hex string literal: each pair of hex digits is one byte.
let bytes: vector<u8> = x"48656C6C6F"; // "Hello"
// ANCHOR_END: literals

// ANCHOR: escapes
// Special characters are written with the `\` escape: `\n` - newline,
// `\r` - carriage return, `\t` - tab, `\\` - backslash, `\"` - double
// quote, and `\xHH` - a byte written as two hex digits.
let escaped: std::string::String = "Quote: \"...\"\nNew line,\ttab, \\ and \x41 is 'A'";
// ANCHOR_END: escapes
}

#[test] fun using_strings_utf8() {
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

#[test] fun common_operations() {
use std::string::String;

// ANCHOR: common_ops
let mut str: String = "Hello,";
let another: String = " World!";

// `append(String)` adds the content to the end of the string.
str.append(another);
assert_eq!(str, "Hello, World!");

// `substring(start, end)` copies a slice of the string.
assert_eq!(str.substring(0, 5), "Hello");

// `index_of(&String)` returns the index of the first occurrence...
assert_eq!(str.index_of(&"World"), 7);

// ...or the length of the string if there is no occurrence.
assert_eq!(str.index_of(&"Rust"), str.length());

// Strings can be compared with `==` and `!=`; the comparison is
// done byte by byte.
assert!(str == "Hello, World!");

// `length()` returns the number of bytes in the string.
assert_eq!(str.length(), 13);

// Methods can also be chained! Get the length of a substring.
assert_eq!(str.substring(0, 5).length(), 5);

// `is_empty()` returns true if the string is empty.
assert_eq!(str.is_empty(), false);

// `as_bytes()` returns the underlying byte vector for custom operations.
let bytes: &vector<u8> = str.as_bytes();
// ANCHOR_END: common_ops
}

#[test] fun number_to_string() {
// ANCHOR: number_to_string
// Every unsigned integer type has a `to_string` method, which
// converts the number into its decimal representation.
assert_eq!(42u64.to_string(), "42");
assert_eq!(255u8.to_string(), "255");
assert_eq!(1000000u128.to_string(), "1000000");
// ANCHOR_END: number_to_string
}

#[test] fun safe_strings() {
use std::string;

// ANCHOR: safe_utf8
// `try_utf8` returns `Some(String)` if the bytes are valid UTF-8...
let hello = string::try_utf8(b"Hello");
assert_eq!(hello.is_some(), true);

// ...and `None` if they are not.
let invalid = string::try_utf8(b"\xFF");
assert_eq!(invalid.is_none(), true);

// The `.try_to_string()` alias on `vector<u8>` does the same.
let hello = b"Hello".try_to_string();
assert_eq!(hello.is_some(), true);
// ANCHOR_END: safe_utf8
}

#[test] fun utf8_limitations() {
use std::string::String;

// ANCHOR: limitations
// `length()` returns the number of bytes, not characters!
let ascii_only: String = "hello"; // 5 characters, 5 bytes
let accented: String = "héllo"; // 5 characters, 6 bytes
let emoji: String = "🥳"; // 1 character, 4 bytes

assert_eq!(ascii_only.length(), 5);
assert_eq!(accented.length(), 6);
assert_eq!(emoji.length(), 4);
// ANCHOR_END: limitations
}

// ANCHOR: substring_abort
#[test, expected_failure]
fun test_substring_aborts_mid_character() {
    let s: std::string::String = "héllo";
    // 'é' occupies bytes 1 and 2 - slicing through it aborts
    let _ = s.substring(0, 2);
}
// ANCHOR_END: substring_abort

#[test] fun using_ascii_strings() {
// ANCHOR: ascii
// The `.to_ascii_string()` alias on `vector<u8>` constructs an
// `ascii::String`; it aborts if any byte is not valid ASCII.
let hey = b"Hey".to_ascii_string();

// ASCII strings provide the same core operations as UTF-8 strings:
// `length`, `append`, `insert`, `substring`, `index_of`, and so on.
assert_eq!(hey.length(), 3);

// As well as some unique ones, like changing the case...
assert_eq!(hey.to_uppercase(), "HEY");
assert_eq!(hey.to_lowercase(), "hey");

// ...and checking if all characters are printable.
assert_eq!(hey.all_characters_printable(), true);

// An `ascii::String` can always be converted into a UTF-8 `String`,
let hey_utf8 = hey.to_string();

// and a UTF-8 `String` - into ASCII, if its contents allow it.
let hey_ascii = hey_utf8.to_ascii();
// ANCHOR_END: ascii
}
