# Comments

If you feel like some parts of your code require additional explanation, use *comments*. Comments are non-executable blocks or lines of text used to comment or leave notes for your code.

### Line comments

```Move
script {
    fun main() {
        // this is a comment line
    }
}
```

You can use double-slash "*//*" to write line comments. Rules are simple - **everything after** "*//*" (and before the new line) is considered a comment to the end of line. You can use line comments to leave short notes for other developers or to *comment out* some code to remove it from the execution chain.

```Move
script {
    // let's add a note to everything!
    fun main() {
        let a = 10;
        // let b = 10 this line is commented and won't be executed
        let b = 5; // here comment is placed after code
        a + b // result is 15, not 10!
    }
}
```

### Block comments

If you don't want to comment all of the line contents, or if you want to comment out more than one line you can use block comments.

Block comment starts with slash-asterisk */\** and includes all the text before first asterisk-slash *\*/*. Block comment is not limited by one line and gives you the power of making a note absolutely anywhere.

```Move
script {
    fun /* you can comment everywhere */ main() {
        /* here
           there
           everywhere */ let a = 10;
        let b = /* even here */ 10; /* and again */
        a + b
    }
    /* you can use it to remove certain expressions or definitions
    fun empty_commented_out() {

    }
    */
}
```

Of course this example is ridiculous! But it clearly shows the power of block comment. Feel free to comment anywhere!

### Documentation comments

There's also a way to document functions and module members to be later picked up and used in extensions and documentation generators. A doc comment is marked with a triple-slash "*///*", however, they should only be placed on top-level definitions (like module, function, constant and struct), leaving a doc comment elsewhere would emit a compiler warning.

```Move
script {
    /// A constant marking the 0x0 address
    const STD_ADDRESS: address = 0x0;

    /// This is the main function of the script
    fun main() {

    }
}
```

### More resources

- [Comments section in the Move Documentation](https://move-language.github.io/move/coding-conventions.html?highlight=comment#comments)
