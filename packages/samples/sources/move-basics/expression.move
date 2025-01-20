// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::expression;

#[test]
fun expression_examples() {

// ANCHOR: empty
// variable `a` has no value;
let a;
// ANCHOR_END: empty

// ANCHOR: literals
let b = true;     // true is a literal
let n = 1000;     // 1000 is a literal
let h = 0x0A;     // 0x0A is a literal
let v = b"hello"; // b"hello" is a byte vector literal
let x = x"0A";    // x"0A" is a byte vector literal
let c = vector[1, 2, 3]; // vector[] is a vector literal
// ANCHOR_END: literals

// ANCHOR: operators
let sum = 1 + 2;   // 1 + 2 is an expression
let sum = (1 + 2); // the same expression with parentheses
let is_true = true && false; // true && false is an expression
let is_true = (true && false); // the same expression with parentheses
// ANCHOR_END: operators

// ANCHOR: block
// block with an empty expression, however, the compiler will
// insert an empty expression automatically: `let none = { () }`
// let none = {};

// block with let statements and an expression.
let sum = {
    let a = 1;
    let b = 2;
    a + b // last expression is the value of the block
};

// block is an expression, so it can be used in an expression and
// doesn't have to be assigned to a variable.
{
    let a = 1;
    let b = 2;
    a + b; // not returned - semicolon.
    // compiler automatically inserts an empty expression `()`
};
// ANCHOR_END: block
}

// ANCHOR: fun_call
fun add(a: u8, b: u8): u8 {
    a + b
}

#[test]
fun some_other() {
    let sum = add(1, 2); // not returned due to the semicolon.
    // compiler automatically inserts an empty expression `()` as return value of the block
}
// ANCHOR_END: fun_call


#[test] fun control_flow() {

let expr = false;
let expr1 = false;
let expr2 = false;
let bool_expr = false;

// ANCHOR: control_flow
// if is an expression, so it returns a value; if there are 2 branches,
// the types of the branches must match.
if (bool_expr) expr1 else expr2;

// while is an expression, but it returns `()`.
while (bool_expr) { expr; };

// loop is an expression, but returns `()` as well.
loop { expr; break };
// ANCHOR_END: control_flow
}
