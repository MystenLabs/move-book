# Aborting Execution

<!-- Consider "aborting execution" -->

<!--

Chapter: Basic Syntax
Goal: Introduce abort keyword and `assert!` macro.
Notes:
    - previous chapter mentions constants
    - error constants standard ECamelCase
    - `assert!` macro
    - asserts should go before the main logic
    - Move has no catch mechanism
    - abort codes are local to the module
    - there are no error messages emitted
    - error codes should handle all possible scenarios in this module

Links:
    - constants (previous section)
 -->

A transaction can either succeed or fail. Successful execution applies all the changes made to
objects and on-chain data, and the transaction is committed to the blockchain. Alternatively, if a
transaction aborts, the changes are not applied. The `abort` keyword is used to abort a transaction
and revert the changes made so far.

> It is important to note that there is no catch mechanism in Move. If a transaction aborts, the
> changes made so far are reverted, and the transaction is considered failed.

## Abort

The `abort` keyword is used to abort the execution of a transaction. It is used in combination with
an abort code, which will be returned to the caller of the transaction. The abort code is an
[integer](./primitive-types.md) of type `u64`.

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:abort}}
```

The code above will, of course, abort with abort code `1`.

## assert!

The `assert!` macro is a built-in macro that can be used to assert a condition. If the condition is
false, the transaction will abort with the given abort code. The `assert!` macro is a convenient way
to abort a transaction if a condition is not met. The macro shortens the code otherwise written with
an `if` expression + `abort`. The `code` argument is required and has to be a `u64` value.

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:assert}}
```

## Error constants

To make error codes more descriptive, it is a good practice to define
[error constants](./constants.md). Error constants are defined as `const` declarations and are
usually prefixed with `E` followed by a camel case name. Error constants are no different from other
constants and don't have special handling, however, they are used to increase the readability of the
code and make it easier to understand the abort scenarios.

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:error_const}}
```

## Further reading

- [Abort and Assert](/reference/abort-and-assert.html) in the Move Reference.
- We suggest reading the [Better Error Handling](./../guides/better-error-handling.md) guide to
  learn about best practices for error handling in Move.
