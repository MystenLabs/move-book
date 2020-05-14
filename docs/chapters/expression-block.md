# Expression

In programming languages expressions is a unit of code which returns a value. A function call with return value is an expression - it returns value, an integer literal is an expression - it has the value of this integer and so on.

### Simple expressions

Look at the code below. What do you see? What is an expression from the definition and what is not?

```Move
fun main(): u8 {
    let a = 10;
    let b;
    b = a;
    (a + b)
}
```

Remember keyword `let` from [primitives chapter](/chapters/primitives.md)? It creates new variable and assigns it a value of expression which has to be put right after equality (or *assignment*) sign.

In this example `10` is an expression (an integer literal) which returns 10. Variable `a` was created and assigned a value - 10. Variable `b` however did not get value and was only defined in `let` statement.

Going further.


