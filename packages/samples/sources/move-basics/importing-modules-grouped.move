// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: grouped
module book::grouped_imports;

// imports the `new` function and the `Character` struct from
// the `module_one` module
use book::module_one::{new, Character};

/// Calls the `new` function from the `module_one` module.
public fun create_character(): Character {
    new()
}
// ANCHOR_END: grouped
