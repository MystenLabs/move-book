// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field)]
module book::struct_syntax;

// ANCHOR: def
use std::string::String;

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
    /// The edition of the record, if defined.
    edition: Option<u16>,
}
// ANCHOR_END: def

// ANCHOR: positional_def
/// The duration of a record: minutes and seconds.
public struct Duration(u64, u64)
// ANCHOR_END: positional_def

// ANCHOR: getter
/// Returns the name of the artist. A "getter" for the `name` field.
public fun name(artist: &Artist): String {
    artist.name
}
// ANCHOR_END: getter

// ANCHOR: setter
/// Updates the name of the artist. A "setter" for the `name` field.
public fun set_name(artist: &mut Artist, name: String) {
    artist.name = name;
}
// ANCHOR_END: setter

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_pack_access_unpack() {
    // ANCHOR: pack
    let mut artist = Artist {
        name: "The Beatles",
    };
    // ANCHOR_END: pack

    // ANCHOR: pack_shorthand
    let name: String = "Queen";

    // The local variable `name` has the same name as the field, so
    // instead of `Artist { name: name }` we can write:
    let queen = Artist { name };
    // ANCHOR_END: pack_shorthand

    // ANCHOR: access
    // Read the `name` field of the `Artist` struct.
    assert_eq!(artist.name, "The Beatles");

    // Mutate the `name` field. Requires `artist` to be declared as `mut`.
    artist.name = "Led Zeppelin";

    // Check that the `name` field has been mutated.
    assert_eq!(artist.name, "Led Zeppelin");
    // ANCHOR_END: access

    // ANCHOR: getter_setter_use
    // Call the setter and then the getter defined above.
    artist.set_name("Pink Floyd");
    assert_eq!(artist.name(), "Pink Floyd");
    // ANCHOR_END: getter_setter_use

    // ANCHOR: unpack
    // Unpack the `Artist` struct, binding the value of the `name`
    // field to a new variable `name`.
    let Artist { name } = artist;
    // ANCHOR_END: unpack

    // ANCHOR: unpack_ignore
    // Unpack the `Artist` struct and ignore the `name` field.
    let Artist { name: _ } = queen;
    // ANCHOR_END: unpack_ignore
}

#[test]
fun test_unpack_rest() {
    // ANCHOR: unpack_rest
    let record = Record {
        title: "Abbey Road",
        artist: Artist { name: "The Beatles" },
        year: 1969,
        is_debut: false,
        edition: option::none(),
    };

    // Unpack the `Record`, keeping `title` and `artist`, and
    // ignoring all of the other fields with `..`.
    let Record { title, artist, .. } = record;

    assert_eq!(title, "Abbey Road");

    // The `artist` binding holds a non-discardable `Artist` value,
    // so it, in turn, must be unpacked as well.
    let Artist { name: _ } = artist;
    // ANCHOR_END: unpack_rest
}

#[test]
fun test_positional() {
    // ANCHOR: positional_use
    // Pack a positional struct - parentheses instead of curly braces.
    let duration = Duration(3, 5);

    // Access the fields by their position, starting at 0.
    assert_eq!(duration.0, 3);
    assert_eq!(duration.1, 5);

    // Unpack the struct, binding each field by its position.
    let Duration(minutes, seconds) = duration;
    // ANCHOR_END: positional_use
}
