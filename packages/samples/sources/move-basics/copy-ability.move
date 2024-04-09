// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::copy_ability {

// ANCHOR: copyable
public struct Copyable has copy {}
// ANCHOR_END: copyable

#[test] fun test_copy() {

// ANCHOR: copyable_test
let a = Copyable {};
let b = a;   // `a` is copied to `b`
let c = *&b; // explicit copy via dereference operator

let Copyable {} = a; // doesn't have `drop`
let Copyable {} = b; // doesn't have `drop`
let Copyable {} = c; // doesn't have `drop`
// ANCHOR_END: copyable_test
}

// ANCHOR: copy_drop
public struct Value has copy, drop {}
// ANCHOR_END: copy_drop
}
