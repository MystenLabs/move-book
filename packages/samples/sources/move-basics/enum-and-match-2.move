// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: enum_test
// Note, that the module has changed!
module book::segment_tests;

use book::segment;
use std::string::String;

#[test]
fun test_full_enum_cycle() {
    use std::unit_test::assert_eq;

    // Create a vector of different Segment variants.
    let segments = vector[
        segment::new_empty(),
        segment::new_string("hello"),
        segment::new_special(" ", 0), // utf8
        segment::new_string("move"),
        segment::new_special("!", 1), // ascii
    ];

    // Aggregate all segments into the final string using `vector::fold!` macro.
    let result = segments.fold!("", |mut acc: String, segment| {
        // Do not append empty, only `Special` and `String`.
        if (!segment.is_empty()) {
            acc.append(segment.to_string());
        };
        acc
    });

    // Check that the result is what's expected.
    assert_eq!(result, "hello move!");
}
// ANCHOR_END: enum_test
