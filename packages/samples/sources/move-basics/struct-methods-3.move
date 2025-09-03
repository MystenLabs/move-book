// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: hero_to_bytes
module book::hero_to_bytes;

use sui::bcs;

// Alias for the `bcs::to_bytes` method. This allows us to use the method
// on the Hero struct as if it were a native method.
public use fun bcs::to_bytes as Hero.to_bytes;

/// A struct representing a hero.
public struct Hero has drop {
    health: u8,
    mana: u8,
}

/// Create a new Hero.
public fun new(): Hero { Hero { health: 100, mana: 100 } }

#[test]
// Test the `to_bytes` method on the Hero struct.
fun test_hero_serialize() {
    let hero = new();
    // Call the `to_bytes` method as if it's a method of Hero
    let serialized = hero.to_bytes();
    
    // Verify the serialization worked
    assert!(serialized.length() > 0, 1);
}
// ANCHOR_END: hero_to_bytes
