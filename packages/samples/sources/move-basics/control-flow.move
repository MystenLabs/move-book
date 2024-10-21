// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: module
module book::control_flow;
// ANCHOR_END: module

// ANCHOR: if_condition
#[test]
fun test_if() {
    let x = 5;

    // `x > 0` is a boolean expression.
    if (x > 0) {
        std::debug::print(&b"X is bigger than 0".to_string())
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

    assert!(y == 1);
}
// ANCHOR_END: if_else
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
    assert!(while_loop(0) == 10); // 10 times
    assert!(while_loop(5) == 5);  // 5 times
    assert!(while_loop(10) == 0); // loop never executed
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
    assert!(x == 5);
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
    assert!(x == 5);
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

    assert!(x == 5);
}
// ANCHOR_END: break_loop
// ANCHOR: continue_loop
#[test]
fun test_continue_loop() {
    let mut x = 0;

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

    assert!(x == 10); // 10
}
// ANCHOR_END: continue_loop
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
    assert!(is_positive(5) == false);
    assert!(is_positive(0) == false);
    assert!(is_positive(1) == true);
}
// ANCHOR_END: return_statement
