// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::references;
// ANCHOR: header_new
/// Error code for when the card is empty.
const ENoUses: u64 = 0;

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
    assert!(card.uses == 0, ENoUses);
    let Card { uses: _ } = card;
}
// ANCHOR_END: move

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
