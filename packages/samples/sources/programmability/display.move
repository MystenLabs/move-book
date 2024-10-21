// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0


#[allow(unused_field)]
// ANCHOR: hero
module book::arena;

use std::string::String;
use sui::package;
use sui::display;

/// The One Time Witness to claim the `Publisher` object.
public struct ARENA has drop {}

/// Some object which will be displayed.
public struct Hero has key {
    id: UID,
    class: String,
    level: u64,
}

/// In the module initializer we create the `Publisher` object, and then
/// the Display for the `Hero` type.
fun init(otw: ARENA, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    let mut display = display::new<Hero>(&publisher, ctx);

    display.add(
        b"name".to_string(),
        b"{class} (lvl. {level})".to_string()
    );

    display.add(
        b"description".to_string(),
        b"One of the greatest heroes of all time. Join us!".to_string()
    );

    display.add(
        b"link".to_string(),
        b"https://example.com/hero/{id}".to_string()
    );

    display.add(
        b"image_url".to_string(),
        b"https://example.com/hero/{class}.jpg".to_string()
    );

    // Update the display with the new data.
    // Must be called to apply changes.
    display.update_version();

    transfer::public_transfer(publisher, ctx.sender());
    transfer::public_transfer(display, ctx.sender());
}
// ANCHOR_END: hero

// ANCHOR: background
/// An attempt to standardize the object structure for display.
public struct CounterWithDisplay has key {
    id: UID,
    /// If this field is present it will be displayed in the UI as `name`.
    name: String,
    /// If this field is present it will be displayed in the UI as `description`.
    description: String,
    // ...
    image: String,
    /// Actual fields of the object.
    counter: u64,
    // ...
}
// ANCHOR_END: background

// ANCHOR: nested
/// Some common metadata for objects.
public struct Metadata has store {
    name: String,
    description: String,
    published_at: u64
}

/// The type with nested Metadata field.
public struct LittlePony has key, store {
    id: UID,
    image_url: String,
    metadata: Metadata
}
// ANCHOR_END: nested
