---
description:
  'Control flow in Move: if/else expressions, while and loop constructs, break, continue, and return
  statements.'
---

# Control Flow

Control flow statements decide which code runs, how many times, and when to stop. They are used to
make decisions, repeat a block of code, or exit a block of code early. Move includes the following
control flow statements (explained in detail below):

- [`if` and `if-else`](#conditional-statements) - making decisions on whether to execute a block of
  code
- [`loop` and `while` loops](#repeating-statements-with-loops) - repeating a block of code
- [`break` and `continue` statements](#exiting-a-loop-early) - exiting a loop early
- [labeled control flow](#labeled-control-flow) - targeting an outer loop or block from a nested one
- [`return`](#early-return) statement - exiting a function early

## Conditional Statements

The `if` expression is used to make decisions in a program. It evaluates a
[boolean](./primitive-types#booleans) expression and executes a block of code if the expression is true.
Paired with `else`, it can execute a different block of code if the expression is false.

The syntax for an `if` expression is:

```move
if (<bool_expression>) <expression>;
if (<bool_expression>) <expression> else <expression>;
```

Just like any other expression, `if` requires a semicolon if there are other expressions following
it. The `else` keyword is optional, except when the resulting value is assigned to a variable, as
all branches must return a value to ensure type safety. Let’s examine how an `if` expression works
in Move with the following example:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=if_condition

```

Let's see how we can use `if` and `else` to assign a value to a variable:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=if_else

```

In this example, the value of the `if` expression is assigned to the variable `y`. If `x` is greater
than 0, `y` is assigned the value 1; otherwise, it is assigned 0. The `else` block is required here
because both branches of an `if` expression must have the same type. When the `else` is omitted, the
false branch defaults to the unit value `()`, so assigning an `if` without an `else` to a variable
is a type error:

```move
let y = if (x > 0) 1;
//      ^^^^^^^^^^^^ ERROR! Expected 'u64', but found '()' - the missing
//                   else branch defaults to the unit value `()`.
```

To choose between more than two branches, `if` expressions can be chained with `else if`. The
branches are checked top to bottom, and the first one whose condition is true is taken:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=else_if

```

Conditional expressions are among the most important control flow statements in Move. They evaluate
user-provided input or stored data to make decisions. One key use case is in the
[`assert!` macro](./assert-and-abort), which checks if a condition is true and aborts execution if
it is not. We explore it in detail later in this chapter.

## Repeating Statements with Loops

Loops are used to execute a block of code multiple times. Move has two built-in types of loops:
`loop` and `while`. In many cases they can be used interchangeably, but usually `while` is used when
the number of iterations is known in advance, and `loop` is used when the number of iterations is
not known in advance or there are multiple exit points.

Loops are useful for working with collections, such as vectors, or for repeating a block of code
until a specific condition is met. However, take care to avoid infinite loops, which can exhaust gas
limits and cause the transaction to abort.

> In practice, hand-written loops are relatively rare in Move. Iterating over a collection is more
> commonly expressed with the higher-level [macros](./macros) such as `do!`, `map!`, and `fold!`,
> which are covered in the [Vector](./vector#vector-macros) chapter. The `loop` and `while`
> constructs described here are the primitives those macros are built on, and remain the right tool
> when the iteration does not fit a simple collection traversal.

## The `while` Loop

The `while` statement executes a block of code repeatedly as long as the associated boolean
expression evaluates to true. Just like we've seen with `if`, the boolean expression is evaluated
before each iteration of the loop. Additionally, like conditional statements, the `while` loop is an
expression and requires a semicolon if there are other expressions following it.

The syntax for the `while` loop is:

```move
while (<bool_expression>) { <expressions>; };
```

Here is an example of a `while` loop with a very simple condition:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=while_loop

```

## Infinite `loop`

Now let's imagine a scenario where the boolean expression is always `true`. For example, if we
literally passed `true` to the `while` condition. This is similar to how the `loop` statement
functions, except that `while` evaluates a condition.

```move file=packages/samples/sources/move-basics/control-flow.move anchor=infinite_while

```

An infinite `while` loop, or a `while` loop with an always `true` condition, is equivalent to a
`loop`. The syntax for creating a `loop` is straightforward:

```move
loop { <expressions>; };
```

Let's rewrite the previous example using `loop` instead of `while`:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=infinite_loop

```

Infinite loops are rarely practical in Move, as every operation consumes gas, and an infinite loop
will inevitably lead to gas exhaustion. If you find yourself using a loop, consider whether there
might be a better approach, as many use cases can be handled more efficiently with other control
flow structures. That said, `loop` might be useful when combined with `break` and `continue`
statements to create controlled and flexible looping behavior.

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

```move file=packages/samples/sources/move-basics/control-flow.move anchor=break_loop

```

Almost identical to the `while` loop, right? The `break` statement is used to exit the loop when `x`
is 5. If we remove the `break` statement, the loop will run forever, just like in the previous
example.

## Skipping an Iteration

The `continue` statement is used to skip the rest of the current iteration and start the next one.
Similarly to `break`, it is used in combination with a conditional statement to skip the rest of an
iteration when a certain condition is met.

Syntax for the `continue` statement is (without a semicolon):

```move
continue
```

The example below skips odd numbers and prints only even numbers from 0 to 10:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=continue_loop

```

`break` and `continue` statements can be used in both `while` and `loop` loops.

## Labeled Control Flow

By default, `break` and `continue` act on the innermost loop that encloses them. This is a problem
when loops are nested: from inside an inner loop, there is no way to break out of the outer one. To
solve this, Move lets you attach a _label_ to a loop and then tell `break` or `continue` exactly
which one to target.

A label is a name prefixed with a single quote, placed before the `loop` or `while` keyword. You can
then write `break 'label` or `continue 'label` to jump to the labeled loop instead of the innermost
one:

```move
'outer: loop {
    while (condition) {
        // Exits both loops at once.
        break 'outer;

        // Skips to the next iteration of the outer loop.
        continue 'outer;
    };
};
```

Consider a search over a grid - a vector of rows, where each row is itself a vector. Once we find
the value we are looking for, we want to stop scanning entirely, not just finish the current row.
Labeling the outer loop lets the inner `while` loop abandon the whole search in one step:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=labeled_loop

```

Notice that the `break` statements also carry a value: `break false` and `break 'search true`. A
`loop` is an expression, so breaking out of it can produce a result - here, the boolean returned by
the function. This is specific to `loop`: a `while` loop always evaluates to the unit value `()`, so
its `break` cannot carry a value. Without the label, escaping both loops would require an extra flag
variable and a second check in the outer loop.

### Labeled Blocks

Labels are not limited to loops. A plain block `{ ... }` can also be labeled, and then exited early
with `return 'label <value>`. This is useful for computing a value with several possible early
exits, without extracting the logic into a separate function:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=labeled_block

```

Here the `'result` block produces a value, and any of the `return 'result` statements can end it
early. This becomes especially powerful together with the iteration [macros](./macros) mentioned
above, where a labeled block lets a lambda break out of the iteration with a result.

Two rules are worth remembering:

- A label can only be placed on a `loop`, a `while`, or a block `{}` - **not** on an `if`
  expression. To label a conditional, label the block around it (an `if` branch is itself a block).
- `break` and `continue` work only with _loop_ labels, while `return` works only with _block_
  labels. Mixing them (for example `break` on a block label) is a compilation error.

> The [Labeled Control Flow](./../../reference/control-flow/labeled-control-flow) chapter of the
> Move Reference covers these forms in more detail, including their interaction with macros.

## Early Return

The `return` statement is used to exit a [function](./function) early and return a value. It is
often used in combination with a conditional statement to exit the function when a certain condition
is met. The syntax for the `return` statement is:

```move
return <expression>
```

Here is an example of a function that returns a value when a certain condition is met:

```move file=packages/samples/sources/move-basics/control-flow.move anchor=return_statement

```

Unlike in many other languages, the `return` statement is not required for the last expression in a
function. The last expression in a function block is automatically returned. However, the `return`
statement is useful when we want to exit a function early if a certain condition is met.

## Further Reading

- [Control Flow](./../../reference/control-flow) chapter in the Move Reference.
