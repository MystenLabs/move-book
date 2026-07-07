---
description: "Functions in Move: declare, call, and return values from functions with support for multiple return values and type parameters."
---

# Functions

Functions are the building blocks of Move programs. They are called from
[user transactions](./../concepts/what-is-a-transaction) and from other functions and group
executable code into reusable units. Functions can take arguments and return a value. They are
declared with the `fun` keyword at the module level. Just like any other module member, by default
they're private and can only be accessed from within the module; making them visible to other
modules is the topic of the [Visibility Modifiers](./visibility) section, later in this chapter.

```move file=packages/samples/sources/move-basics/function.move anchor=math

```

In this example, we define a function `add` that takes two arguments of type `u64` and returns their
sum. The `test_add` function, located in the same module, is a test function that calls `add`. The
test uses the `assert_eq!` macro to compare the result of `add` with the expected value. If the
two values differ, the execution is aborted automatically.

## Function Declaration

> In Move, functions are typically named using the `snake_case` convention. This means function
> names should be all lowercase, with words separated by underscores. Examples include
> `do_something`, `add`, `get_balance`, `is_authorized`, and so on.

A function is declared with the `fun` keyword followed by the function name (a valid Move
identifier), a list of arguments in parentheses, and a return type. The function body is a
[block](./expression#blocks), and, like in any block, the last expression without a semicolon is
the function's return value. The `return` keyword allows returning early - it is covered with the
other [control flow](./control-flow) expressions.

```move file=packages/samples/sources/move-basics/function.move anchor=return_nothing

```

## Accessing Functions

Just like other module members, functions can be imported and accessed using a path. The path
consists of the module path and the function name, separated by ::. For example, if you have a
function named `add` in the `math` module within the `book` package, its full path would be
`book::math::add`. If the module has already been imported - imports are covered in the
[Importing Modules](./importing-modules) section - you can access it directly as `math::add`, as
in the following example:

```move file=packages/samples/sources/move-basics/function_use.move anchor=use_math

```

## Multiple Return Values

Move functions can return multiple values, which is particularly useful when you need to return more
than one piece of data from a function. The return type is specified as a tuple of types, and the
return value is provided as a tuple of expressions:

```move file=packages/samples/sources/move-basics/function.move anchor=tuple_return

```

The result of a function call with a tuple return has to be unpacked into variables via the
`let (tuple)` syntax:

```move file=packages/samples/sources/move-basics/function.move anchor=tuple_return_imm

```

If any of the declared values need to be declared as mutable, the `mut` keyword is placed before the
variable name:

```move file=packages/samples/sources/move-basics/function.move anchor=tuple_return_mut

```

If some of the returned values are not needed, they can be ignored with the `_` symbol:

```move file=packages/samples/sources/move-basics/function.move anchor=tuple_return_ignore

```

## Further Reading

- [Functions](./../../reference/functions) in the Move Reference.
