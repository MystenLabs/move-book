// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_function)]
// ANCHOR: block
module book::comments_block {
    fun /* you can comment everywhere */ go_wild() {
        /* here
           there
           everywhere */ let a = 10;
        let b = /* even here */ 10; /* and again */
        a + b;
    }
    /* you can use it to remove certain expressions or definitions
    fun empty_commented_out() {

    }
    */
}
// ANCHOR_END: block

#[allow(unused_function, unused_const, unused_variable, unused_field)]
// ANCHOR: doc
/// Module has documentation!
module book::comments_doc {

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
}
// ANCHOR_END: doc

#[allow(unused_function, unused_variable)]
// ANCHOR: line_2
module book::comments_line_2 {
    // let's add a note to everything!
    fun some_function_with_numbers() {
        let a = 10;
        // let b = 10 this line is commented and won't be executed
        let b = 5; // here comment is placed after code
        a + b; // result is 15, not 10!
    }
}
// ANCHOR_END: line_2

#[allow(unused_function)]
// ANCHOR: line
module book::comments_line {
    fun some_function() {
        // this is a comment line
    }
}
// ANCHOR_END: line
