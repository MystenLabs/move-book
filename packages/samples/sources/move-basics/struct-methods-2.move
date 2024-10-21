// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: hero_and_villain
module book::hero_and_villain;

/// A struct representing a hero.
public struct Hero has drop {
    health: u8,
}

/// A struct representing a villain.
public struct Villain has drop {
    health: u8,
}

/// Create a new Hero.
public fun new_hero(): Hero { Hero { health: 100 } }

/// Create a new Villain.
public fun new_villain(): Villain { Villain { health: 100 } }

// Alias for the `hero_health` method. Will be imported automatically when
// the module is imported.
public use fun hero_health as Hero.health;

public fun hero_health(hero: &Hero): u8 { hero.health }

// Alias for the `villain_health` method. Will be imported automatically
// when the module is imported.
public use fun villain_health as Villain.health;

public fun villain_health(villain: &Villain): u8 { villain.health }

#[test]
// Test the methods of the `Hero` and `Villain` structs.
fun test_associated_methods() {
    let hero = new_hero();
    assert!(hero.health() == 100);

    let villain = new_villain();
    assert!(villain.health() == 100);
}
// ANCHOR_END: hero_and_villain
