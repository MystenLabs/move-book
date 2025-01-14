# Expression

In programming languages, an expression is a unit of code that returns a value. In Move, almost
everything is an expression, with the sole exception of the `let` statement, which is a declaration. In
this section, we cover the types of expressions and introduce the concept of scope.

> Expressions are sequenced with semicolons `;`. If there's "no expression" after the semicolon, the
> compiler will insert a `unit ()`, which represents an empty expression.

## Literals

In the [Primitive Types](./primitive-types.md) section, we introduced the basic types of Move. And
to illustrate them, we used literals. A literal is a notation for representing a fixed value in 
source code. Literals can be used to initialize variables or directly pass fixed values as arguments to 
functions. Move has the following literals:

- Boolean values: `true` and `false`
- Integer values: `0`, `1`, `123123`
- Hexadecimal values: Numbers prefixed with 0x to represent integers, such as `0x0`, `0x1`, `0x123`
- Byte vector values: Prefixed with `b`, such as `b"bytes_vector"`
- Byte values: Hexadecimal literals prefixed with `x`, such as `x"0A"`

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:literals}}
```

## Operators

Arithmetic, logical, and bitwise operators are used to perform operations on values. Since these 
operations produce values, they are considered expressions.

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:operators}}
```

## Blocks

A block is a sequence of statements and expressions enclosed in curly braces `{}`. It returns the value of 
the last expression in the block (note that this final expression must not have an ending semicolon).
A block is an expression, so it can be used anywhere an expression is expected. 

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:block}}
```

## Function Calls

We go into detail about functions in the [Functions](./functions.md) section. However, we have already
used function calls in previous sections, so it's worth mentioning them here. A function call is
an expression that calls a function and returns the value of the last expression in the function
body, provided the last expression does not have a terminating semi-colon.

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:fun_call}}
```

## Control Flow Expressions

Control flow expressions are used to control the flow of the program. They are also expressions, so
they return a value. We cover control flow expressions in the [Control Flow](./control-flow.md)
section. Here's a very brief overview:

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:control_flow}}
```
