# Control Flow

Move is an imperative language and like one it has *control flow* - a way to make choice whether to run a block of code or to skip or to run another one instead.

<!-- In Move you have two statme to control flow: by using loops (`while` and `loop`) or `if` expressions. -->

In Move you have loops (`while` and `loop`) and `if` expressions.

## The `if` expression

The `if` expression allows you to run a block of code if a condition is `true`, and to run another block instead if the condition resulted in `false`.

```Move
script {
    use 0x1::Debug;

    fun main() {
        let a = true;

        if (a) {
            Debug::print<u8>(&0);
        } else {
            Debug::print<u8>(&99);
        };
    }
}
```

In this example we've used `if` + `block` to print `0` if `a == true` and if a is `false` - then `99` is printed. Simple as that, if syntax is:

```
if (<bool_expression>) <expression> else <expression>;
```

`if` is an expression, and like all of them it must end with semicolon. This is also a reason to use it with the `let` statement!

```Move
script {
    use 0x1::Debug;

    fun main() {

        // try switching to false
        let a = true;
        let b = if (a) { // 1st branch
            10
        } else { // 2nd branch
            20
        };

        Debug::print<u8>(&b);
    }
}
```

Now variable `b` will be assigned a different value depending on the `a` expression. But both of the branches in `if` must return the same type! Otherwise variable `b` will have an option to be of different kind (or undefined) and this is impossible in statically typed language. In compiler terms it's called *branch compatibility* - both of the branches must return compatible (same) type.

`if` can be used in-solo - without `else`.

```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        // only one optional branch
        // if a = false, debug won't be called
        if (a) {
            Debug::print<u8>(&10);
        };
    }
}
```

But keep in mind that the `if` expression without `else` branch cannot be used in assignment as when condition is not met - alternative branch is not called and variable may be "undefined" which is, again, impossible.

## Iterating with loops

There're two ways of defining loops in Move:

1. Conditional loop with `while`
2. Inifinite `loop`

### Conditional loop with `while`

`while` is a way to define a loop - an expression which will be executed repeatedly *while* the condition evaluates to `true`. To implement a condition usually an external variable (or a counter) is used.

```Move
script {
    fun main() {

        let i = 0; // define counter

        // iterate while i < 5
        // on every iteration increase i
        // when i is 5, condition fails and loop exits
        while (i < 5) {
            i = i + 1;
        };
    }
}
```

It's worth mentioning that `while` is an expression - just like `if`, and it too requires a semicolon afterwards. Syntax for the while loop can be expressed as:

```Move
while (<expression: bool>) <expression>;
```

Unlike `if`, `while` cannot return a value, so a variable assignment (like we did with `if` expression) is impossible.

### Unreachable code

To be reliable Move must be secure. This is why it obliges you to use all your variables and for the same reason it forbids having unreachable code. As digital assets are programmable, they can be used in code (you'll learn about it in [resources chapter](/chapters/resource.md)), and placing them in unreachable areas may lead to their loss as the result.

This is why unreachable code is such a big issue. Now that is clear, we can proceed.

### Infinite `loop`

There is a way to define infinite loops. They're non-conditional and actually infinite (unless you force them to stop). Unfortunately, the compiler cannot define whether a loop is infinite (in most of the cases) and cannot stop you from publishing the code, execution of which will consume all given resources (in blockchain terms - gas). So it's on you to test your code properly when using them or just switch to a conditional `while` as it's way more secure.

Infinite loops are defined with the keyword `loop`.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;
        };

        // UNREACHABLE CODE
        let _ = i;
    }
}
```

However this is possible (compiler will let you do this):

```Move
script {
    fun main() {
        let i = 0;

        loop {
            if (i == 1) { // i never changed
                break // this statement breaks loop
            }
        };

        // actually unreachable
        0x1::Debug::print<u8>(&i);
    }
}
```

Syntax for the `loop` is:

```Move
loop <expression>;
```

It's a non-trivial task for the compiler to understand whether a loop is really infinite or not, so for now you and only you can help yourself avoid looping errors.

### Control loops with `continue` and `break`

Keywords `continue` and `break` allow you to skip an iteration or break it respectively. You can use them in both types of loops.

For example let's add two conditions into the `loop`. If `i` is even, we use `continue` to jump to the next iteration without going through code after the `continue` call.

With `break` we exit the loop ignoring the rest of the block.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i / 2 == 0) continue;
            if (i == 5) break;

            // assume we do something here
         };

        0x1::Debug::print<u8>(&i);
    }
}
```

About semicolons. If `break` and `continue` are the last in a block, you can't put a semicolon after them as any code after won't be executed. Somehow even the semicolon can't be put. See this:

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i == 5) {
                break; // will result in compiler error. correct is `break` without semi
                       // Error: Unreachable code
            };

            // same with continue here: no semi, never;
            if (true) {
                continue
            };

            // however you can put semi like this, because continue and break here
            // are single expressions, hence they "end their own scope"
            if (true) continue;
            if (i == 5) break;
        }
    }
}
```

### Conditional `abort`

Sometimes you need to abort an execution of a transaction when some condition has failed. For that case there's the `abort` keyword.

```Move
script {
    fun main(a: u8) {

        if (a != 10) {
            abort 0;
        }

        // code here won't be executed if a != 10
        // transaction aborted
    }
}
```

Keyword `abort` allows you to *abort* execution with an error code which is placed right after.

### Use `assert` built-in

Built-in `assert!(<expression: bool>, <code>)` method already wraps `abort` + condition and is accessible anywhere in code:

```Move
script {
    fun main(a: u8) {
        assert!(a == 10, 0);

        // code here will be executed if (a == 10)
    }
}
```

`assert!()` will abort execution when condition is not met, or it will do nothing in the opposite case.

### Further reading

- [While and Loop in the Documentation](https://move-language.github.io/move/loops.html)
- [Conditionals in the Documentation](https://move-language.github.io/move/conditionals.html)
- [Abort and Assert in the Documentation](https://move-language.github.io/move/abort-and-assert.html)
