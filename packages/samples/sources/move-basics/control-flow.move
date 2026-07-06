// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_function, untyped_literal)]
// ANCHOR: module
module book::control_flow;
// ANCHOR_END: module

#[test_only]
use std::unit_test::assert_eq;

// ANCHOR: if_condition
#[test]
fun test_if() {
    let x = 5;

    // `x > 0` is a boolean expression.
    if (x > 0) {
        let message: std::string::String = "X is bigger than 0";
        std::debug::print(&message)
    };
}
// ANCHOR_END: if_condition
// ANCHOR: if_else
#[test]
fun test_if_else() {
    let x = 5;
    let y = if (x > 0) {
        1
    } else {
        0
    };

    assert_eq!(y, 1);
}
// ANCHOR_END: if_else
// ANCHOR: else_if
// Returns a letter grade for a score from 0 to 100.
fun grade(score: u8): vector<u8> {
    if (score >= 90) "A"
    else if (score >= 80) "B"
    else if (score >= 70) "C"
    else "F"
}

#[test]
fun test_else_if() {
    assert_eq!(grade(95), "A");
    assert_eq!(grade(82), "B");
    assert_eq!(grade(40), "F");
}
// ANCHOR_END: else_if
// ANCHOR: while_loop
// This function iterates over the `x` variable until it reaches 10, the
// return value is the number of iterations it took to reach 10.
//
// If `x` is 0, then the function will return 10.
// If `x` is 5, then the function will return 5.
fun while_loop(mut x: u8): u8 {
    let mut y = 0;

    // This will loop until `x` is 10.
    // And will never run if `x` is 10 or more.
    while (x < 10) {
        y = y + 1;
        x = x + 1;
    };

    y
}

#[test]
fun test_while() {
    assert_eq!(while_loop(0), 10); // 10 times
    assert_eq!(while_loop(5), 5); // 5 times
    assert_eq!(while_loop(10), 0); // loop never executed
}
// ANCHOR_END: while_loop
// ANCHOR: infinite_while
#[test, expected_failure(out_of_gas, location=Self)]
fun test_infinite_while() {
    let mut x = 0;

    // This will loop forever.
    while (true) {
        x = x + 1;
    };

    // This line will never be executed.
    assert_eq!(x, 5);
}
// ANCHOR_END: infinite_while
#[allow(dead_code)]
// ANCHOR: infinite_loop
#[test, expected_failure(out_of_gas, location=Self)]
fun test_infinite_loop() {
    let mut x = 0;

    // This will loop forever.
    loop {
        x = x + 1;
    };

    // This line will never be executed.
    assert_eq!(x, 5);
}
// ANCHOR_END: infinite_loop
// ANCHOR: break_loop
#[test]
fun test_break_loop() {
    let mut x = 0;

    // This will loop until `x` is 5.
    loop {
        x = x + 1;

        // If `x` is 5, then exit the loop.
        if (x == 5) {
            break // Exit the loop.
        }
    };

    assert_eq!(x, 5);
}
// ANCHOR_END: break_loop
// ANCHOR: continue_loop
#[test]
fun test_continue_loop() {
    let mut x = 0u64;

    // This will loop until `x` is 10.
    loop {
        x = x + 1;

        // If `x` is odd, then skip the rest of the iteration.
        if (x % 2 == 1) {
            continue // Skip the rest of the iteration.
        };

        std::debug::print(&x);

        // If `x` is 10, then exit the loop.
        if (x == 10) {
            break // Exit the loop.
        }
    };

    assert_eq!(x, 10) // 10
}
// ANCHOR_END: continue_loop
// ANCHOR: labeled_loop
// Searches a grid (a vector of rows) for `target`, returning `true` as
// soon as it is found. The `'search` label lets the inner loop break out
// of *both* loops at once.
fun grid_contains(grid: &vector<vector<u8>>, target: u8): bool {
    let mut row = 0;

    'search: loop {
        // Ran out of rows without finding the target.
        if (row >= grid.length()) break false;

        let inner = &grid[row];
        let mut col = 0;

        while (col < inner.length()) {
            if (inner[col] == target) {
                // Found it - break the outer `'search` loop directly,
                // skipping any remaining columns and rows.
                break 'search true
            };
            col = col + 1;
        };

        row = row + 1;
    }
}

#[test]
fun test_grid_contains() {
    let grid = vector[
        vector[1, 2, 3],
        vector[4, 5, 6],
        vector[7, 8, 9],
    ];

    assert_eq!(grid_contains(&grid, 5), true);
    assert_eq!(grid_contains(&grid, 10), false);
}
// ANCHOR_END: labeled_loop
// ANCHOR: labeled_block
// Classifies a number, exiting the `'result` block early with `return`
// as soon as the answer is known.
fun classify(x: u64): vector<u8> {
    'result: {
        if (x == 0) return 'result "zero";
        if (x % 2 == 0) return 'result "even";
        "odd"
    }
}

#[test]
fun test_labeled_block() {
    assert_eq!(classify(0), "zero");
    assert_eq!(classify(4), "even");
    assert_eq!(classify(7), "odd");
}
// ANCHOR_END: labeled_block
// ANCHOR: return_statement
/// This function returns `true` if `x` is greater than 0 and not 5,
/// otherwise it returns `false`.
fun is_positive(x: u8): bool {
    if (x == 5) {
        return false
    };

    if (x > 0) {
        return true
    };

    false
}

#[test]
fun test_return() {
    assert_eq!(is_positive(5), false);
    assert_eq!(is_positive(0), false);
    assert_eq!(is_positive(1), true);
}
// ANCHOR_END: return_statement
