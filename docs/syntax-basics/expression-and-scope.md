# Expression and Scope

In programming languages an expression is a unit of code which returns a value. A function call with a return value is an expression - it returns value; an integer (or bool or address) literal is also an expression - it has the value of its integer type and so on.

> Expressions must be sequenced (separated) by a semicolon*

*\* When you put a semicolon, 'internally' it's treated as `; (empty_expression)`. If you put any expression after semi, it will replace the empty one.*

### Empty expression

You probably will never use it directly but an empty expression in Move (in this way it's similar to Rust) is marked with empty parentheses:

```Move
script {
    fun empty() {
        () // this is an empty expression
    }
}
```

An empty expression can be omitted as it's automatically inserted by the VM.

### Literal expressions

Look at the code below. Every line contains an expression which ends with a semicolon. Last line has three expressions separated by semicolons.

```Move
script {
    fun main() {
        10;
        10 + 5;
        true;
        true != false;
        0x1;
        1; 2; 3
    }
}
```

Good. You now know the simplest expressions there are. But why do we need them? And how to use it? It's time to know the `let` keyword.

### Variables and `let` keyword

To store the expression value inside a variable (to pass it somewhere or structure code better) you have the `let` keyword (you've already seen it in the [primitives chapter](/syntax-basics/primitives.md)). It creates a new variable either empty (not yet defined) or with value of the assigned expression.

```Move
script {
    fun main() {
        let a;
        let b = true;
        let c = 10;
        let d = 0x1;
        a = c;
    }
}
```

> Keyword `let` creates a new variable inside the *current scope* and optionally *initializes* this variable with a value. Syntax for the expression is: `let <VARIABLE> : <TYPE>;` or `let <VARIABLE> = <EXPRESSION>`.

After you've created and initialized variable you're able to *modify* or *access* its value by using a variable name. In example above variable `a` was initialized in the end of function and was *assigned* a value of variable `c`.

> Equality sign `=` is an assignment operator. It assigns right-hand-side expression to the left-hand-side variable. Example: `a = 10` - variable `a` is assigned an integer value of `10`.

### Operators for integer types

Move has a variety of operators to modify integer values. Here's a list:

| Operator | Op     | Types |                                 |
|----------|--------|-------|---------------------------------|
| +        | sum    | uint  | Sum LHS and RHS                 |
| -        | sub    | uint  | Subtract RHS from LHS           |
| /        | div    | uint  | Divide LHS by RHS               |
| *        | mul    | uint  | Multiply LHS times RHS          |
| %        | mod    | uint  | Division remainder (LHS by RHS) |
| <<       | lshift | uint  | Left bit shift LHS by RHS       |
| >>       | rshift | uint  | Right bit shift LHS by RHS      |
| &        | and    | uint  | Bitwise AND                     |
| ^        | xor    | uint  | Bitwise XOR                     |
| \|       | or     | uint  | Bitwise OR                      |

*LHS - left-hand-side expression, RHS - right-hand-side expression; uint: u8, u64, u128.*

<!--

### Comparison and boolean operators

To build a bool condition by comparing values you have these operators. All of them return `bool` value and require LHS and RHS types match.

| Operator | Op     | Types |                                |
|----------|--------|-------|--------------------------------|
| ==       | equal  | any   | Check if LHS equals RHS        |
|----------|--------|-------|--------------------------------|
| =<       | equal  | any   | Check if LHS equals RHS        |
|----------|--------|-------|--------------------------------|

-->

### Underscore "_" to mark unused

In Move every variable must be used (otherwise your code won't compile), hence you can't initialize one and leave it untouched. Though you have one way to mark variable as *intentionally unused* - by using underscore `_`.

You'll get an error if you try to compile this script:

```Move
script {
    fun main() {
        let a = 1;
    }
}
```

The error:
```

    ┌── /scripts/script.move:3:13 ───
    │
 33 │         let a = 1;
    │             ^ Unused assignment or binding for local 'a'. Consider removing or replacing it with '_'
    │
```

Compiler message is pretty clear, so all you have to do in this case is put an underscore (or prefix with an underscore):

```Move
script {
    fun main() {
        let _a = 1;
    }
}
```

### Shadowing

Move allows you to define the same variable twice with one limitation - it still needs to be used. In the example above only second `a` is used. The first one: `let a = 1` is actually unused as on the next line we *redefine* `a` while leaving the first one unused.

```Move
script {
    fun main() {
        let a = 1;
        let a = 2;
        let _ = a;
    }
}
```

Though we still can make it work by using first one:

```Move
script {
    fun main() {
        let a = 1;
        let a = a + 2; // let here is unnecessary
        let _ = a;
    }
}
```

## Block expression

A block is an expression; it's marked with *curly braces* - `{}`. Block can contain other expressions (and other blocks). Function body (as you can see by already familiar curly-braces) is also a block in some sense (with a few limitations).

```Move
script {
    fun block() {
        { };
        { { }; };
        true;
        {
            true;

            { 10; };
        };
        { { { 10; }; }; };
    }
}
```

### Understanding scopes

Scope (as it's said in [Wikipedia](https://en.wikipedia.org/wiki/Scope_(computer_science))) is a region of code where a binding is valid. In other words - it's a part of code in which a variable exists. In Move - a scope is a block of code surrounded by curly braces.

> When defining a block you create a new scope.

```Move
script {
    fun scope_sample() {
        // this is a function scope
        {
            // this is a block scope inside function scope
            {
                // and this is a scope inside scope
                // inside functions scope... etc
            };
        };

        {
            // this is another block inside the function scope
        };
    }
}
```

As you can see from comments in this sample, scopes are defined by blocks (or functions), they can be nested and there's no limit to how many scopes you can define.

### Variable lifetime and visibility

Keyword `let` creates a variable - you already know that. Though you probably don't know that the defined variable will live only inside the scope where it is defined (hence inside nested scopes); simply put - it's unaccessible outside its scope and dies right after this scope's end.

```Move
script {
    fun let_scope_sample() {
        let a = 1; // we've defined variable A inside function scope

        {
            let b = 2; // variable B is inside block scope

            {
                // variables A and B are accessible inside
                // nested scopes
                let c = a + b;

            }; // in here C dies

            // we can't write this line
            // let d = c + b;
            // as variable C died with its scope

            // but we can define another C
            let c = b - 1;

        }; // variable B dies, so does C

        // this is impossible
        // let d = b + c;

        // we can define any variables we want
        // no name reservation happened
        let b = a + 1;
        let c = b + 1;

    } // function scope ended - a, b and c are dropped and no longer accessible
}
```

> Variable only lives only within scope (or block) where it's defined. When its scope ends, the variable dies.

### Block return values

In the previous part you've learned that a block is an expression but we didn't cover why it is an expression and what is the block's return value.

> Block can return a value, it's the value of the last expression inside this block if it's not followed by a semicolon

May sound hard, so I'll give you a few examples:

```Move
script {
    fun block_ret_sample() {

        // since block is an expression, we can
        // assign it's value to variable with let
        let a = {

            let c = 10;

            c * 1000  // no semicolon!
        }; // scope ended, variable a got value 10000

        let b = {
            a * 1000  // no semi!
        };

        // variable b got value 10000000

        {
            10; // see semi!
        }; // this block does not return a value

        let _ = a + b; // both a and b get their values from blocks
    }
}
```

> The last expression in scope (without semicolon) is the return value of this scope.

### Summary

Let's summarize the main points of this chapter.

1. Every expression must end with semicolon unless it's the return value of block;
2. Keyword `let` creates new variable with value or right-hand-side expression which lives as long as the scope in which it's been created;
3. Block is an expression that may or may not have return value.

How to control execution flow and how to use blocks for logic switches - on the next page.

### Further reading

- [Local Variables and Scope in the Move Documentation](https://move-language.github.io/move/variables.html)
