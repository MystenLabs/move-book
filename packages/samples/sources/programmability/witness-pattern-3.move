// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: source
module book::witness_source;

use book::witness::{Self, Instance};

/// A struct used as a witness - canonically, an empty struct with `drop`.
public struct W has drop {}

/// Create a new instance of `Instance<W>`.
public fun new_instance(): Instance<W> {
    witness::new(W {})
}
// ANCHOR_END: source

#[test]
fun test_new_instance() {
    let _instance = new_instance();
}
