# Functions

Functions are the building blocks of Move programs. They are called from
[user transactions](../concepts/user-interaction.md) and from other functions and group executable
code into reusable units. Functions can take arguments and return a value. They are declared with
the `fun` keyword at the module level. Just like any other module member, by default they're private
and can only be accessed from within the module.

```move
{{#include ../../../packages/samples/sources/move-basics/function.move:math}}
```

In this example, we define a function `add` that takes two arguments of type `u64` and returns their sum.
The `test_add` function, located in the same module, is a test function that calls `add`. The test uses the
`assert!` macro to compare the result of `add` with the expected value. If the condition inside `assert!` evaluates
to false, the execution is aborted automatically.

## Function declaration

> In Move, functions are typically named using the `snake_case` convention. This means function names
> should be all lowercase, with words separated by underscores. Examples include `do_something`, `add`,
> `get_balance`, `is_authorized`, and so on.

A function is declared with the `fun` keyword followed by the function name (a valid Move
identifier), a list of arguments in parentheses, and a return type. The function body is a block of
code that contains a sequence of statements and expressions. The last expression the function
body is the return value of the function.

```move
{{#include ../../../packages/samples/sources/move-basics/function.move:return_nothing}}
```

## Accessing functions

Just like other module members, functions can be imported and accessed using a path. The path consists
of the module path and the function name, separated by ::. For example, if you have a function named
`add` in the `math` module within the `book` package, its full path would be `book::math::add`. If the module
has already been imported, you can access it directly as `math::add` as in the following example:

```move
{{#include ../../../packages/samples/sources/move-basics/function_use.move:use_math}}
```

## Multiple return values

Move functions can return multiple values, which is particularly useful when you need to return more
than one piece of data from a function. The return type is specified as a tuple of types, and the return
value is provided as a tuple of expressions:

```move
{{#include ../../../packages/samples/sources/move-basics/function.move:tuple_return}}
```

The result of a function call with a tuple return has to be unpacked into variables via the `let (tuple)`
syntax:

```move
{{#include ../../../packages/samples/sources/move-basics/function.move:tuple_return_imm}}
```

If any of the declared values need to be declared as mutable, the `mut` keyword is placed before the
variable name:

```move
{{#include ../../../packages/samples/sources/move-basics/function.move:tuple_return_mut}}
```

If some of the arguments are not used, they can be ignored with the `_` symbol:

```move
{{#include ../../../packages/samples/sources/move-basics/function.move:tuple_return_ignore}}
```

## Further reading

- [Functions](/reference/functions.html) in the Move Reference.
