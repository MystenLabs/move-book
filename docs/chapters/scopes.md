# Understanding Scopes

Scope (as it's said in [Wikipedia](https://en.wikipedia.org/wiki/Scope_(computer_science))) is a region of code where binding is valid. In other words - it's a code block in which variable exist. In Move scope is a block of code surrounded by curly braces - basically a block, as mentioned in previous chapter.

> When defining a block you actually define a scope.

Let's jump straight to samples!

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
            // this is another block inside function scope
        };
    }
}
```

As you can see by comments in this sample, scopes are defined by blocks, they can be nested and there's no limit to how many scopes you can define.

### Variable lifetime and visibility

Keyword let creates a variable - you already know that. Though you probably don't know that defined variable will live only inside the scope where it's defined (hence inside nested scopes); simply put - it's unaccessible outside its scope and dies right after this scope's end.

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

        }; // variable C dies, so does C

        // this is impossible
        // let d = b + c;

        // we can define any variables we want
        // no name reservation happened
        let b = a + 1;
        let c = b + 1;

    } // function scope ended - no A, B and C are dead
}
```

> Variable lives only within scope (or block) where it's defined. When its scope ends, variable dies.

### Block return values

In previous part you've learned that block is an expression but we didn't cover why it is an expression and what is block's return value.

> Block can return a value, it's the value of the last expression inside this block if it's not followed by semicolon

May sound hard, so I'll give you few examples:

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
    }
}
```
