// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field)]
module book::struct_syntax;

use std::string::String;

// ANCHOR: def
/// A struct representing an artist.
public struct Artist {
    /// The name of the artist.
    name: String,
}

/// A struct representing a music record.
public struct Record {
    /// The title of the record.
    title: String,
    /// The artist of the record. Uses the `Artist` type.
    artist: Artist,
    /// The year the record was released.
    year: u16,
    /// Whether the record is a debut album.
    is_debut: bool,
    /// The edition of the record.
    edition: Option<u16>,
}
// ANCHOR_END: def

#[test] fun test_pack_unpack() {

// ANCHOR: pack
let mut artist = Artist {
    name: b"The Beatles".to_string()
};
// ANCHOR_END: pack

// ANCHOR: access
// Access the `name` field of the `Artist` struct.
let artist_name = artist.name;

// Access a field of the `Artist` struct.
assert!(artist.name == b"The Beatles".to_string());

// Mutate the `name` field of the `Artist` struct.
artist.name = b"Led Zeppelin".to_string();

// Check that the `name` field has been mutated.
assert!(artist.name == b"Led Zeppelin".to_string());
// ANCHOR_END: access

// ANCHOR: unpack
// Unpack the `Artist` struct and create a new variable `name`
// with the value of the `name` field.
let Artist { name } = artist;
// ANCHOR_END: unpack

let artist = Artist {
    name: b"The Beatles".to_string()
};

// ANCHOR: unpack_ignore
// Unpack the `Artist` struct and ignore the `name` field.
let Artist { name: _ } = artist;
// ANCHOR_END: unpack_ignore
}
