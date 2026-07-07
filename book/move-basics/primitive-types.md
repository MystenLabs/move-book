---
description:
  'Move primitive types: booleans and unsigned integers from u8 to u256 - literals and type
  inference, arithmetic and comparison, casting with as, and overflow behavior.'
---

# Primitive Types

Move is a statically typed language: every value has a type, known at compilation time. This
section introduces the simplest of them - the built-in _primitive_ types: booleans and unsigned
integers. Together with [addresses](./address), covered in the next section, they are the material
every other type is built from.

> The code samples in this chapter are excerpts: expressions like the ones below live inside a
> function - usually a [test function](./testing) - in a module, which we omit for brevity. To try
> a sample yourself, place it inside a `#[test]` function of the package created in the
> [Hello World](./../your-first-move/hello-world) chapter and run `sui move test`.

## Variables and Assignment

Variables are declared with the `let` keyword, and they are _immutable_ by default: once a value is
assigned, it cannot be replaced. A variable that needs to change is declared with `let mut`, and
only then can it be reassigned with the `=` operator:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=variables_and_assignment

```

The type annotation - the `: u8` after the name - is optional wherever the compiler can infer the
type from the value or from later use; writing it out is a matter of clarity, not necessity.

A variable name can also be reused by declaring it again, which is called _shadowing_. Unlike
reassignment, shadowing creates a new variable, so it works on immutable variables and can change
the type:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=shadowing

```

## Booleans

The `bool` type has exactly two values - the keywords `true` and `false` - and the compiler always
infers it, so a `bool` never needs a type annotation. Booleans combine with the logical operators
`&&` (and), `||` (or), and `!` (not), where `&&` and `||` short-circuit: the right-hand side is not
evaluated if the left-hand side already decides the result.

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=boolean

```

Booleans store flags and drive conditions - the `if` and `while` expressions covered in the
[Control Flow](./control-flow) section.

## Integer Types

Move has six integer types, differing only in size - and all of them _unsigned_: there are no
negative integers in Move, and no dedicated signed types.

<div class="modules-table">

| Type   | Size (bits) | Maximum Value                  |
| ------ | ----------- | ------------------------------ |
| `u8`   | 8           | `255`                          |
| `u16`  | 16          | `65_535`                       |
| `u32`  | 32          | `4_294_967_295`                |
| `u64`  | 64          | `18_446_744_073_709_551_615`   |
| `u128` | 128         | 2<sup>128</sup> − 1            |
| `u256` | 256         | 2<sup>256</sup> − 1            |

</div>

The workhorse is `u64` - token amounts, sizes, and indices all use it. Integer literals are written
in decimal (`42`), with optional underscores for readability (`1_000_000`), or in hexadecimal with
the `0x` prefix (`0x2A`):

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=integers

```

While `true` and `false` are unambiguously booleans, a literal like `42` could be any of the six
integer types. The compiler infers the type from how the value is used, defaulting to `u64`; when
inference is not enough - or when being explicit reads better - the type can be given as an
annotation or as a literal suffix:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=integer_explicit_type

```

### Operations

Move supports the standard arithmetic operations for integers: addition, subtraction,
multiplication, division, and modulus (remainder). None of them can produce a value outside the
range of the type - instead of wrapping around, the operation aborts:

<div class="modules-table">

| Syntax | Operation           | Aborts If                                |
| ------ | ------------------- | ---------------------------------------- |
| +      | addition            | Result is too large for the integer type |
| -      | subtraction         | Result is less than zero                 |
| \*     | multiplication      | Result is too large for the integer type |
| %      | modulus (remainder) | The divisor is 0                         |
| /      | truncating division | The divisor is 0                         |

</div>

Division is _truncating_: there are no fractional values, and any remainder is discarded, so
`7 / 2` is `3`. Integers can also be compared with `==`, `!=`, `<`, `>`, `<=`, and `>=`, producing
a `bool`:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=comparison

```

In every operation and comparison, the types of the operands _must match_ - there is no implicit
conversion between integer types, and adding a `u8` to a `u64` is a compilation error. To operate
on different types, one of the operands has to be explicitly cast.

> For more operations, including bitwise operations, refer to the
> [Move Reference](./../../reference/primitive-types/integers#bitwise).

### Casting with `as`

The `as` operator converts an integer from one type to another. Note that an expression with a cast
often needs parentheses around it to prevent ambiguity:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=cast_as

```

Casting _up_ to a larger type always succeeds. Casting _down_ must fit: unlike languages that
silently truncate the value, Move aborts when it is out of range:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=downcast

```

A common use of upcasting is making room for an intermediate result that would not fit into the
original type:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=overflow

```

### Overflow and Underflow

As the operations table shows, arithmetic in Move never wraps around. An operation whose result
does not fit into the type - too large, or below zero - aborts at runtime:

```move file=packages/samples/sources/move-basics/primitive-types.move anchor=overflow_abort

```

This is a deliberate safety feature. Silent overflow is a classic source of smart contract bugs -
a balance that wraps around to zero, or a check that passes because a value quietly became small.
Move turns every such case into a loud failure that reverts the transaction.

## Further Reading

- [Bool](./../../reference/primitive-types/bool) in the Move Reference.
- [Integer](./../../reference/primitive-types/integers) in the Move Reference.
- [std::u64](https://docs.sui.io/references/framework/std/u64) module documentation - every integer
  type has a helper module (`std::u8` through `std::u256`) with functions like `min`, `max`, `sqrt`,
  and more.
