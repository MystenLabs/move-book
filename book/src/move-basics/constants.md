# Constants

<!--

Chapter: Basic Syntax
Goal: Introduce constants.
Notes:
    - constants are immutable
    - constants are private
    - start with a capital letter always
    - stored in the bytecode (but w/o a name)
    - mention standard for naming constants

Links:
    - next section (abort and assert)
    - coding conventions (constants)
    - constants (language reference)

 -->

Constants are immutable values that are defined at the module level. They often serve as a way to
give names to static values that are used throughout a module. For example, if there's a default
price for a product, you might define a constant for it. Constants are stored in the module's
bytecode, and each time they are used, the value is copied.

```move
{{#include ../../../packages/samples/sources/move-basics/constants.move:shop_price}}
```

## Naming Convention

Constants must start with a capital letter - this is enforced at the compiler level. For constants
used as a value, there's a convention to use uppercase letters and underscores to separate words.
It's a way to make constants stand out from other identifiers in the code. One exception is made for
[error constants](./assert-and-abort.md#assert-and-abort), which are written in ECamelCase.

```move
{{#include ../../../packages/samples/sources/move-basics/constants.move:naming}}
```

## Constants are Immutable

Constants can't be changed and assigned new values. They are part of the package bytecode, and
inherently immutable.

```move
module book::immutable_constants {
    const ITEM_PRICE: u64 = 100;

    // emits an error
    fun change_price() {
        ITEM_PRICE = 200;
    }
}
```

## Using Config Pattern

A common use case for an application is to define a set of constants that are used throughout the
codebase. But due to constants being private to the module, they can't be accessed from other
modules. One way to solve this is to define a "config" module that exports the constants.

```move
{{#include ../../../packages/samples/sources/move-basics/constants.move:config}}
```

This way other modules can import and read the constants, and the update process is simplified. If
the constants need to be changed, only the config module needs to be updated during the package
upgrade.

## Links

- [Constants](/reference/constants.html) in the Move Language Reference
- [Coding conventions for constants](./../guides/coding-conventions.md#constant)
