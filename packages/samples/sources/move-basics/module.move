// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: address_literal
module 0x0::address_literal { /* ... */ }
module book::named_address { /* ... */ }
// ANCHOR_END: address_literal

#[allow(unused_function, unused_const, unused_use)]
// ANCHOR: members
module book::my_block_module_with_members {
    // import
    use book::my_module;

    // a constant
    const CONST: u8 = 0;

    // a struct
    public struct Struct {}

    // method alias
    public use fun function as Struct.struct_fun;

    // function
    fun function(_: &Struct) { /* function body */ }
}

// module block allows multiple module definitions in the
// same file but this is not a recommended practice
module book::another_module_in_the_file {
    // ...
}
// ANCHOR_END: members
