// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: hero
module book::hero;

/// A struct representing a hero.
public struct Hero has drop {
    health: u8,
    mana: u8,
}

/// Create a new Hero.
public fun new(): Hero { Hero { health: 100, mana: 100 } }

/// A method which casts a spell, consuming mana.
public fun heal_spell(hero: &mut Hero) {
    hero.health = hero.health + 10;
    hero.mana = hero.mana - 10;
}

/// A method which returns the health of the hero.
public fun health(hero: &Hero): u8 { hero.health }

/// A method which returns the mana of the hero.
public fun mana(hero: &Hero): u8 { hero.mana }

#[test]
// Test the methods of the `Hero` struct.
fun test_methods() {
    let mut hero = new();
    hero.heal_spell();

    assert!(hero.health() == 110);
    assert!(hero.mana() == 90);
}
// ANCHOR_END: hero
