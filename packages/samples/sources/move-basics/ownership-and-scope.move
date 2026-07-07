// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::ownership;

// ANCHOR: coin
/// A struct representing a digital asset. Note that `Coin` has no
/// abilities: its value cannot be copied and cannot be discarded.
public struct Coin { value: u64 }

/// Creates a new `Coin`. The new value is returned, and its ownership
/// is transferred to the caller of the function.
public fun mint(value: u64): Coin {
    Coin { value }
}

/// Takes ownership of a `Coin` and destroys it by unpacking.
public fun spend(coin: Coin) {
    let Coin { value: _ } = coin; // the coin is destroyed here
}
// ANCHOR_END: coin

// ANCHOR: scope
public fun scope() {
    // `a` is not yet declared and cannot be used here
    let a = 1u8; // `a` comes into scope and is owned by `scope`
    // `a` can be used here
} // scope ends; `a` goes out of scope
// ANCHOR_END: scope

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_move_semantics() {
    // ANCHOR: move_to_function
    let coin = mint(100); // the test function owns the coin
    spend(coin); // ownership of the value moves into `spend`
    // `coin` can no longer be used here
    // ANCHOR_END: move_to_function

    // ANCHOR: move_to_variable
    let coin = mint(100);
    let new_owner = coin; // the value moves from `coin` to `new_owner`
    // `coin` can no longer be used here
    spend(new_owner);
    // ANCHOR_END: move_to_variable
}

#[test]
fun test_copy_semantics() {
    // ANCHOR: copy_types
    let x = 10u64;
    let y = x; // `x` is copied into `y`, not moved

    // both `x` and `y` can be used after the assignment
    assert_eq!(x, y);
    // ANCHOR_END: copy_types

    // ANCHOR: explicit_move
    let x = 10u64;
    let y = move x; // explicitly move `x` instead of copying it
    // `x` can no longer be used here
    // ANCHOR_END: explicit_move
}

#[test]
fun test_scopes_with_blocks() {
    // ANCHOR: blocks
    let x = 1u8;
    {
        let y = 2u8; // `y` is owned by the block
        let z = x + y; // variables from the outer scope are accessible
    }; // block ends; `y` and `z` go out of scope
    // only `x` can be used here
    // ANCHOR_END: blocks

    // ANCHOR: block_return
    let x = {
        let y = 2u8;
        y + 1 // the result of the block moves to `x`
    }; // `y` goes out of scope
    assert_eq!(x, 3);
    // ANCHOR_END: block_return
}
