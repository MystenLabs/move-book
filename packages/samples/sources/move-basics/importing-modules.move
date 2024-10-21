// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: module_one
module book::module_one;

/// Struct defined in the same module.
public struct Character has drop {}

/// Simple function that creates a new `Character` instance.
public fun new(): Character { Character {} }
// ANCHOR_END: module_one
