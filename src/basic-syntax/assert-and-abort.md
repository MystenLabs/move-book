# Assert and Abort

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

## Abort

The `abort` keyword is used to abort the execution of a transaction. It is used in combination with an abort code, which will be returned to the caller of the transaction. The abort code is an integer of type `u64` and can be any value.

```move
let user_has_access = true;

// abort with a predefined constant if `user_has_access` is false
if (!user_has_access) {
    abort 0
};

// there's an alternative syntax using parenthesis`
if (user_has_access) {
   abort(0)
};

/* ... */
```

## assert!

The `assert!` macro is a built-in macro that can be used to assert a condition. If the condition is false, the transaction will abort with the given abort code. The `assert!` macro is a convenient way to abort a transaction if a condition is not met. The macro shortens the code otherwise written with an `if` expression + `abort`.

```move
// aborts if `user_has_access` is false with abort code 0
assert!(user_has_access, 0);

// expands into:
if (!user_has_access) {
    abort 0
};
```

## Error constants

To make error codes more descriptive, it is a good practice to define error constants. Error constants are defined as `const` declarations and are usually prefixed with `E` followed by a camel case name. Error constatns are no different from other constants and don't have special handling. So their addition is purely a practice for better code readability.

```move
/// Error code for when the user has no access.
const ENoAccess: u64 = 0;
/// Trying to access a field that does not exist.
const ENoField: u64 = 1;

// asserts are way more readable now
assert!(user_has_access, ENoAccess);
assert!(field_exists, ENoField);
```

## Further reading

We suggest reading the [Better Error Handling](./../guides/better-error-handling.md) guide to learn about best practices for error handling in Move.
