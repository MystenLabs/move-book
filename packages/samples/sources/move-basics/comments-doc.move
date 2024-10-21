// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_function, unused_const, unused_variable, unused_field)]
// ANCHOR: main
/// Module has documentation!
module book::comments_doc;

/// This is a 0x0 address constant!
const AN_ADDRESS: address = @0x0;

/// This is a struct!
public struct AStruct {
    /// This is a field of a struct!
    a_field: u8,
}

/// This function does something!
/// And it's documented!
fun do_something() {}
// ANCHOR_END: main
