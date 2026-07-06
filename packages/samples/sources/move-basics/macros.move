// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::macros;

#[test_only]
use std::unit_test::assert_eq;

// ANCHOR: max
/// Returns the larger of the two values.
public macro fun max<$T>($a: $T, $b: $T): $T {
    let a = $a;
    let b = $b;
    if (a > b) a else b
}
// ANCHOR_END: max

#[test]
fun test_max() {
    // ANCHOR: max_use
    assert_eq!(max!(1, 2), 2);
    assert_eq!(max!(10u8, 5), 10);
    assert_eq!(max!(100u128, 200), 200);
    // ANCHOR_END: max_use
}

// ANCHOR: repeat
/// Calls the `$f` lambda `$n` times, passing in the iteration number.
public macro fun repeat($n: u64, $f: |u64|) {
    let n = $n;
    let mut i = 0;
    while (i < n) {
        $f(i);
        i = i + 1;
    }
}
// ANCHOR_END: repeat

#[test]
fun test_repeat() {
    // ANCHOR: repeat_use
    let mut sum = 0;
    repeat!(4, |i| sum = sum + i);
    assert_eq!(sum, 6); // 0 + 1 + 2 + 3
    // ANCHOR_END: repeat_use
}

#[test]
fun test_std_macros() {
    // ANCHOR: std_macros
    // `Option` macros: `destroy_or!` unwraps the value with a default...
    let opt = option::some(10);
    assert_eq!(opt.destroy_or!(0), 10);

    // ...and `map!` transforms the inner value, if it is present.
    let doubled = option::some(5).map!(|x| x * 2);
    assert_eq!(doubled, option::some(10));

    // Integer macros iterate over numbers without a `while` loop.
    let mut sum = 0u64;
    10u64.do!(|i| sum = sum + i);
    assert_eq!(sum, 45); // 0 + 1 + ... + 9

    // And the `assert_eq!` macro, used all over this book, is
    // defined in the `std::unit_test` module.
    // ANCHOR_END: std_macros
}
