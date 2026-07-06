// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::witness;

/// A struct that can only be created with a witness of `T`.
public struct Instance<phantom T> has drop {}

/// Create a new `Instance<T>` with the provided witness. The witness is
/// discarded after use.
public fun new<T: drop>(_witness: T): Instance<T> {
    Instance {}
}
// ANCHOR_END: main
