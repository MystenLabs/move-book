// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field)]
// ANCHOR: hero
module book::arena;

use std::string::String;
use sui::display_registry::{Self, DisplayRegistry, DisplayCap};

/// Some object which will be displayed.
public struct Hero has key {
    id: UID,
    class: String,
    level: u64,
}

/// Creates the `Display<Hero>`. Call it exactly once, right after publishing:
/// the registry holds a single `Display` per type, so a second call aborts.
/// It is an `entry` function rather than a `public` one, so that a later
/// package upgrade can remove it - upgrade rules freeze `public` functions,
/// but not `entry` ones.
entry fun create_display(registry: &mut DisplayRegistry, ctx: &mut TxContext) {
    let (mut display, cap) = display_registry::new<Hero>(
        registry,
        internal::permit(),
        ctx,
    );

    display.set(&cap, "name", "{class} (lvl. {level})");
    display.set(&cap, "description", "One of the greatest heroes of all time. Join us!");
    display.set(&cap, "link", "https://example.com/hero/{id}");
    display.set(&cap, "image_url", "https://example.com/hero/{class}.jpg");

    // Share the `Display` so clients can find it, and send the capability to
    // the publisher, who keeps it to update the fields later.
    display.share();
    transfer::public_transfer(cap, ctx.sender());
}
// ANCHOR_END: hero

// ANCHOR: migrate
use sui::display::Display as LegacyDisplay;

/// Claim the `DisplayCap` for the system-migrated `Display<Hero>`, giving up
/// the legacy V1 `Display` object, which is destroyed in the process.
public fun claim_display_cap(
    display: &mut display_registry::Display<Hero>,
    legacy: LegacyDisplay<Hero>,
    ctx: &mut TxContext,
): DisplayCap<Hero> {
    display.claim(legacy, ctx)
}
// ANCHOR_END: migrate

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
