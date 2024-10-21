// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: members
module book::more_imports;

use book::module_one::new;       // imports the `new` function from the `module_one` module
use book::module_one::Character; // importing the `Character` struct from the `module_one` module

/// Calls the `new` function from the `module_one` module.
public fun create_character(): Character {
    new()
}
// ANCHOR_END: members
