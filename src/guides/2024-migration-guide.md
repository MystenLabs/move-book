# Move 2024 Migration Guide

Move 2024 is the new edition of the Move language that is maintained by Mysten Labs. This guide is intended to help you understand the differences between the 2024 edition and the previous version of the Move language.

## Using the New Edition

To use the new edition, you need to specify the edition in the `move` file. The edition is specified in the `move` file using the `edition` keyword. Currently, the only available edition is `2024.alpha`.

```ini
edition = "2024.alpha";
```

## Struct Visibility

In Move 2024, structs get a visibility modifier. Just like functions, structs can be public, friend, or private.

```move
// Move 2020
struct Book {}

// Move 2024
public struct Book {}
```

## Struct Methods

In the new edition, functions which have a struct as the first argument are associated with the struct. This means that the function can be called using the dot notation. Methods defined in the same module with the type are automatically exported.

```move
public fun count(c: &Counter): u64 { /* ... */ }

fun use_counter() {
    // move 2020
    let count = counter::count(&c);

    // move 2024
    let count = c.count();
}
```

## Borrowing Operator

The `borrow` and `borrow_mut` functions (when defined) can be accessed using the square brackets. Just like the method syntax, the borrowing functions are associated with the type.

```move
fun play_vec() {
    let v = vector[1,2,3,4];
    let first = v[0]; // calls vector::borrow(v, 0)
    v[0] = 5;         // calls vector::borrow_mut(v, 0)
}
```

## Method Aliases

In Move 2024, generic methods can be associated with types. The alias can be defined for any type privately to the module, or publicly, if the type is defined in the same module.

```move
use fun my_custom_function as vector.do_magic;
```

## Macros

Macros are introduced in Move 2024. And `assert!` is no longer a built-in function - Instead, it's a macro.

```move
// can be called as for!(0, 10, |i| call(i));
macro fun for($start: u64, $stop: u64, $body: |u64|) {
    let mut i = $start;
    let stop = $stop;
    while (i < stop) {
        $body(i);
        i = i + 1
    }
}
```
