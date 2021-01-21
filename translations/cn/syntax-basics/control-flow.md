# 控制流

通过控制流表达式，我们可以选择运行某个代码块，或者跳过某块代码而运行另一代码块。

Move支持if表达式和循环表达式。

<!-- In Move you have two statme to control flow: by using loops (`while` and `loop`) or `if` expressions. -->

## `if` 表达式

if 表达式允许我们在条件为真时运行代码块，在条件为假时运行另一个代码块。

```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        if (a) {
            Debug::print<u8>(&0);
        } else {
            Debug::print<u8>(&99);
        };
    }
}
```

这个例子中，当`a == true`时打印`0`，当a是`false`时打印`99`，语法非常简单：
```
if (<布尔表达式>) <表达式> else <表达式>;
```

if是一个表达式，我们可以在let声明中使用它。但是像所有其他表达式一样，它必须以分号结尾。

```Move
script {
    use 0x1::Debug;

    fun main() {

        // try switching to false
        let a = true;
        let b = if (a) { // 1st branch
            10
        } else { // 2nd branch
            20
        };

        Debug::print<u8>(&b);
    }
}
```

现在，b将根据a表达式为变量分配不同的值。但是if的两个分支必须返回相同的类型！否则，变量b将会具有不同种类型，这在静态类型的语言中是不允许的。在编译器术语中，这称为分支兼容性 —— 两个分支必须返回兼容（相同）类型。

if不一定非要和else一起使用，也可以单独使用。


```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        // only one optional branch
        // if a = false, debug won't be called
        if (a) {
            Debug::print<u8>(&10);
        };
    }
}
```

但是请记住，不能在let赋值语句中使用不带分支的表达式！因为如果if不满足条件，就会导致变量未被定义，这同样是不允许的。

## 循环表达式

在Move中定义循环有两种方法：

1. `while`条件循环
2. `loop`无限循环

### `while`条件循环

while是定义循环的一种方法：在条件为真时执行表达式。只要条件为`true`，代码将一遍又一遍的执行。条件通常使用外部变量或计数器实现。

```Move
script {
    fun main() {

        let i = 0; // define counter

        // iterate while i < 5
        // on every iteration increase i
        // when i is 5, condition fails and loop exits
        while (i < 5) {
            i = i + 1;
        };
    }
}
```

需要指出的是，`while`表达式就像`if`表达式一样，也需要使用分号结束。while循环的通用语法是：

```Move
while (<布尔表达式>) <表达式>;
```

与`if`表达式不同的是，`while`表达式没有返回值，因而也就不能像`if`那样把自己赋值给某变量。

### 无法访问的代码

安全是Move最显著的特性。出于安全考虑，Move规定所有变量必须被使用。并且出于同样的原因，Move禁止使用无法访问的代码。由于数字资产是可编程的，因此可以在代码中使用它们（我们将在Resource一章中对其进行介绍）。而将资产放置在无法访问的代码中可能会带来问题，并造成损失。

这就是为什么无法访问的代码如此重要的原因。


### 无限循环

Move提供了一种定义无限循环的方法，它没有条件判断，会一直执行。一旦执行该代码将消耗所有给定资源（gas），在大多数情况下，编译器也无法判断循环是否是无限的，也就无法阻止无限循环代码的发布。因此，使用无限循环时一定要注意安全，通常情况下建议使用`while`条件循环。

无限循环用关键字`loop`定义。

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;
        };

        // UNREACHABLE CODE
        let _ = i;
    }
}
```

下面的代码也是可以编译通过的:

```Move
script {
    fun main() {
        let i = 0;

        loop {
            if (i == 1) { // i never changed
                break // this statement breaks loop
            }
        };

        // actually unreachable
        0x1::Debug::print<u8>(&i);
    }
}
```

对于编译器而言，要了解循环是否真的是无限的，这是一项艰巨的任务，因此，就目前而言，只有开发者自己可以帮助自己发现循环错误，避免资产损失。

### 通过 `continue` 和 `break` 控制循环

`continue`和`break`关键字，分别允许程序跳过一轮或中断循环，可以在两种类型的循环中同时使用它们。

例如，让我们在`loop`中添加两个条件，如果i是偶数，我们通过`continue`跳转到下一个迭代，而无需执行循环中`continue`之后的代码。当i等于5时，我们通过break停止迭代并退出循环。

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i / 2 == 0) continue;
            if (i == 5) break;

            // assume we do something here
         };

        0x1::Debug::print<u8>(&i);
    }
}
```

注意，如果break和continue是块中的最后一个关键字，则不能在其后加分号，因为后面的任何代码都不会被执行。请看这个例子：

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i == 5) {
                break; // will result in compiler error. correct is `break` without semi
                       // Error: Unreachable code
            };

            // same with continue here: no semi, never;
            if (true) {
                continue
            };

            // however you can put semi like this, because continue and break here
            // are single expressions, hence they "end their own scope"
            if (true) continue;
            if (i == 5) break;
        }
    }
}
```

### 有条件退出 `abort`

有时，当某些条件失败时，您需要中止程序的执行。对于这种情况，Move提供了有键字abort。

```Move
script {
    fun main(a: u8) {

        if (a != 10) {
            abort 0;
        }

        // code here won't be executed if a != 10
        // transaction aborted
    }
}
```

关键字abort允许程序中止执行的同时报告错误代码。

### 使用 `assert` 内置方法

内置方法 `assert(<condition>, <code>)` 对 `abort`和条件进行了封装，你可以在代码中任何地方使用它。

```Move
script {

    fun main(a: u8) {
        assert(a == 10, 0);

        // code here will be executed if (a == 10)
    }
}
```

`assert()` 在不满足条件时将中止执行，在满足条件时将不执行任何操作。
