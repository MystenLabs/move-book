// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::segment;

use std::string::String;

/// `Segment` enum definition.
public enum Segment has drop, copy {
    /// Empty variant, no value
    Empty,
    /// Variant with a value (positional style)
    String(String),
    /// Variant with named fields
    Special {
        content: vector<u8>,
        encoding: u8, // Encoding tag
    }
}

/// Constructs an `Empty` segment.
public fun new_empty(): Segment { Segment::Empty }

/// Constructs a `String` segment with the `str` value.
public fun new_string(str: String): Segment { Segment::String(str) }

/// Constructs a `Special` segment with the `content` and `encoding` values.
public fun new_special(content: vector<u8>, encoding: u8): Segment {
    Segment::Special {
        content,
        encoding,
    }
}

/// A struct to demonstrate enum capabilities.
public struct Segments(vector<Segment>) has drop, copy;

#[test]
fun test_segments() {
    let _ = Segments(vector[
        Segment::Empty,
        Segment::String(b"hello".to_string()),
        Segment::String(b" move".to_string()),
        Segment::Special { content: b"21", encoding: 1 },
    ]);
}

/// Whether this it's an `Empty` segment.
public fun is_empty_(s: &Segment): bool {
    // Match is an expression, hence we can use it for return value
    match (s) {
        Segment::Empty => true,
        Segment::String(_str) => false,
        Segment::Special { content: _, encoding: _ } => false
    }
}

public fun is_empty(s: &Segment): bool {
    match (s) {
        Segment::Empty => true,
        _ => false, // Anything else returns `false`
    }
}

/// Whether it's a `Special` segment.
public fun is_special(s: &Segment): bool {
    match (s) {
        // Hint: the `..` ignores inner fields
        Segment::Special { .. } => true,
        _ => false,
    }
}

/// Whether it's a `String` segment.
public fun is_string(s: &Segment): bool {
    match (s) {
        Segment::String(_) => true,
        _ => false,
    }
}

/// Returns `Some(String)` if the `Segment` is `String`, `None` otherwise.
public fun try_into_inner_string(s: Segment): Option<String> {
    match (s) {
        Segment::String(str) => option::some(str),
        _ => option::none()
    }
}

/// Return a `String` representation of a segment.
public fun to_string(s: &Segment): String {
    match (*s) {
        // Return an empty string.
        Segment::Empty => b"".to_string(),
        // Return the inner string.
        Segment::String(str) => str,
        // Return the decoded contents based on the encoding.
        Segment::Special { content, encoding } => {
            // Perform a match on the encoding, we only support 0 - ut8, 1 - hex
            match (encoding) {
                // Plain encoding, return content
                0 => content.to_string(),
                // HEX encoding, decode and return
                1 => sui::hex::decode(content).to_string(),
                // We have to provide a wildcard pattern, because values of `u8` are 0-255
                _ => abort
            }
        }
    }
}
