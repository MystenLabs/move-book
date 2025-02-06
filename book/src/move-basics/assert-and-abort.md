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

A transaction can either succeed or fail. Successful execution applies all changes made to
objects and on-chain data, and the transaction is committed to the blockchain. Alternatively, if a
transaction aborts, changes are not applied. Use the `abort` keyword to abort a transaction
and revert any changes that were made.

> It is important to note that there is no catch mechanism in Move. If a transaction aborts, the
> changes made so far are reverted, and the transaction is considered failed.

## Abort

The `abort` keyword is used to abort the execution of a transaction. It is used in combination with
an abort code, which is returned to the caller of the transaction. The abort code is an
[integer](./primitive-types.md) of type `u64`.

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:abort}}
```

The code above will, of course, abort with abort code `1`.

## assert!

The `assert!` macro is a built-in macro that can be used to assert a condition. If the condition is
false, the transaction will abort with the given abort code. The `assert!` macro is a convenient way
to abort a transaction if a condition is not met. The macro shortens the code otherwise written with
an `if` expression + `abort`. The `code` argument is optional, but has to be a `u64` value or an
`#[error]` (see below for more information).

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:assert}}
```

## Error constants

To make error codes more descriptive, it is a good practice to define
[error constants](./constants.md). Error constants are defined as `const` declarations and are
usually prefixed with `E` followed by a camel case name. Error constants are similar to other constants
and do not have any special handling. However, they are commonly used to improve code readability and
make abort scenarios easier to understand.

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:error_const}}
```

## Error messages

Move 2024 introduces a special type of error constant, marked with the `#[error]` attribute. This
attribute allows the error constant to be of type `vector<u8>` and can be used to store an error
message.

```move
{{#include ../../../packages/samples/sources/move-basics/assert-and-abort.move:error_attribute}}
```

## Further reading

- [Abort and Assert](/reference/abort-and-assert.html) in the Move Reference.
- We suggest reading the [Better Error Handling](./../guides/better-error-handling.md) guide to
  learn about best practices for error handling in Move.
