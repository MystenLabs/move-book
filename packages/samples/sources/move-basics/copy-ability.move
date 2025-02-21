// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::copy_ability;

// ANCHOR: copyable
public struct Copyable has copy {}
// ANCHOR_END: copyable

#[test] fun test_copy() {

// ANCHOR: copyable_test
let a = Copyable {}; // allowed because the Copyable struct has the `copy` ability
let b = a;   // `a` is copied to `b`
let c = *&b; // explicit copy via dereference operator

// Copyable doesn't have the `drop` ability, so every instance (a, b, and c) must
// be used or explicitly destructured. The `drop` ability is explained below.
let Copyable {} = a;
let Copyable {} = b;
let Copyable {} = c;
// ANCHOR_END: copyable_test
}

// ANCHOR: copy_drop
public struct Value has copy, drop {}
// ANCHOR_END: copy_drop
