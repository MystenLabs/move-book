// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field)]
module book::abilities_introduction;

// ANCHOR: definition
/// This struct has the `copy` and `drop` abilities.
public struct VeryAble has copy, drop {
    /// The fields must support the abilities of the struct:
    /// `u64` has `copy` and `drop` (and more).
    value: u64,
}
// ANCHOR_END: definition

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_very_able() {
    // ANCHOR: use
    let a = VeryAble { value: 10 };

    // `copy`: `a` is copied into `b` - both are usable afterwards.
    let b = a;
    assert_eq!(a.value, b.value);

    // `drop`: neither value has to be stored or unpacked; both are
    // silently discarded at the end of the function.
    // ANCHOR_END: use
}
