# Function

Functions are the building blocks of Move programs. They are called from [user transactions](../concepts/user-interaction.md) and from other functions and group executable code into reusable units. Functions can take arguments and return a value. They are declared with the `fun` keyword at the module level. Just like any other module member, by default they're private and can only be accessed from within the module.

```move
module book::math {
    /// Function takes two arguments of type `u64` and returns their sum.
    /// The `public` visibility modifier makes the function accessible from
    /// outside the module.
    public fun add(a: u64, b: u64): u64 {
        a + b
    }

    #[test]
    fun test_add() {
        let sum = add(1, 2);
        assert!(sum == 3, 0);
    }
}
```

In this example, we define a function `add` that takes two arguments of type `u64` and returns their sum. The function is called from the `test_add` function, which is a test function located in the same module. In the test we compare the result of the `add` function with the expected value and abort the execution if the result is different.

## Function declaration

> There's a convention to call functions in Move with the `snake_case` naming convention. This means that the function name should be all lowercase with words separated by underscores. For example, `do_something`, `add`, `get_balance`, `is_authorized`, and so on.

A function is declared with the `fun` keyword followed by the function name (a valid Move identifier), a list of arguments in parentheses, and a return type. The function body is a block of code that contains a sequence of statements and expressions. The last expression in the function body is the return value of the function.

```move
fun return_nothing() {
    // empty expression, function returns `()`
}
```

## Accessing functions

Just like any other module member, functions can be imported and accessed via a path. The path consists of the module path and the function name separated by `::`. For example, if you have a function called `add` in the `math` module in the `book` package, the path to it will be `book::math::add`, or, if the module is imported, `math::add`.

```move
module book::use_math {
    use book::math;

    fun call_add() {
        // function is called via the path
        let sum = math::add(1, 2);
    }
}
```

## Multiple return values

Move functions can return multiple values, which is useful when you need to return more than one value from a function. The return type of the function is a tuple of types. The return value is a tuple of expressions.

```move
fun get_name_and_age(): (vector<u8>, u8) {
    (b"John", 25)
}
```

Result of a function call with tuple return has to be unpacked into variables via `let (tuple)` syntax:

```move
// declare name and age as immutable
let (name, age) = get_name_and_age();
```

If any of the declared values need to be declared as mutable, the `mut` keyword is placed before the variable name:

```move
// declare name as mutable, age as immutable
let (mut name, age) = get_name_and_age();
```

If some of the arguments are not used, they can be ignored with the `_` symbol:

```move
// ignore the name, declare age as mutable
let (_, mut age) = get_name_and_age();
```
