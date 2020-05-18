# Expression

In programming languages expressions is a unit of code which returns a value. A function call with return value is an expression - it returns value, an integer (or bool or address) literal is an expression - it has the value of its integer type and so on.

> Every expression in Move MUST end with semicolon*

### Literal expressions

Look at the code below. Every line contains an expression which ends with semicolon. Last line has three expressions separated by semicolons.

```Move
script {
    fun expr_samples() {
        10;
        10 + 5;
        true;
        true != false;
        0x0;
        1; 2; 3;
    }
}
```

Good. You now know the simplest expressions there are. But why do we need them? And how to use? It's time to know `let` keyword.

### Variables and `let` keyword

To store expression value inside variable (to pass it somewhere) you have keyword `let` (you've already seen it in [primitives chapter](/chapters/primitives.md), remember?). It creates a new variable either empty (undefined) or with value of expression. Let's see some code:

```Move
script {
    fun let_kwd() {
        let a;
        let b = true;
        let c = 10;
        let d = 0x0;
        a = c;
    }
}
```

> Keword `let` creates new variable inside *current scope* and optionally *initializes* this variable with value. Syntax for this expression is: `let <VARIABLE>;` or `let <VARIABLE> = <EXPRESSION>`.

After you've created and initialized variable you're able to *modify* or *access* its value by using variable name. In example above variable `a` was initialized in the end of function and was *assigned* a value of variable `c`.

> Equality sign `=` is an assignment operator. It assigns right-hand-side expression to left-hand-side variable. Example: `a = 10` - variable `a` is assigned an integer value of `10`.

## Block expression

A block is an expression - it's marked with *curly braces* - `{}`. It can contain other expressions (and other blocks). Function body (as you can see by already familiar curly-braces) is also a block in some sence (with few limitations).

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
