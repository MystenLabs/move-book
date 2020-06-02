# Function

Function is the only place of execution in Move. Function starts with the `fun` keyword which is followed by function name, parentheses for arguments and curly braces for body.

```Move
fun function_name(arg1: u64, arg2: bool): u64 {
    // function body
}
```
You have already seen some in previous chapters. And now you will learn how to use them.

> **Note:** in Move functions should be named in *snake_case* - lowercase with underscores as word separators.

## Function in script

Script block can contain only one function which is considered *main*. This function (possibly with arguments) will be executed as a transaction. It is very limited: it cannot return value and should be used to operate other functions in already published modules.

Here's an example of simple script which checks if address exists:

```Move
script {
    use 0x0::Account;

    fun main(addr: address) {
        Transaction::assert(Account::exists(addr), 1);
    }
}
```
This function can have arguments: in this case it is `addr` argument with type `address`, also it can operate imported modules.

> **Note:** as there's only one function, you can call it any way you want. Though you may want to follow general programming concepts and call it **main**

## Function in module

While script context is fairly limited, full potential of functions can only be seen in a module. Let's go through it again: module is a published set of functions and types (we'll get to it in the next chapter) which solves one or many tasks.

In this part we'll create a simple Math module which will provide users with a basic set of mathematical functions and a few helper methods. Most of this could be done without using a module, but our goal is education!

```Move
module Math {
    fun zero(): u8 {
        0
    }
}
```

First step: we've defined a module named `Math` with one function in it: `zero()`, which returns 0 - a value of type `u8`. Remember [expressions](/chapters/expression-and-scope.md)? There's no semicolon after `0` as it is the *return value* of this function. Just like you would do with block. Yeah, function body is very similar to block.

### Function arguments

This should be clear by now, but let's repeat. Function can take arguments (values passed into function). As many as needed. Every argument has 2 properties: name - its name within a function body, and type - just like any other variable in Move.

Function arguments - just like any other variables defined within a scope - live only within function body. When the function block ends, no variables remain.

```Move
module Math {

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    fun zero(): u8 {
        0
    }
]
```

What's new in our Math: function `sum(a,b)` which sums two `u64` values and returns a result - `u64` sum (type can't change).

Let's state few syntax rules:

1. Arguments must have types and must be separated by comma
2. Function return value is placed after parentheses and must follow a colon

Now how would we use this function in script? Through import!

```Move
script {
    use 0x1::Math;  // used 0x1 here; could be your address
    use 0x0::Debug; // this one will be covered later!

    fun main(first_num: u64, second_num: u64) {

        // variables names don't have to match the function's ones
        let sum = Math::sum(first_num, second_num);

        Debug::print<u64>(&sum);
    }
}
```

### Multiple return values

In previous examples we've experimented with functions with no return value or with single. But what if I told you that you can return multiple values of any type? Curious? Let's proceed!

To specify multiple return values you need to use parentheses:

```Move
module Math {

    // ...

    public fun max(a: u8, b: u8): (u8, bool) {
        if (a > b) {
            (a, false)
        } else if (a < b) {
            (b, false)
        } else {
            (a, true)
        }
    }
}
```
This function takes two arguments: `a` and `b` and *returns two values*: first is the max value from two passed and second is a bool - whether numbers entered are equal. Take closer look at the syntax: instead of specifying single return argument we've added *parenteses* and have listed return argument types.

Now let's see how we can use the result of this function in another function in the script.

```Move
script {
    use 0x0::Debug;
    use 0x1::Math;

    fun main(a: u8, b: u8)  {
        let (max, is_equal) = Math::max(99, 100);

        Transaction::assert(is_equal, 1)

        Debug::print<u8>(&max);
    }
}
```

In this example we've *destructed* a tuple: created two new variables with values and types of return values of function *max*. Order is preserved and variable *max* here gets type *u8* and now stores max value, whereas *is_equal* is a *bool*.

Two is not the limit - number of returned arguments is up to you, though you'll soon learn about structs and see alternative way to return complex data.

### Function visibility

When defining a module you may want to make some functions accessible by other developers and some to remain hidden. This is when *function visibility modifiers* come to play.

By default every function defined in a module is private - it cannot be accessed in other modules or scripts. If you've been attentive, you may have noticed that some of the functions that we've defined in our Math module have keyword `public` before their definition:

```Move
module Math {

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    fun zero(): u8 {
        0
    }
}
```

In this example function `sum()` is accessible from outside when module is imported, however function `zero()` is not - it is private by default.

> Keyword `public` changes function's default *private* visibility and makes it *public* - i.e. accessible from outside.

So basically if you didn't make `sum()` function *public*, this wouldn't be possible:

```Move
script {
    use 0x1::Math;

    fun main() {
        Math::sum(10, 100); // won't compile!
    }
}
```

### Access local functions

There would not be any sense in making private functions if they could not be accessed at all. Private functions exist to do some *internal* work when public functions are called.

> Private functions can only be accessed in the module where they're defined.

So how do you access functions in the same module? By simply calling this function like it was imported!

```Move
module Math {

    public fun is_zero(a: u8): bool {
        a == zero()
    }

    fun zero(): u8 {
        0
    }
}
```

Any function defined in a module is accessible by any function in the same module no matter what visibility modifiers any of them has. This way private functions can still be used as calls inside public ones without exposing some private features or too risky operations.

### Native functions

There's a special kind of functions - *native* ones. *Native functions* implement functionality which goes beyond Move's possibilities and give you extra power. Native functions are defined by VM itself and may vary in different implementations. Which means they don't have implementation in Move syntax and instead of having function body they end with a semicolon. Keyword `native` is used to mark native functions. It does not conflict with function visibility modifiers and the same function can be `native` and `public` at the same time.

Here's an example from Libra's standard library.

```Move
module Transaction {
    // get transaction sender, you can't do it other way
    native public fun sender(): address;

    // ...
}
```

