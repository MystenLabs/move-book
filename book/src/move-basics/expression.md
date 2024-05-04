# Expression

In programming languages expression is a unit of code which returns a value, in Move, almost
everything is an expression, - with the sole exception of `let` statement which is a declaration. In
this section, we cover the types of expressions and introduce the concept of scope.

> Expressions are sequenced with semicolons `;`. If there's "no expression" after the semicolon, the
> compiler will insert a unit `()` - an empty expression.

## Literals

In the [Primitive Types](./primitive-types.md) section, we introduced the basic types of Move. And
to illustrate them, we used literals. A literal is a notation for representing a fixed value in the
source code. Literals are used to initialize variables and to pass arguments to functions. Move has
the following literals:

- `true` and `false` for boolean values
- `0`, `1`, `123123` or other numeric for integer values
- `0x0`, `0x1`, `0x123` or other hexadecimal for integer values
- `b"bytes_vector"` for byte vector values
- `x"0A"` HEX literal for byte values

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:literals}}
```

## Operators

Arithmetic, logical, and bitwise operators are used to perform operations on values. The result of
an operation is a value, so operators are also expressions.

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:operators}}
```

## Blocks

A block is a sequence of statements and expressions, and it returns the value of the last expression
in the block. A block is written as a pair of curly braces `{}`. A block is an expression, so it can
be used anywhere an expression is expected.

```move
{{#include ../../../packages/samples/sources/move-basics/expression.move:block}}
```

## Function Calls

We go into detail about functions in the [Functions](./functions.md) section. However, we already
used function calls in the previous sections, so it's worth mentioning them here. A function call is
an expression that calls a function and returns the value of the last expression in the function
body.

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
