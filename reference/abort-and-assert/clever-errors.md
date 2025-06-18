---
title: 'Clever Errors | Reference'
description:
  Clever errors are a feature that allows for more informative error messages when an assertion
  fails or an abort is raised
---

# Clever Errors

Clever errors are a feature that allows for more informative error messages when an assertion fails
or an abort is raised. They are a source feature and compile to a `u64` abort code value that
contains the information needed to access the line number, constant name, and constant value given
the clever error code and the module that the clever error constant was declared in. Because of this
compilation, post-processing is required to go from the `u64` abort code value to a human-readable
error message. The post-processing is automatically performed by the Sui GraphQL server, as well as
the Sui CLI. If you want to manually decode a clever abort code, you can use the process outlined in
[Inflating Clever Abort Codes](#inflating-clever-abort-codes) to do so.

> Clever errors include source line information amongst other data. Because of this their value may
> change due to any changes in the source file (e.g., due to auto-formatting, adding a new module
> member, or adding a newline).

## Clever Abort Codes

Clever abort codes allow you to use non-u64 constants as abort codes as long as the constants are
annotated with the `#[error]` attribute. They can be used both in assertions, and as codes to
`abort`.

```move
module 0x42::a_module;

#[error]
const EIsThree: vector<u8> = b"The value is three";

// Will abort with `EIsThree` if `x` is 3
public fun double_except_three(x: u64): u64 {
    assert!(x != 3, EIsThree);
    x * x
}

// Will always abort with `EIsThree`
public fun clever_abort() {
    abort EIsThree
}
```

In this example, the `EIsThree` constant is a `vector<u8>`, which is not a `u64`. However, the
`#[error]` attribute allows the constant to be used as an abort code, and will at runtime produce a
`u64` abort code value that holds:

1. A set tag-bit that indicates that the abort code is a clever abort code.
2. The line number of where the abort occurred in the source file (e.g., 7).
3. The index in the module's identifier table for the constant's name (e.g., `EIsThree`).
4. The index of the constant's value in the module's constant table (e.g., `b"The value is three"`).

In hex, if `double_except_three(3)` is called, it will abort with a `u64` abort code as follows:

```
0x8000_0007_0001_0000
  ^       ^    ^    ^
  |       |    |    |
  |       |    |    |
  |       |    |    +-- Constant value index = 0 (b"The value is three")
  |       |    +-- Constant name index = 1 (EIsThree)
  |       +-- Line number = 7 (line of the assertion)
  +-- Tag bit = 0b1000_0000_0000_0000
```

And could be rendered as a human-readable error message as (e.g.)

```
Error from '0x42::a_module::double_except_three' (line 7), abort 'EIsThree': "The value is three"
```

The exact formatting of this message may vary depending on the tooling used to decode the clever
error however all of the information needed to generate a human-readable error message like the
above is present in the `u64` abort code when coupled with the module where the error occurred.

> Clever abort code values do _not_ need to be a `vector<u8>` -- it can be any valid constant type
> in Move.

## Assertions with no Abort Codes

Assertions and `abort` statements without an abort code will automatically derive an abort code from
the source line number and will be encoded in the clever error format with the constant name and
constant value information will be filled with sentinel values of `0xffff` each. E.g.,

```move
module 0x42::a_module;

#[test]
fun assert_false(x: bool) {
    assert!(false);
}

#[test]
fun abort_no_code() {
    abort
}
```

Both of these will produce a `u64` abort code value that holds:

1. A set tag-bit that indicates that the abort code is a clever abort code.
2. The line number of where the abort occurred in the source file (e.g., 6).
3. A sentinel value of `0xffff` for the index into the module's identifier table for the constant's
   name.
4. A sentinel value of `0xffff` for the index of the constant's value in the module's constant
   table.

In hex, if `assert_false(3)` is called, it will abort with a `u64` abort code as follows:

```
0x8000_0004_ffff_ffff
  ^       ^    ^    ^
  |       |    |    |
  |       |    |    |
  |       |    |    +-- Constant value index = 0xffff (sentinel value)
  |       |    +-- Constant name index = 0xffff (sentinel value)
  |       +-- Line number = 4 (link of the assertion)
  +-- Tag bit = 0b1000_0000_0000_0000
```

## Clever Errors and Macros

The line number information in clever abort codes are derived from the source file at the location
where the abort occurs. In particular, for a function this will be the line number within in the
function, however for macros, this will be the location where the macro is invoked. This can be
quite useful when writing macros as it provides a way for users to use macros that may raise abort
conditions and still get useful error messages.

```move
module 0x42::macro_exporter;

public macro fun assert_false() {
    assert!(false);
}

public macro fun abort_always() {
    abort
}

public fun assert_false_fun() {
    assert!(false); // Will always abort with the line number of this invocation
}

public fun abort_always_fun() {
    abort // Will always abort with the line number of this invocation
}
```

Then in a module that uses these macros:

```move
module 0x42::user_module;

use 0x42::macro_exporter::{
    assert_false,
    abort_always,
    assert_false_fun,
    abort_always_fun
};

fun invoke_assert_false() {
    assert_false!(); // Will abort with the line number of this invocation
}

fun invoke_abort_always() {
    abort_always!(); // Will abort with the line number of this invocation
}

fun invoke_assert_false_fun() {
    assert_false_fun(); // Will abort with the line number of the assertion in `assert_false_fun`
}

fun invoke_abort_always_fun() {
    abort_always_fun(); // Will abort with the line number of the `abort` in `abort_always_fun`
}
```

## Inflating Clever Abort Codes

Precisely, the layout of a clever abort code is as follows:

```

|<tagbit>|<reserved>|<source line number>|<module identifier index>|<module constant index>|
+--------+----------+--------------------+-------------------------+-----------------------+
| 1-bit  | 15-bits  |       16-bits      |     16-bits             |        16-bits        |

```

Note that the Move abort will come with some additional information -- importantly in our case the
module where the error occurred. This is important because the identifier index, and constant index
are relative to the module's identifier and constant tables (if not set the sentinel values).

> To decode a clever abort code, you will need to know the module where the error occurred if either
> the identifier index or constant index are not set to the sentinel value of `0xffff`.

In pseudo-code, you can decode a clever abort code as follows:

```rust
// Information available in the MoveAbort
let clever_abort_code: u64 = ...;
let (package_id, module_name): (PackageStorageId, ModuleName) = ...;

let is_clever_abort = (clever_abort_code & 0x8000_0000_0000_0000) != 0;

if is_clever_abort {
    // Get line number, identifier index, and constant index
    // Identifier and constant index are sentinel values if set to '0xffff'
    let line_number = ((clever_abort_code & 0x0000_ffff_0000_0000) >> 32) as u16;
    let identifier_index = ((clever_abort_code & 0x0000_0000_ffff_0000) >> 16) as u16;
    let constant_index = ((clever_abort_code & 0x0000_0000_0000_ffff)) as u16;

    // Print the line error message
    print!("Error from '{}::{}' (line {})", package_id, module_name, line_number);

    // No need to print anything or load the module if both are sentinel values
    if identifier_index == 0xffff && constant_index == 0xffff {
        return;
    }

    // Only needed if constant name and value are not 0xffff
    let module: CompiledModule = fetch_module(package_id, module_name);

    // Print the constant name (if any)
    if identifier_index != 0xffff {
        let constant_name = module.get_identifier_at_table_index(identifier_index);
        print!(", '{}'", constant_name);
    }

    // Print the constant value (if any)
    if constant_index != 0xffff {
        let constant_value = module
            .get_constant_at_table_index(constant_index)
            .deserialize_on_constant_type()
            .to_string();

        print!(": {}", constant_value);
    }

    return;
}
```
