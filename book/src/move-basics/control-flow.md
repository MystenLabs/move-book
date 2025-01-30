# Control Flow

<!--

Chapter: Basic Syntax
Goal: Introduce control flow statements.
Notes:
    - if/else is an expression
    - while () {} loop
    - continue and break
    - loop {}
    - infinite loop is possible but will lead to gas exhaustion
    - return keyword
    - if is an expression and as such requires a semicolon (!!!)

Links:
    - reference (control flow)
    - coding conventions (control flow)

 -->

Control flow statements are used to control the flow of execution in a program. They are used to
make decisions, repeat a block of code, or exit a block of code early. Move includes the following
control flow statements (explained in detail below):

- [`if` and `if-else`](#conditional-statements) - making decisions on whether to execute a block of
  code
- [`loop` and `while` loops](#repeating-statements-with-loops) - repeating a block of code
- [`break` and `continue` statements](#exiting-a-loop-early) - exiting a loop early
- [`return`](#early-return) statement - exiting a function early

## Conditional Statements

The `if` expression is used to make decisions in a program. It evaluates a
[boolean expression](./expression.md#literals) and executes a block of code if the expression is
true. Paired with `else`, it can execute a different block of code if the expression is false.

The syntax for an `if` expression is:

```move
if (<bool_expression>) <expression>;
if (<bool_expression>) <expression> else <expression>;
```

Just like any other expression, `if` requires a semicolon if there are other expressions following
it. The `else` keyword is optional, except when the resulting value is assigned to a variable, as all 
branches must return a value to ensure type safety. Let’s examine how an `if` expression works in Move
with the following example:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:if_condition}}
```

Let's see how we can use `if` and `else` to assign a value to a variable:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:if_else}}
```

In this example, the value of the `if` expression is assigned to the variable `y`. If `x` is greater than 0, `y` is assigned the value 1; otherwise, it is assigned 0. The `else` block is required because both branches of the `if` expression must return a value of the same type. Omitting the `else` block would result in a compiler error, as it ensures all possible branches are accounted for and type safety is maintained.

<!-- TODO: add an error -->

Conditional expressions are among the most important control flow statements in Move. They evaluate user-provided input or stored data to make decisions. One key use case is in the [`assert!` macro](./assert-and-abort.md), which checks if a condition is true and aborts execution if it is not. We’ll explore this in detail shortly.

## Repeating Statements with Loops

Loops are used to execute a block of code multiple times. Move has two built-in types of loops:
`loop` and `while`. In many cases they can be used interchangeably, but usually `while` is used when
the number of iterations is known in advance, and `loop` is used when the number of iterations is
not known in advance or there are multiple exit points.

Loops are useful for working with collections, such as vectors, or for repeating a block of code until a specific condition is met. However, take care to avoid infinite loops, which can exhaust gas limits and cause the transaction to abort.

## The `while` loop

The `while` statement executes a block of code repeatedly as long as a boolean expression evaluates to true.
Just like we've seen with `if`, the boolean expression is evaluated before each iteration of the
loop. Additionally, like conditional statements, the `while` loop is an expression and requires a semicolon
if there are other expressions following it.

The syntax for the `while` loop is:

```move
while (<bool_expression>) { <expressions>; };
```

Here is an example of a `while` loop with a very simple condition:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:while_loop}}
```

## Infinite `loop`

Now let's imagine a scenario where the boolean expression is always `true`. For example, if we
literally passed `true` to the `while` condition. This is similar to how the `loop` statement functions, 
except that `while` evaluates a condition.

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:infinite_while}}
```

An infinite `while` loop, or a `while` loop with an always `true` condition, is equivalent to a `loop`. The syntax for creating a `loop` is straightforward:

```move
loop { <expressions>; };
```

Let's rewrite the previous example using `loop` instead of `while`:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:infinite_loop}}
```

<!-- TODO: that's a weak point lmao -->

Infinite loops are rarely practical in Move, as every operation consumes gas, and an infinite loop will inevitably lead to gas exhaustion. If you find yourself using a loop, consider whether there might be a better approach, as many use cases can be handled more efficiently with other control flow structures. That said, `loop` might be useful when combined with `break` and `continue` statements to create controlled and flexible looping behavior.

## Exiting a Loop Early

As we already mentioned, infinite loops are rather useless on their own. And that's where we
introduce the `break` and `continue` statements. They are used to exit a loop early, and to skip the
rest of the current iteration, respectively.

Syntax for the `break` statement is (without a semicolon):

```move
break
```

The `break` statement is used to stop the execution of a loop and exit it early. It is often used in
combination with a conditional statement to exit the loop when a certain condition is met. To
illustrate this point, let's turn the infinite `loop` from the previous example into something that
looks and behaves more like a `while` loop:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:break_loop}}
```

Almost identical to the `while` loop, right? The `break` statement is used to exit the loop when `x`
is 5. If we remove the `break` statement, the loop will run forever, just like in the previous example.

## Skipping an Iteration

The `continue` statement is used to skip the rest of the current iteration and start the next one.
Similarly to `break`, it is used in combination with a conditional statement to skip the rest of an
iteration when a certain condition is met.

Syntax for the `continue` statement is (without a semicolon):

```move
continue
```

The example below skips odd numbers and prints only even numbers from 0 to 10:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:continue_loop}}
```

`break` and `continue` statements can be used in both `while` and `loop` loops.

## Early Return

The `return` statement is used to exit a [function](./function.md) early and return a value. It is
often used in combination with a conditional statement to exit the function when a certain condition
is met. The syntax for the `return` statement is:

```move
return <expression>
```

Here is an example of a function that returns a value when a certain condition is met:

```move
{{#include ../../../packages/samples/sources/move-basics/control-flow.move:return_statement}}
```

Unlike in many other languages, the `return` statement is not required for the last expression in a
function. The last expression in a function block is automatically returned. However, the `return`
statement is useful when we want to exit a function early if a certain condition is met.
