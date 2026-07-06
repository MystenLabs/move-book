---
description: "Macro functions in Move: compile-time expanded functions with lambda arguments - how to use standard library macros and define your own."
---

# Macro Functions

Throughout this chapter, we have called quite a few functions whose names end with an exclamation
mark: the `assert!` and `assert_eq!` macros in tests, and the
[vector macros](./vector#vector-macros) such as `map!` and `fold!`. All of them are _macro
functions_, and now that we know [functions](./function) and [generics](./generics), we have
everything needed to understand how they work - and how to define our own.

## What is a Macro Function?

A macro function looks and feels like a regular function, but it does not exist at runtime.
Instead, the compiler _expands_ the macro: at every call site, the body of the macro is substituted
inline, with the arguments plugged into it, and only then is the resulting code type checked and
compiled. A macro call is easy to recognize - the macro name is always followed by the `!` mark.

This compile-time expansion gives macros two abilities that regular functions do not have:

- They can take _lambdas_ - inline blocks of code - as arguments. Move has no function values at
  runtime, but because a macro is expanded during compilation, the lambda simply becomes part of
  the generated code.
- Their bodies are type checked _after_ expansion, per call site, which permits operations that
  regular [generics](./generics) cannot express - as we are about to see.

## Defining a Macro

A macro is defined with the `macro fun` keywords. The parameters - including type parameters - are
prefixed with the `$` sign, marking them as compile-time substitutions rather than runtime values:

```move file=packages/samples/sources/move-basics/macros.move anchor=max

```

The `max` macro returns the larger of its two arguments. Note something remarkable about the body:
it compares two values of the generic type `$T` with the `>` operator. A regular generic function
could not do this - there is no ability constraint for "comparable", so `fun max<T>(a: T, b: T)`
would not compile. The macro sidesteps the problem entirely: by the time the body is type checked,
`$T` is already replaced with a concrete type at each call site:

```move file=packages/samples/sources/move-basics/macros.move anchor=max_use

```

> Also note the `let a = $a;` binding at the top of the body. A macro argument is substituted as an
> _expression_, not as a computed value: every occurrence of `$a` in the body would evaluate the
> argument expression again. Binding the argument to a local variable once is a good habit that
> avoids surprising double evaluation.

## Lambda Arguments

The real power of macros comes from lambda parameters. A lambda type is written as
`|argument_types|` (or `|argument_types| -> return_type` when it returns a value), and the caller
passes the lambda inline, using the `|arguments| expression` syntax:

```move file=packages/samples/sources/move-basics/macros.move anchor=repeat

```

```move file=packages/samples/sources/move-basics/macros.move anchor=repeat_use

```

A lambda can read and even modify the variables of the enclosing scope - the `repeat!` call above
updates the local variable `sum` on every iteration. This is exactly the mechanism behind the
[vector macros](./vector#vector-macros): `v.do!(|el| ...)` is a macro with a lambda parameter,
expanded into a plain loop at compilation time.

## Lazy Evaluation

Because arguments are substituted rather than computed up front, an argument expression may be
evaluated once, many times - or not at all. The `assert!` macro is a good illustration: in
`assert!(condition, EMyError)`, the error code expression is only evaluated when the condition
fails. This is a feature - the failure branch costs nothing on the happy path - but it is also the
flip side of the double-evaluation caveat above: when writing your own macros, think about how many
times each `$` parameter is actually used.

> Expansion at the call site has one more visible effect: an abort raised inside a macro body
> reports the line number of the macro _call_, not a line inside the macro definition. This is part
> of the [clever error](./assert-and-abort#error-messages) encoding, and it is why a failing
> `assert!` or `assert_eq!` points at the line in your code rather than somewhere in the standard
> library - a good reason to prefer a macro over a regular function when writing assertion helpers.

## Macros in the Standard Library

The [Standard Library](./standard-library) makes heavy use of macros, and they are the idiomatic
way to work with its core types. We have already seen the [vector macros](./vector#vector-macros);
`Option` and the integer types have their own sets:

```move file=packages/samples/sources/move-basics/macros.move anchor=std_macros

```

A quick overview of where to find them:

- [std::vector](https://docs.sui.io/references/framework/std/vector) - `do!`, `map!`, `filter!`,
  `fold!`, `count!`, `any!`, `all!`, `tabulate!`, and more;
- [std::option](https://docs.sui.io/references/framework/std/option) - `do!`, `map!`,
  `destroy_or!`, `extract_or!`, `is_some_and!`;
- integer modules, e.g. [std::u64](https://docs.sui.io/references/framework/std/u64) - `do!`,
  `range_do!`, `max_value!`;
- [std::unit_test](https://docs.sui.io/references/framework/std/unit_test) - `assert_eq!` and
  `assert_ref_eq!`, available in tests.

This section covers the day-to-day use of macros; the full feature set - including method syntax
for macros, `$` expressions in type positions, and hygiene rules - is described in the Move
Reference.

## Further Reading

- [Macro Functions](./../../reference/functions/macros) in the Move Reference.
