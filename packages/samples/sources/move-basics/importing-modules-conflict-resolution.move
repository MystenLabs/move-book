// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: conflict
module book::conflict_resolution;

// `as` can be placed after any import, including group imports
use book::module_one::{Self as mod, Character as Char};

/// Calls the `new` function from the `module_one` module.
public fun create(): Char {
    mod::new()
}
// ANCHOR_END: conflict
