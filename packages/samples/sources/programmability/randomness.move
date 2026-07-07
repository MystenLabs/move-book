// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::randomness;

use sui::random::{Random, RandomGenerator};

// ANCHOR: main
const GOLD: u8 = 0;
const SILVER: u8 = 1;
const BRONZE: u8 = 2;

/// A medal of a random quality, awarded to the caller.
public struct Medal has key {
    id: UID,
    quality: u8,
}

/// The entry function - a thin "facade" which takes the `Random` object,
/// creates a generator, and forwards it to the implementation.
entry fun mint_medal(random: &Random, ctx: &mut TxContext) {
    let mut generator = random.new_generator(ctx);
    let medal = mint_medal_impl(&mut generator, ctx);
    transfer::transfer(medal, ctx.sender());
}

/// The actual implementation: 10% for Gold, 30% for Silver, 60% for Bronze.
/// Thanks to `public(package)` visibility and the `RandomGenerator`
/// parameter, this function can be called directly in tests.
public(package) fun mint_medal_impl(generator: &mut RandomGenerator, ctx: &mut TxContext): Medal {
    let value = generator.generate_u8_in_range(1, 100);
    let quality = if (value <= 10) GOLD else if (value <= 40) SILVER else BRONZE;

    Medal { id: object::new(ctx), quality }
}
// ANCHOR_END: main

#[test_only]
use std::unit_test::{assert_eq, destroy};
#[test_only]
use sui::random;
#[test_only]
use sui::test_scenario;

// ANCHOR: generator
#[test]
fun test_generator_methods() {
    let mut generator = random::new_generator_for_testing();

    // Booleans, integers of any size, and integers in a range.
    let coin_flip: bool = generator.generate_bool();
    let any_u64: u64 = generator.generate_u64();
    let dice: u8 = generator.generate_u8_in_range(1, 6);

    // Random bytes and shuffling of vectors.
    let bytes = generator.generate_bytes(32);
    let mut cards = vector[1u8, 2, 3, 4, 5];
    generator.shuffle(&mut cards);
}
// ANCHOR_END: generator

// ANCHOR: test_unit
#[test]
fun test_mint_medal() {
    let ctx = &mut tx_context::dummy();

    // Generators created from the same seed return the same sequence of
    // values, making the test fully reproducible...
    let mut gen1 = random::new_generator_from_seed_for_testing("victory");
    let mut gen2 = random::new_generator_from_seed_for_testing("victory");
    assert_eq!(gen1.generate_u64(), gen2.generate_u64());

    // ...and different seeds produce different values. Search for seeds
    // which lead the test into the branch you want to check: `"victory"`
    // rolls a 6 (Gold), and `"trophy"` rolls a 90 (Bronze).
    let mut gold_gen = random::new_generator_from_seed_for_testing("victory");
    let gold_medal = mint_medal_impl(&mut gold_gen, ctx);
    assert_eq!(gold_medal.quality, GOLD);
    destroy(gold_medal);

    let mut bronze_gen = random::new_generator_from_seed_for_testing("trophy");
    let bronze_medal = mint_medal_impl(&mut bronze_gen, ctx);
    assert_eq!(bronze_medal.quality, BRONZE);
    destroy(bronze_medal);

    // A non-seeded generator is useful for property-style tests: whatever
    // the outcome, the quality must be one of the three defined values.
    let mut generator = random::new_generator_for_testing();
    100u8.do!(|_| {
        let medal = mint_medal_impl(&mut generator, ctx);
        assert!(medal.quality <= BRONZE);
        destroy(medal);
    });
}
// ANCHOR_END: test_unit

// ANCHOR: test_scenario
#[test]
fun test_mint_medal_via_entry() {
    let user = @0xA11CE;

    // The `Random` object can only be created and updated by the system,
    // so the scenario has to start as the system address `0x0`.
    let mut scenario = test_scenario::begin(@0x0);
    random::create_for_testing(scenario.ctx());
    scenario.next_tx(@0x0);

    let mut random: Random = scenario.take_shared();
    random.update_randomness_state_for_testing(
        0,
        x"1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F",
        scenario.ctx(),
    );
    test_scenario::return_shared(random);

    // Now the user calls the entry function, as a transaction would.
    scenario.next_tx(user);
    let random: Random = scenario.take_shared();
    mint_medal(&random, scenario.ctx());
    test_scenario::return_shared(random);

    // The `Medal` is now owned by the caller.
    scenario.next_tx(user);
    let medal: Medal = scenario.take_from_sender();
    assert!(medal.quality <= BRONZE);
    scenario.return_to_sender(medal);

    scenario.end();
}
// ANCHOR_END: test_scenario
