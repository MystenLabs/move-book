# 表达式和作用域

在编程语言中，表达式是返回值的代码单元。具有返回值的函数调用是一个表达式，它有返回值；整数常数也是一个表达式-它具有整数类型的值，依此类推。

> 表达式必须用分号";"隔开

### 空表达式

类似于Rust，Move中的空表达式用空括号表示：
```Move
script {
    fun empty() {
        () // this is an empty expression
    }
}
```

### 文字表达式

下面的代码，每行包含一个以分号结尾的表达式。最后一行包含三个表达式，由分号隔开。
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

现在我们已经知道了最简单的表达式。但是为什么我们需要它们？以及如何使用它们？这就需要介绍let关键字了。

### 变量和`let`关键字

关键字let用来将表达式的值存储在变量中，以便于将其传递到其它地方。我们曾经在基本类型章节中使用过let，它用来创建一个新变量，该变量要么为空（未定义），要么为某表达式的值。

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

> 关键字let会在*当前作用域*内创建新变量，并可以选择*初始化*此变量。该表达式的语法是：let <VARIABLE> : <TYPE>;或let <VARIABLE> = <EXPRESSION>。

创建和初始化变量后，就可以使用变量名来*修改*或*访问*它所代表的值了。在上面的示例中，变量a在函数末尾被初始化，并被*分配*了一个值 c。

> 等号"="是赋值运算符。它将右侧表达式赋值给左侧变量。示例：a = 10 表示将整数10赋值给变量a。

### 整型运算符

Move具有多种用于修改整数值的运算符：

|  运算符   |  操作   |  类型  |                                 |
|----------|--------|-------|---------------------------------|
| +        | sum    | uint  | LHS加上RHS                       |
| -        | sub    | uint  | 从LHS减去RHS                     |
| /        | div    | uint  | 用LHS除以RHS                     |
| *        | mul    | uint  | LHS乘以RHS                       |
| %        | mod    | uint  | LHS除以RHS的余数                  |
| <<       | lshift | uint  | LHS左移RHS位                     |
| >>       | rshift | uint  | LHS右移RHS位                     |
| &        | and    | uint  | 按位与                           |
| ^        | xor    | uint  | 按位异或                          |
| \        | or     | uint  | 按位或                           |

*LHS - 左侧表达式, RHS - 右侧表达式; uint: u8, u64, u128.*

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

### 下划线 "_" 表示未被使用

Move中每个变量都必须被使用，否则代码编译不会通过, 因此我们不能初始化一个变量却不去使用它。 但是你可以用下划线来告诉编译器，这个变量是故意不被使用的。

例如，下面的脚本在编译时会报错：

```Move
script {
    fun main() {
        let a = 1;
    }
}
```

报错:
```

    ┌── /scripts/script.move:3:13 ───
    │
 33 │         let a = 1;
    │             ^ Unused assignment or binding for local 'a'. Consider removing or replacing it with '_'
    │
```

编译器给出明确提示：用下划线来代替变量名。

```Move
script {
    fun main() {
        let _ = 1;
    }
}
```

### 屏蔽

Move允许两次定义同一个的变量，第一个变量将会被屏蔽。但有一个要求——我们仍然需要使用被屏蔽的变量。

```Move
script {
    fun main() {
        let a = 1;
        let a = 2;
        let _ = a;
    }
}
```
在上面的示例中，我们仅使用了第二个a。第一个a实际上未使用，因为a在下一行被重新定义了。所以，我们可以通过下面的修改使得这段代码正常运行。

```Move
script {
    fun main() {
        let a = 1;
        let a = a + 2;
        let _ = a;
    }
}
```

## 块表达式

块表达式用花括号"*{}*"表示。块可以包含其它表达式（和其它块）。函数体在某种意义上也是一个块。

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

### 作用域

如[Wikipedia](https://en.wikipedia.org/wiki/Scope_(computer_science) )中所述，作用域是绑定生效的代码区域。换句话说，变量存在于作用域中。Move作用域是由花括号扩起来的代码块，它本质上是一个块。

> 定义一个块，实际上是定义一个作用域。

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

从该示例可以看出，作用域是由块（或函数）定义的。它们可以嵌套，并且可以定义多少个，数量没有限制。

### 变量的生命周期和可见性

我们前面已经介绍过关键字let的作用，它可以用来定义变量。有一点需要强调的是，该变量仅存在于变量所处的作用域内。也就是说，它在作用域之外不可访问，并在作用域结束后立即消亡。


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

    } // function scope ended - a, b and c are dropped and no longer accessible
}
```

> 变量仅存在于其作用域（或块）内，当作用域结束时变量随之消亡。

### 块返回值

上面我们了解到块是一个表达式，但是我们没有介绍为什么它是一个表达式以及块的返回值是什么。

>块可以返回一个值，如果它后面没有分号，则返回值为块内最后一个表达式的值。

听起来不好理解，我们来看下面的例子：

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

> 块中的最后一个表达式（不带分号）是该块的返回值。

### 小结

我们来总结一下本章要点：

1. 每个表达式都必须以分号结尾，除非它是block的返回值。
2. 关键字let使用值或表达式创建新变量，该变量的生命周期与其作用域相同。
3. 块是一个可能具有也可能没有返回值的表达式。

下一章我们将介绍控制流和分支语句。

### 进一步阅读

- [Diem Community thread on empty expressions and semicolon](https://community.diem.com/t/odd-error-when-semi-is-put-after-break-or-continue/2868)
