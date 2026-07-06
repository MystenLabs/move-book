---
description: "Expressions in Move: literals, function calls, blocks, and how almost everything returns a value in the Move language."
---

# Expression

In programming languages, an expression is a unit of code that returns a value. In Move, almost
everything is an expression, with the sole exception of the `let` statement, which is a declaration.
In this section, we cover the types of expressions and introduce the concept of scope.

> Expressions are sequenced with semicolons `;`. If there's "no expression" after the semicolon, the
> compiler will insert a _unit_ `()` - a value that represents an empty expression.

## Literals

In the [Primitive Types](./primitive-types) section, we introduced the basic types of Move. And to
illustrate them, we used literals. A literal is a notation for representing a fixed value in source
code. Literals can be used to initialize variables or directly pass fixed values as arguments to
functions. Move has the following literals:

- Boolean values: `true` and `false`
- Integer values: `0`, `1`, `123123`
- Hexadecimal values: Numbers prefixed with 0x to represent integers, such as `0x0`, `0x1`, `0x123`
- Byte vector values: Prefixed with `b`, such as `b"bytes_vector"`
- Byte values: Hexadecimal literals prefixed with `x`, such as `x"0A"`
- String values: Double-quoted text, such as `"hello"`. Unlike other literals, the type of a string
  literal is inferred from the context - it can be a `vector<u8>` or one of the two standard string
  types. Strings are covered in detail in the [String](./string) section.

```move file=packages/samples/sources/move-basics/expression.move anchor=literals

```

## Operators

Arithmetic, logical, and bitwise operators are used to perform operations on values. Since these
operations produce values, they are considered expressions. The integer operators - and when they
abort - are listed in the [Primitive Types](./primitive-types#operations) section.

```move file=packages/samples/sources/move-basics/expression.move anchor=operators

```

## Blocks

A block is a sequence of statements and expressions enclosed in curly braces `{}`. It returns the
value of the last expression in the block (note that this final expression must not have an ending
semicolon). A block is an expression, so it can be used anywhere an expression is expected.

```move file=packages/samples/sources/move-basics/expression.move anchor=block

```

A block also delimits _scope_: a variable declared inside a block exists only until the block's
closing brace. What exactly happens to values when their scope ends is an important question in
Move, and the [Ownership and Scope](./ownership-and-scope) section is devoted to it.

## Function Calls

We go into detail about functions in the very next section - [Functions](./function). Here, it is
enough to say that a function call is an expression: it calls a function and returns the value of
the last expression in the function body, provided the last expression does not have a terminating
semicolon.

```move file=packages/samples/sources/move-basics/expression.move anchor=fun_call

```

## Control Flow Expressions

Control flow expressions are used to control the flow of the program. They are also expressions, so
they return a value. We cover control flow expressions in the [Control Flow](./control-flow)
section. Here's a very brief overview:

```move file=packages/samples/sources/move-basics/expression.move anchor=control_flow

```

## Further Reading

- [Equality](./../../reference/equality) in the Move Reference.
- [Control Flow](./../../reference/control-flow) in the Move Reference.
