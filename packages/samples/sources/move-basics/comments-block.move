// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_function)]
// ANCHOR: main
module book::comments_block;

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
// ANCHOR_END: main
