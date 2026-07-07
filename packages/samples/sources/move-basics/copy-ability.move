// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::copy_ability;

// ANCHOR: copyable
public struct Copyable has copy {}
// ANCHOR_END: copyable

#[test] fun test_copy() {

// ANCHOR: copyable_test
let a = Copyable {};

// `a` is copied into `b` implicitly - both are usable afterwards.
let b = a;

// The `copy` keyword makes the copy explicit.
let c = copy a;

// `Copyable` does not have the `drop` ability, so every instance -
// `a`, `b`, and `c` - has to be used. Here, we unpack all of them.
let Copyable {} = a;
let Copyable {} = b;
let Copyable {} = c;
// ANCHOR_END: copyable_test
}

// ANCHOR: copy_drop
public struct Value has copy, drop {}
// ANCHOR_END: copy_drop
