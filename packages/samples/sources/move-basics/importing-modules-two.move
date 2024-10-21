// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: module_two
module book::module_two;

use book::module_one; // importing module_one from the same package

/// Calls the `new` function from the `module_one` module.
public fun create_and_ignore() {
    let _ = module_one::new();
}
// ANCHOR_END: module_two
