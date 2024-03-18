# Expression

In programming languages expression is a unit of code which returns a value, in Move, almost everything is an expression, - with the sole exception of `let` statement which is a declaration. In this section, we cover the types of expressions and introduce the concept of scope.

> Expressions are sequenced with semicolons `;`. If there's "no expression" after the semicolon, the compiler will insert an empty expression `()`.

## Empty Expression

The very base of the expression is the empty expression. It is a valid expression that does nothing and returns nothing. An empty expression is written as empty parentheses `()`. It's rarely the case when you need to use an empty expression. The compiler automatically inserts empty expressions where needed, for example in an empty [Scope](#scope). Though, it may be helpful to know that it exists. Parentheses are also used to group expressions to control the order of evaluation.

```move
// variable `a` has no value;
let a = ();

// similarly, we could write:
let a;
```

## Literals

In the [Primitive Types](./primitive-types.md) section, we introduced the basic types of Move. And to illustrate them, we used literals. A literal is a notation for representing a fixed value in the source code. Literals are used to initialize variables and to pass arguments to functions. Move has the following literals:

- `true` and `false` for boolean values
- `0`, `1`, `123123` or other numeric for integer values
- `0x0`, `0x1`, `0x123` or other hexadecimal for integer values
- `b"bytes_vector"` for byte vector values
- `x"0A"` HEX literal for byte values

```move
let b = true;     // true is a literal
let n = 1000;     // 1000 is a literal
let h = 0x0A;     // 0x0A is a literal
let v = b"hello"; // b'hello' is a byte vector literal
let x = x"0A";    // x'0A' is a byte vector literal
let c = vector[1, 2, 3]; // vector[] is a vector literal
```

## Operators

Ariphmetic, logical, and bitwise operators are used to perform operations on values. The result of an operation is a value, so operators are also expressions.

```move
let sum = 1 + 2;   // 1 + 2 is an expression
let sum = (1 + 2); // the same expression with parentheses
let is_true = true && false; // true && false is an expression
let is_true = (true && false); // the same expression with parentheses
```

## Blocks

A block is a sequence of statements and expressions, and it returns the value of the last expression in the block. A block is written as a pair of curly braces `{}`. A block is an expression, so it can be used anywhere an expression is expected.

```move
// block with an empty expression, however, the compiler will
// insert an empty expression automatically: `let none = { () }`
let none = {};

// block with let statements and an expression.
let sum = {
    let a = 1;
    let b = 2;
    a + b // last expression is the value of the block
};

let none = {
    let a = 1;
    let b = 2;
    a + b; // not returned - semicolon.
    // compiler automatically inserts an empty expression `()`
};
```

## Function Calls

We go into detail about functions in the [Functions](./functions.md) section. However, we already used function calls in the previous sections, so it's worth mentioning them here. A function call is an expression that calls a function and returns the value of the last expression in the function body.

```move
fun add(a: u8, b: u8): u8 {
    a + b
}

#[test]
fun some_other() {
    let sum = add(1, 2); // add(1, 2) is an expression with type u8
}
```

## Control Flow Expressions

Control flow expressions are used to control the flow of the program. They are also expressions, so they return a value. We cover control flow expressions in the [Control Flow](./control-flow.md) section. Here's a very brief overview:

```move
// if is an expression, so it returns a value; if there are 2 branches,
// the types of the branches must match.
if (bool_expr) expr1 else expr2;

// while is an expression, but it returns `()`.
while (bool_expr) expr;

// loop is an expression, but returns `()` as well.
loop expr;
```
