# Control Flow

Move is imperative language and like one it has *control flow* - a way to control execution and to make a choice whether to run block of code or to skip or to run another one instead.

In Move you have two ways to control flow: by using loops (`while` and `loop`) or `if` expressions.

## The `if`

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

`if` is an expression, and like all of them it must finish with semicolon. This fact also gives us an option to use it with `let` statement!

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

Now variable `b` will be assigned a different value depending on expression. But both of the return expressions in `if` must have the same type! Otherwise variable `b` will have an option to be of different kind and this is impossible in statically typed language. In compiler terms it's called *branch compatibility* - both of the branches must return compatible (same) type.

If can be used in-solo - without `else`.

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

But keep in mind that `if` expression without `else` branch cannot be used in assignment as when condition is not met alternative branch is not called and variable may be undefined which is - again - impossible.

## Iterating with loops

> In progress.

In Move you have two ways to do repetition: conditional loop with `while` and infinite `loop`.

Use while loop with bool expression inside parentheses:

```Move
fun main() {

    let i = 0;

    while (i < 5) {
        i = i + 1;
    }
}
```

For infinite (non-conditional) loops use `loop` keyword with expression:

```Move
fun main() {
    let i = 0;

    loop {
        i = i + 1;
        if (i == 5) break
    }
}
```

Syntax for loops:
```Move
while (<EXPRESSION>) <EXPRESSION>;
loop <EXPRESSION>;
```

### Control loops with `continue` and `break`

Keywords `continue` and `break` allow you to skip one round or break iteration.

For example let's add two conditions into `loop`. If `i` is even we use `continue` to jump to next iteration without going through code after `continue` call.
With `break` we stop iteration and exit loop.
```Move
fun main() {
    let i = 0;

    loop {
        i = i + 1;

        if (i / 2 == 0) continue;
        if (i == 5) break;

        // assume we do something here
    };

    // i here is 5
}
```

About semicolons. If `break` and `continue` are the last keywords in scope, you can't put a semicolon after them as any code after won't be executed. Somehow even semi can't be put. See this:
```Move
fun main() {
    let i = 0;

    loop {
        i = i + 1;

        if (i == 5) {
            break; // will result in compiler error. correct is `break` without semi
                   // Error: Unreachable code
        }

        // same with continue here: no semi, never;
        if (true) {
            continue
        }

        // however you can put semi like this, because continue and break here
        // are single expressions, hence they "end their own scope"
        if (true) continue;
        if (i == 5) break;
    }
}
```
