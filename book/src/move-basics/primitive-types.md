# Primitive Types

<!-- TODO: Shall we split this into two pages? Maybe give an overview and focus more on specifics? -->

For simple values, Move has a number of built-in primitive types. They're the base that makes up all
other types. The primitive types are:

- [Booleans](#booleans)
- [Unsigned Integers](#integers)
- [Address](./address.md) - covered in the next section

However, before we get to the types, let's first look at how to declare and assign variables in
Move.

## Variables and assignment

Variables are declared using the `let` keyword. They are immutable by default, but can be made
mutable using the `let mut` keyword. The syntax for the `let mut` statement is:

```
let <variable_name>[: <type>]  = <expression>;
let mut <variable_name>[: <type>] = <expression>;
```

Where:

- `<variable_name>` - the name of the variable
- `<type>` - the type of the variable, optional
- `<expression>` - the value to be assigned to the variable

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:variables_and_assignment}}
```

A mutable variable can be reassigned using the `=` operator.

```move
y = 43;
```

Variables can also be shadowed by re-declaring.

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:shadowing}}
```

## Booleans

The `bool` type represents a boolean value - yes or no, true or false. It has two possible values:
`true` and `false` which are keywords in Move. For booleans, there's no need to explicitly specify
the type - the compiler can infer it from the value.

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:boolean}}
```

Booleans are often used to store flags and to control the flow of the program. Please, refer to the
[Control Flow](./control-flow.md) section for more information.

## Integer Types

Move supports unsigned integers of various sizes: from 8-bit to 256-bit. The integer types are:

- `u8` - 8-bit
- `u16` - 16-bit
- `u32` - 32-bit
- `u64` - 64-bit
- `u128` - 128-bit
- `u256` - 256-bit

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:integers}}
```

Unlike booleans, integer types need to be inferred. In most of the cases, the compiler will infer
the type from the value, usually defaulting to `u64`. However, sometimes the compiler is unable to
infer the type and will require an explicit type annotation. It can either be provided during
assignment or by using a type suffix.

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:integer_explicit_type}}
```

### Operations

Move supports the standard arithmetic operations for integers: addition, subtraction,
multiplication, division, and remainder. The syntax for these operations is:

| Syntax | Operation           | Aborts If                                |
| ------ | ------------------- | ---------------------------------------- |
| +      | addition            | Result is too large for the integer type |
| -      | subtraction         | Result is less than zero                 |
| \*     | multiplication      | Result is too large for the integer type |
| %      | modular division    | The divisor is 0                         |
| /      | truncating division | The divisor is 0                         |

> For more operations, including bitwise operations, please refer to the
> [Move Reference](/reference/primitive-types/integers.html#bitwise).

The type of the operands _must match_, otherwise, the compiler will raise an error. The result of
the operation will be of the same type as the operands. To perform operations on different types,
the operands need to be cast to the same type.

<!-- TODO: add examples + parentheses for arithmetic operations -->
<!-- TODO: add bitwise operators -->

### Casting with `as`

Move supports explicit casting between integer types. The syntax for it is:

```move
<expression> as <type>
```

Note, that it may require parentheses around the expression to prevent ambiguity.

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:cast_as}}
```

A more complex example, preventing overflow:

```move
{{#include ../../../packages/samples/sources/move-basics/primitive-types.move:overflow}}
```

### Overflow

Move does not support overflow / underflow, an operation that results in a value outside the range
of the type will raise a runtime error. This is a safety feature to prevent unexpected behavior.

```move
let x = 255u8;
let y = 1u8;

// This will raise an error
let z = x + y;
```

## Further reading

- [Bool](/reference/primitive-types/bool.html) in the Move Reference.
- [Integer](/reference/primitive-types/integers.html) in the Move Reference.
