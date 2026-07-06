// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
/// Defines the type `A`.
module book::exercise_internal;

use sui::event;

/// Type defined in this module, so it's internal here.
public struct A has copy, drop {}

/// Works, because `A` is defined in this module.
public fun call_internal() {
    event::emit(A {})
}
// ANCHOR_END: main

#[test]
fun test_call_internal() {
    call_internal();
}
