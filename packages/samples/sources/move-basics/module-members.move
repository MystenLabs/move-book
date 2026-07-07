// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_function, unused_const, unused_use)]
// ANCHOR: members
module book::my_module_with_members;

// import - brings the `my_module` module into scope
use book::my_module;

// a constant - an immutable, module-private value
const CONST: u8 = 0;

// a struct - a custom data type
public struct Struct {}

// a function - a unit of executable code
fun function() { /* function body */ }
// ANCHOR_END: members
