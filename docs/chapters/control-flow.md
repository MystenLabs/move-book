# Control Flow

Move is imperative language and like one it has *control flow* - a way to make schoice whether to run block of code or to skip or to run another one instead.

<!-- In Move you have two statme to control flow: by using loops (`while` and `loop`) or `if` expressions. -->

In Move you have loops (`while` and `loop`) and `if` expressions.

## The `if` expression

`if` expression allows you to run a block of code if some condition is true, and to run another block instead if condition resulted in false.

```Move
script {
    use 0x0::Debug;

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

`if` is an expression, and like all of them it must end with semicolon. This is also a reason to use it with `let` statement!

```Move
script {
    use 0x0::Debug;

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

Now variable `b` will be assigned a different value depending on the `a` expression. But both of the branhes in `if` must return the same type! Otherwise variable `b` will have an option to be of different kind (or undefined) and this is impossible in statically typed language. In compiler terms it's called *branch compatibility* - both of the branches must return compatible (same) type.

`if` can be used in-solo - without `else`.

```Move
script {
    use 0x0::Debug;

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

But keep in mind that `if` expression without `else` branch cannot be used in assignment as when condition is not met - alternative branch is not called and variable may be undefined which is, again, impossible.

## Iterating with loops

There're two ways of defining loops in Move:
1. Conditional loop with `while`
2. Inifinite `loop`

### Conditional loop with `while`

`while` is a way to define loop - expression which will be executed while some condition is true. So simply: code will be run over and over *while* condition is `true`. To implement condition usually external variable (or counter) is used.

```Move
fun main() {

    let i = 0; // define counter

    // iterate while i < 5
    // on every iteration increase i
    // when i is 5, condition fails and loop exits
    while (i < 5) {
        i = i + 1;
    };
}
```

It's worth mentioning that `while` is an expression - just like `if` is, and it too requires a semicolon afterwards. Generic syntax for while loop is:

```Move
while (<bool_expression>) <expression>;
```

Unlike `if`, `while` cannot return a value, so variable assignment (like we did with `if` expersion) is impossible.

### Unreachable code

To be reliable Move must be secure. This is why it obliges you to use all your variables and for the same reason it forbids having unreachable code. As digital assets are programmable, they can be used in code (you'll learn about it in [resources chapter](/chapters/resource.md)), and placing them in unreachable area may lead to inconvinience and their loss as the result.

This is why unreachable code is such a big issue. Now that is clear, we can proceed.

### Infinite `loop`

There is a way to define infinite loops. They're non-conditional and actually infinite (unless you force them to stop). Unfortunately compiler cannot define whether a loop is infinite (in most of the cases) and cannot stop you from publishing code, execution of which will consume all given resources (in blockchain terms - gas). So it's on you to test your code properly when using them or just switch to conditional `while` as it's way more secure.

Infinite loops are defined with keyword `loop`.

```Move
fun main() {
    let i = 0;

    loop {
        i = i + 1;
    };

    // UNREACHABLE CODE
    let _ = i;
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
        0x0::Debug::print<u8>(&i);
    }
}
```

It's a non-trivial task for compiler to understand whether loop is really infinite or not, so for now you and only you can help yourself avoid looping errors. As I described above, this can lead to assets loss.

### Control loops with `continue` and `break`

Keywords `continue` and `break` allow you to skip one round or break iteration respectively. You can use both of them in both types of loops.

For example let's add two conditions into `loop`. If `i` is even we use `continue` to jump to next iteration without going through code after `continue` call.

With `break` we stop iteration and exit loop.

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

        0x0::Debug::print<u8>(&i);
    }
}
```

About semicolons. If `break` and `continue` are the last keywords in block, you can't put a semicolon after them as any code after won't be executed. Somehow even semi can't be put. See this:

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
