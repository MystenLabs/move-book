// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::references;
// ANCHOR: header_new
/// Error code for when the card is empty.
const ENoUses: u64 = 0;
/// Error code for when the card is not empty.
const EHasUses: u64 = 1;

/// Number of uses for a metro pass card.
const USES: u8 = 3;

/// A metro pass card
public struct Card { uses: u8 }

/// Purchase a metro pass card.
public fun purchase(/* pass a Coin */): Card {
    Card { uses: USES }
}
// ANCHOR_END: header_new

// ANCHOR: immutable
/// Show the metro pass card to the inspector.
public fun is_valid(card: &Card): bool {
    card.uses > 0
}
// ANCHOR_END: immutable

// ANCHOR: mutable
/// Use the metro pass card at the turnstile to enter the metro.
public fun enter_metro(card: &mut Card) {
    assert!(card.uses > 0, ENoUses);
    card.uses = card.uses - 1;
}
// ANCHOR_END: mutable

// ANCHOR: move
/// Recycle the metro pass card.
public fun recycle(card: Card) {
    assert!(card.uses == 0, EHasUses);
    let Card { uses: _ } = card;
}
// ANCHOR_END: move

// ANCHOR: getter
/// Getter: a reference to the `uses` field, derived from
/// the `card` reference taken as an argument.
public fun uses(card: &Card): &u8 {
    &card.uses
}
// ANCHOR_END: getter

#[test]
fun test_getter() {
    let mut card = purchase();
    assert!(*card.uses() == 3);

    enter_metro(&mut card);
    assert!(*card.uses() == 2);

    // spend the remaining rides and recycle the card
    enter_metro(&mut card);
    enter_metro(&mut card);
    recycle(card);
}

// ANCHOR: test
#[test]
fun test_card() {
    // declaring variable as mutable because we modify it
    let mut card = purchase();

    enter_metro(&mut card);

    assert!(is_valid(&card)); // read the card!

    enter_metro(&mut card); // modify the card but don't move it
    enter_metro(&mut card); // modify the card but don't move it

    recycle(card); // move the card out of the scope
}
// ANCHOR_END: test

// ANCHOR: deref
#[test]
fun test_dereference() {
    let mut card = purchase();

    // A reference to the `uses` field - a `u8` value.
    let uses_ref = &card.uses;

    // The dereference operator `*` copies the value behind the reference.
    let uses: u8 = *uses_ref;
    assert!(uses == 3);

    // Writing through a mutable reference is also a dereference.
    *(&mut card.uses) = 0;
    assert!(card.uses == 0);

    recycle(card);
}
// ANCHOR_END: deref

// ANCHOR: move_2024
#[test]
fun test_card_2024() {
    // declaring variable as mutable because we modify it
    let mut card = purchase();

    card.enter_metro(); // modify the card but don't move it
    assert!(card.is_valid()); // read the card!

    card.enter_metro(); // modify the card but don't move it
    card.enter_metro(); // modify the card but don't move it

    card.recycle(); // move the card out of the scope
}
// ANCHOR_END: move_2024
// ANCHOR_END: main
