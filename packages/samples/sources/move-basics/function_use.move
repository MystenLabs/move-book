// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_function)]
// ANCHOR: use_math
module book::use_math;

use book::math;

fun call_add() {
    // function is called via the path
    let sum = math::add(1, 2);
}
// ANCHOR_END: use_math
