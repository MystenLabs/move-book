# Control flow

In terms of control operators Move's syntax is similar to Rust with some differences which I'll highlight.

Let's start with one simple rule:

> Every expression MUST end with semicolon unless it's the last expression in scope

Which means that every `loop`, every `while` and `if` expressions - all of them MUST have semicolon at the end if any expression goes after. Not having semicolon (like in Rust) will result in syntax error.

## The `if` expression

If you want to run code block when some expression is `true` you need to use `if` keyword:

```Move
// assume it's a script
use 0x0::Transaction;

fun main(custom_addr: address) {
    if (custom_addr !== Transaction::sender()) {
        abort 11
    };

    // alternatively
    if (custom_addr !== Transaction::sender()) abort 11
}
```

Syntax (take a good look at semicolon positions):

```Move
if (<EXPRESSION>) <EXPRESSION>;
if (<EXPRESSION>) {
    <EXPRESSION>
};
```

### Let's add `else` to our `if`s!

You can (and sometimes must) add `else` to your `if` construction:
```Move
// assume it's a script
use 0x0::Transaction;

fun main(custom_addr: address) {
    if (custom_addr !== Transaction::sender()) {
        abort 11
    } else {
        let _ = true
    };

    // alternatively
    if (custom_addr !== Transaction::sender()) abort 11 else {
        let _ = true
    };
}
```

Syntax (again - mind semicolons):
```Move
if (<EXPRESSION>) <EXPRESSION> else <EXPRESSION>;
if (<EXPRESSION>) { <EXPRESSION> } else <EXPRESSION>;
if (<EXPRESSION>) { <EXPRESSION> } else { <EXPRESSION> };
```

## Using loops

In Move you have two ways to do repetition: conditional loop with `while` and infinite `loop`.

```Move
fun main() {
    let i = 0;

    loop {
        if (i < 5) {
            i = i + 1;
            continue
        } else {
            break
        }
    }
}
```
