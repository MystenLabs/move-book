// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: self
module book::self_imports;

// imports the `Character` struct, and the `module_one` module
use book::module_one::{Self, Character};

/// Calls the `new` function from the `module_one` module.
public fun create_character(): Character {
    module_one::new()
}
// ANCHOR_END: self
