# Struct Methods

Move Compiler supports *receiver syntax*, which allows defining methods which can be called on instances of a struct. This is similar to the method syntax in other programming languages. It is a convenient way to define functions which operate on the fields of a struct.

## Method syntax

If the first argument of a function is a struct internal to the module, then the function can be called using the `.` operator. If the function uses a struct from another module, then method won't be associated with the struct by default. In this case, the function can be called using the standard function call syntax.

When a module is imported, the methods are automatically associated with the struct.

```move
module book::hero {
    /// A struct representing a hero.
    struct Hero has drop {
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
```

## Method Aliases

For modules that define multiple structs and their methods, it is possible to define method aliases to avoid name conflicts, or to provide a better-named method for a struct.

The syntax for aliases is:
```move
// for local method association
use fun <function_path> as <Type>.<method_name>;

// exported alias
public use fun <function_path> as <Type>.<method_name>;
```

> Public aliases are only allowed for structs defined in the same module. If a struct is defined in another module, an alias can still be created but cannot be made public.

In the example below, we changed the `hero` module and added another type - `Villain`. Both `Hero` and `Villain` have similar field names and methods. And to avoid name conflicts, we prefixed methods with `hero_` and `villain_` respectively. However, we can create aliases for these methods so that they can be called on the instances of the structs without the prefix.

```move
module book::hero_and_villain {
    /// A struct representing a hero.
    struct Hero has drop {
        health: u8,
    }

    /// A struct representing a villain.
    struct Villain has drop {
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
        let mut hero = new_hero();
        assert!(hero.health() == 100, 1);

        let mut villain = new_villain();
        assert!(villain.health() == 100, 3);
    }
}
```

As you can see, in the test function, we called the `health` method on the instances of `Hero` and `Villain` without the prefix. The compiler will automatically associate the methods with the structs.

## Aliasing an external module's method

It is also possible to associate a function defined in another module with a struct from the current module. Following the same approach, we can create an alias for the method defined in another module. Let's use the `bcs::to_bytes` method from the [Standard Library](./standard-library.md) and associate it with the `Hero` struct. It will allow serializing the `Hero` struct to a vector of bytes.

```move
module book::hero_to_bytes {
    use std::bcs;

    // Alias for the `bcs::to_bytes` method. Imported aliases should be defined
    // in the top of the module.
    public use fun bcs::to_bytes as Hero.to_bytes;

    /// A struct representing a hero.
    struct Hero has drop {
        health: u8,
        mana: u8,
    }

    /// Create a new Hero.
    public fun new(): Hero { Hero { health: 100, mana: 100 } }

    // Alias for the `bcs::to_string` method.
    public use fun bcs::to_bytes as Hero.to_bytes;

    #[test]
    // Test the methods of the `Hero` struct.
    fun test_hero_serialize() {
        let mut hero = new();
        let serialized = hero.to_bytes();
        assert!(serialized.length() == 3, 1);
    }
}
```
