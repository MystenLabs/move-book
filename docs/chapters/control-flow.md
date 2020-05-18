# Control Flow

In terms of control operators Move's syntax is similar to Rust with some differences which I'll highlight.

## The `if` expression

If you want to run code block when some expression is `true` you need to use `if` keyword:

```Move
script {
    use 0x0::Transaction;

    fun main(custom_addr: address) {
        if (custom_addr != Transaction::sender()) {
            abort 11
        };

        // alternatively
        if (custom_addr != Transaction::sender()) abort 11
    }
}
```

Syntax:

```Move
if (<EXPRESSION>) <EXPRESSION>;
```

### Let's add `else` to our `if`s!

You can (and sometimes must) add `else` to your `if` construction:
```Move
script {
    use 0x0::Transaction;

    fun main(custom_addr: address) {
        if (custom_addr != Transaction::sender()) {
            abort 11
        } else {
            let _ = true
        };

        // alternatively
        if (custom_addr != Transaction::sender()) abort 11 else {
            let _ = true
        };
    }
}
```

Syntax with `else`:
```Move
if (<EXPRESSION>)
    <EXPRESSION>
else
    <EXPRESSION>;
```

## Using loops

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
