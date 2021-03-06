# 函数

Move 中代码的执行是通过调用函数实现的。函数以 fun 关键字开头，后跟函数名称、扩在括号中的参数，以及扩在花括号中的函数体。

```Move
fun function_name(arg1: u64, arg2: bool): u64 {
    // function body
}
```

我们在前面的章节中已经看到过函数，现在我们来学习如何使用函数。

> 注意：Move 函数使用snake_case命名规则，也就是小写字母以及下划线作为单词分隔符。

## 脚本中的函数

脚本块只能包含一个被视为 main 的函数。它作为交易被执行，可以有参数，但是没有返回值。它可以操作其它已经发布的模块中的函数。

这里有一个简单的例子，用来检查地址是否存在：

```Move
script {
    use 0x1::Account;

    fun main(addr: address) {
        assert(Account::exists(addr), 1);
    }
}
```

脚本中的函数可以带有参数，本例中它是 address 类型的参数 addr。函数中操作了导入的模块 Account。

> 注意：由于只有一个函数，因此你可以按任意方式对它命名。一般情况下我们遵循惯用的编程概念将其称为 main。


## 模块中的函数

脚本中能使用的函数功能是相对有限的，函数的全部潜能只有在模块中才能展现。让我们再看一遍什么是模块：模块是一组函数和结构体（我们将在下一章中介绍结构体），它可以封装一项或多项功能。

这部分内容中，我们将创建一个简单的 Math 模块，它将为用户提供一组基本的数学函数和一些辅助方法。当然这里面大部分操作无需使用模块即可完成，但我们的目标是通过这个例子来理解函数。

```Move
module Math {
    fun zero(): u8 {
        0
    }
}
```

第一步：我们定义一个 Math 模块，它有一个函数：zero()，该函数返回 u8 类型的值 0。还记得我们之前介绍过的表达式吗？0 之后没有分号，因为它是函数的返回值。是的，就像块表达式一样，函数与块非常相似。

### 函数参数

关于参数其实大家都已经很清楚了，但是我们还是稍微啰嗦一下，函数可以根据需要接受任意多个参数（传递给函数的值）。就像 Move 中的其他任何变量一样，每个参数都有两个属性：参数名，也就是参数在函数体内的名称，以及参数类型。

像作用域中定义的任何其他变量一样，函数参数仅存在于函数体内。当函数块结束时，参数也会消亡。

```Move
module Math {

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    fun zero(): u8 {
        0
    }
}
```

大家发现有什么不一样了么？Math 模块新增了 sum(a,b) 函数，该函数将两个 u64 值相加并作为 u64 结果返回。

关于参数的一些语法规则：

1. 参数必须具有类型，并且必须用逗号分隔
2. 函数返回值放在括号后，并且必须在冒号后面

下面我们如何在脚本中使用此函数呢？通过"导入"！

```Move
script {
    use 0x1::Math;  // used 0x1 here; could be your address
    use 0x1::Debug; // this one will be covered later!

    fun main(first_num: u64, second_num: u64) {

        // variables names don't have to match the function's ones
        let sum = Math::sum(first_num, second_num);

        Debug::print<u64>(&sum);
    }
}
```

### 关键字 `return`

关键字 return 允许函数结束执行并返回结果。它可以与 if 条件一起使用，这样可以根据条件返回不同结果。

```Move
module M {

    public fun conditional_return(a: u8): bool {
        if (a == 10) {
            return true // semi is not put!
        };

        if (a < 10) {
            true
        } else {
            false
        }
    }
}
```

### 多个返回值

在前面的示例中，我们尝试了没有返回值或返回单个值的函数。但是，要想返回任何类型的多个值应该怎么办呢？好的，让我们继续往下看！

要指定多个返回值，需要使用括号：

```Move
module Math {

    // ...

    public fun max(a: u8, b: u8): (u8, bool) {
        if (a > b) {
            (a, false)
        } else if (a < b) {
            (b, false)
        } else {
            (a, true)
        }
    }
}
```

该函数有两个参数：a 和 b，并返回两个值：第一个是两个输入参数中的较大的值，第二个是布尔类型，表示输入的参数是否相等。请仔细看一下语法，我们没有指定单个返回值，而是添加了括号并在其中列出了返回值类型。

现在让我们看看如何在另一个脚本中使用该函数的返回值。

```Move
script {
    use 0x1::Debug;
    use 0x1::Math;

    fun main(a: u8, b: u8)  {
        let (max, is_equal) = Math::max(99, 100);

        assert(is_equal, 1)

        Debug::print<u8>(&max);
    }
}
```
上面例子中，我们解构了一个二元组，用函数 max 的返回值创建了两个新变量。返回值的顺序保持不变，变量 max 用来存储 u8 类型的最大值，而 is_equal 用来存储 bool 类型。

返回值数量并没有限制，你可以根据需要决定元组的元素个数。下一章，我们还会介绍返回复杂数据的另一种方法，那就是结构体。

### 函数可见性

定义模块时，你可能希望其他开发人员可以访问某些函数，而某些函数则保持隐藏状态。这正是函数可见性修饰符发挥作用的时候。

默认情况下，模块中定义的每个函数都是私有的，无法在其它模块或脚本中访问。可能你已经注意到了，我们在 Math 模块中定义的某些函数前有关键字 public：

```Move
module Math {

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    fun zero(): u8 {
        0
    }
}
```

例子中Math模块被其它模块导入后，sum() 函数可以从外部访问，但是 zero() 不能被访问，因为默认情况下它是私有的。

> 关键字 public 将更改函数的默认可见性并使其公开，即可以从外部访问。

基本上，如果不将 sum() 函数设为 public，从外部访问是不可能的：

```Move
script {
    use 0x1::Math;

    fun main() {
        Math::sum(10, 100); // won't compile!
    }
}
```

### 访问私有函数

如果根本无法访问，那么私有函数就没有任何意义了。调用 public 函数的同时，可以用私有函数来执行一些内部工作。

> 私有函数只能在定义它们的模块中访问。

那么如何访问同一模块中的函数？通过像导入一样简单地调用此函数！

```Move
module Math {

    public fun is_zero(a: u8): bool {
        a == zero()
    }

    fun zero(): u8 {
        0
    }
}
```

一个模块中定义的任何函数都可以被同一模块中的任何函数访问，无论它们的可见性修饰符是什么。这样，私有函数仍然可以在内部调用，而且不会暴露某些私有操作到模块外。


### 本地方法

有一种特殊的函数叫做"本地方法"。本地方法实现的功能超出了 Move 的能力，它可以提供了额外的功能。本地方法由 VM 本身定义，并且在不同的VM实现中可能会有所不同。这意味着它们没有用 Move 语法实现，没有函数体，直接以分号结尾。关键字 native 用于标记本地函数，它和函数可见性修饰符不冲突，native 和 public 可以同时使用。

这是 Diem 标准库中的示例。

```Move
module Signer {

    native public fun borrow_address(s: &signer): &address;

    // ... some other functions ...
}
```
