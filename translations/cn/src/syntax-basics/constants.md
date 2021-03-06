# 常量

Move 支持`模块`或`脚本`级常量。常量一旦定义，就无法更改，所以可以使用常量为特定模块或脚本定义一些不变量，例如角色、标识符等。

常量可以定义为基本类型（比如整数，布尔值和地址），也可以定义为数组。我们可以通过名称访问常量，但是要注意，常量对于定义它们的脚本或模块来说是本地可见的。

> 我们无法从模块外部访问模块内部定义的常量

```Move
script {

    use 0x1::Debug;

    const RECEIVER : address = 0x999;

    fun main(account: &signer) {
        Debug::print<address>(&RECEIVER);

        // they can also be assigned to a variable

        let _ = RECEIVER;

        // but this code leads to compile error
        // RECEIVER = 0x800;
    }
}
```

一些用法:

```Move
module M {

    const MAX : u64 = 100;

    // however you can pass constant outside using a function
    public fun get_max(): u64 {
        MAX
    }

    // or using
    public fun is_max(num: u64): bool {
        num == MAX
    }
}
```

使用常量时应该注意:

1. 一旦定义，常量是不可更改的。
2. 常量在模块或脚本中是本地可见的，不能在外部使用。
3. 可以将常量定义为一个表达式（带有花括号），但是此表达式的语法非常有限。

### 进一步阅读

- [常量的实现](https://github.com/diem/diem/pull/4653)
