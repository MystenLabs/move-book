// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::drop_ability;

/// This struct has the `drop` ability.
public struct IgnoreMe has drop {
    a: u8,
    b: u8,
}

/// This struct does not have the `drop` ability.
public struct NoDrop {}

#[test]
// Create an instance of the `IgnoreMe` struct and ignore it.
// Even though we constructed the instance, we don't need to unpack it.
fun test_ignore() {
    let no_drop = NoDrop {};
    let _ = IgnoreMe { a: 1, b: 2 }; // no need to unpack

    // The value must be unpacked for the code to compile.
    let NoDrop {} = no_drop; // OK
}
// ANCHOR_END: main
