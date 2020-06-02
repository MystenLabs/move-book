# Comments

If you feel like some places in your code require additional explanation, use *comments*. Comments are non-executable blocks or lines of text aimed to describe some pieces of the code.

### Line comments

```Move
script {
    fun main() {
        // this is a comment line
    }
}
```

You can use double-slash "*//*" to write line comments. Rules are simple - **everything after** "*//*" is considered a comment to the end of line. You can use line comments to leave short notes for other developers or to *comment out* some code to remove it from the execution chain.

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

If you don't want to comment all the line contents, or if you want to comment out more than one line you can use block comments.

Block comment starts with slash-asterisk */\** and includes all the text before first asterisk-slash *\*/*. Block comment is not limited by one line and gives you power of making a note in absolutely any place in code.

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
