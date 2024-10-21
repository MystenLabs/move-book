// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: hero_to_bytes
// TODO: better example (external module...)
module book::hero_to_bytes;

// Alias for the `bcs::to_bytes` method. Imported aliases should be defined
// in the top of the module.
// public use fun bcs::to_bytes as Hero.to_bytes;

/// A struct representing a hero.
public struct Hero has drop {
    health: u8,
    mana: u8,
}

/// Create a new Hero.
public fun new(): Hero { Hero { health: 100, mana: 100 } }

#[test]
// Test the methods of the `Hero` struct.
fun test_hero_serialize() {
    // let mut hero = new();
    // let serialized = hero.to_bytes();
    // assert!(serialized.length() == 3, 1);
}
// ANCHOR_END: hero_to_bytes
