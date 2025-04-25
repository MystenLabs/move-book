// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// note, that the module has changed!
module book::segment_tests;

use book::segment;
use std::unit_test::assert_eq;

#[test]
fun test_full_enum_cycle() {
    // create a vector of different Segment variants
    let segments = vector[
        segment::new_empty(),
        segment::new_string(b"hello".to_string()),
        segment::new_special(b" ".to_string(), 0), // plaintext
        segment::new_string(b"move".to_string()),
        segment::new_special(b"21".to_string(), 1), // hex
    ];

    // aggregate all segments into the final string using `vector::fold!` macro
    let result = segments.fold!(b"".to_string(), |mut acc, segment| {
        // do not append empty, only `Special` and `String`
        if (!segment.is_empty()) {
            acc.append(segment.to_string());
        };
        acc
    });

    // check that the result
    assert_eq!(result, b"hello move!".to_string());
}
