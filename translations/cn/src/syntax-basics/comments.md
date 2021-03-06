# 注释

需要对某些代码进行额外说明时，我们使用注释。注释是不参与执行的、旨在对相关代码进行描述和解释的文本块或文本行。

### 行注释

```Move
script {
    fun main() {
        // this is a comment line
    }
}
```

可以使用双斜杠“//”编写行注释。规则很简单，“//”之后到行尾的所有内容均视为注释。也可以使用行注释为其他开发人员留下简短消息，或者注释掉一些代码使之不参与执行。

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

### 块注释

如果不想注释整行内容，或者想要注释掉多行，则可以使用块注释。

块注释以"/\*"开头，并包含第一个"\*/"之前的所有文本。块注释不受行的限制，代码中的任何位置都可以注释。

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

当然这个例子有点荒谬！但这也清楚地显示了块注释的功能，即随时随地添加说明。
<!-- ### Documentation comments -->
