// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_function, unused_variable)]
// ANCHOR: main
module book::comments_line;

// let's add a note to everything!
fun some_function_with_numbers() {
    let a = 10;
    // let b = 10 this line is commented and won't be executed
    let b = 5; // here comment is placed after code
    a + b; // result is 15, not 10!
}
// ANCHOR_END: main
