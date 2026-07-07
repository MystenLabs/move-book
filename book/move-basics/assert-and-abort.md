---
description: "Error handling in Move: use abort to halt execution with error codes and assert! to enforce conditions in smart contracts."
---

# Aborting Execution

A transaction can end in one of two ways: it either succeeds, and all of the changes it made are
applied and committed to the blockchain, or it _aborts_, and none of the changes are applied. There
is nothing in between: a transaction cannot partially succeed, and an abort in a deeply nested
function call fails the entire transaction. This all-or-nothing model is what makes error handling
in Move simple and predictable - a function never needs to undo its changes, because an abort
undoes everything at once.

> There is no catch mechanism in Move. An abort cannot be intercepted or recovered from: it always
> fails the whole transaction. This is a design choice - it trades flexibility for simplicity and
> makes it impossible to end up in a partially updated state.

In this section, we look at the tools Move provides for aborting: the `abort` expression, the
`assert!` macro, and the conventions for defining error codes and error messages.

## Abort

The `abort` keyword stops execution immediately. It is normally given an _abort code_ - an
[integer](./primitive-types) of type `u64` - which is returned to the caller of the transaction
together with the identity of the module that aborted. Here is an example:

```move file=packages/samples/sources/move-basics/assert-and-abort.move anchor=abort

```

The code above will, of course, abort with abort code `1`.

Two properties of abort codes are worth internalizing early:

- Abort codes are _local to the module_. Two different modules can both abort with code `1`, and
  they mean different things; the caller has to interpret the code together with the module that
  produced it.
- An abort code carries no message. The blockchain records only the numeric code and the location
  of the abort - making the codes readable is up to the module author, which is what
  [error constants](#error-constants) and [error messages](#error-messages) below are for.

## Omitting the Abort Code

The abort code can be omitted in the source - a bare `abort` expression is valid Move:

```move file=packages/samples/sources/move-basics/assert-and-abort.move anchor=clean_abort

```

Omitted does not mean absent, though: the caller still receives a `u64` abort code, derived
automatically by the compiler. The derived code uses the clever-error encoding described in
[Error Messages](#error-messages) below - it carries the module and the source line of the
failure, with the constant name and value left empty.

This form, sometimes called a _clean abort_, is a good fit for branches that are not expected to be
reachable at all - such as the wildcard arm of a `match` expression covering values that cannot
occur (see [Enums and Match](./enum-and-match)). Since the derived code points at the failure but
says nothing about its _meaning_, for conditions that external callers can actually trigger, prefer
an explicit code or an error message.

## assert!

The `assert!` macro is a built-in macro that checks a condition and aborts if the condition is
false. It is a shorthand for the `if` + `abort` combination you would otherwise write by hand, and
it is by far the most common way to abort in Move code. The first argument is the condition; the
second, optional, argument is the abort code - when it is omitted, a code is derived automatically,
the same way as for a bare `abort`:

```move file=packages/samples/sources/move-basics/assert-and-abort.move anchor=assert

```

A common practice is to place asserts at the beginning of a function - check everything first, then
perform the changes. Because an abort reverts the whole transaction this is not required for
safety, but it makes the function's requirements visible at a glance and avoids wasting
[gas](./../concepts/what-is-a-transaction) on work that is bound to be thrown away.

## Error Constants

A raw numeric code like `assert!(user_has_access, 1)` tells the reader nothing about what went
wrong. To make error codes descriptive, it is a good practice to define them as
[constants](./constants). Error constants follow their own naming convention - `E` followed by a
CamelCase description - which sets them apart from regular `ALL_CAPS` constants:

```move file=packages/samples/sources/move-basics/assert-and-abort.move anchor=error_const

```

Error constants are regular `u64` constants and receive no special treatment from the compiler.
However, following the convention makes the code self-documenting -
`assert!(user_has_access, ENoAccess)` reads as a sentence - and a caller who receives the abort
code can find the matching constant in the module's source. A well-written module defines an error
constant for every abort scenario it can produce.

## Error Messages

Move 2024 introduces _clever errors_ - error constants marked with the `#[error]` attribute. Unlike
regular error constants, they can be of any type - most usefully `vector<u8>`, holding a
human-readable error message:

```move file=packages/samples/sources/move-basics/assert-and-abort.move anchor=error_attribute

```

The attribute does not change what an abort is: the transaction still fails with a `u64` abort
code. What changes is the content of that code - the compiler packs into it the source line number
of the abort (for a macro like `assert!`, the line of the call site) and references to the
constant's name and value. Tooling that understands the format - the Sui CLI, explorers, SDKs -
unpacks it and shows the full picture, along the lines of:

```text
Error from 'book::assert_abort::update_value' (line 15), abort 'EValueTooLow':
"The value is too low, it should be at least 10"
```

Error messages remove the need to look up the meaning of a numeric code, which matters most in
public-facing applications, where the person reading the failure is often not the author of the
module. The flip side of the encoding is that the numeric value of a clever abort code depends on
the source layout: reformatting the module or adding a line changes it. Refer to these constants by
name - never by their compiled numeric value. The exact layout of the encoding is described in
[Clever Errors](./../../reference/abort-and-assert/clever-errors) in the Move Reference.

## Aborts in Tests

Aborting is a behavior worth testing like any other. The `#[expected_failure]` attribute marks a
test that is supposed to abort, and its `abort_code` argument asserts the exact code - the test
fails if the function succeeds or aborts with a different code. We cover this attribute in more
detail in the [Testing](./testing) section.

## Further Reading

- [Abort and Assert](./../../reference/abort-and-assert) in the Move Reference.
- [Clever Errors](./../../reference/abort-and-assert/clever-errors) in the Move Reference.
- We suggest reading the [Better Error Handling](./../guides/better-error-handling) guide to learn
  about best practices for error handling in Move.
