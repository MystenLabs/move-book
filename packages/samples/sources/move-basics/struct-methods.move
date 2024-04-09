
// ANCHOR: hero
module book::hero {
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

        assert!(hero.health() == 110, 1);
        assert!(hero.mana() == 90, 2);
    }
}
// ANCHOR_END: hero


// ANCHOR: hero_and_villain
module book::hero_and_villain {
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
        assert!(hero.health() == 100, 1);

        let villain = new_villain();
        assert!(villain.health() == 100, 3);
    }
}
// ANCHOR_END: hero_and_villain


// ANCHOR: hero_to_bytes
// TODO: better example (external module...)
module book::hero_to_bytes {
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
}
// ANCHOR_END: hero_to_bytes
