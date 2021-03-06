# 基本类型

Move 的基本数据类型包括: 整型 (u8, u64, u128)、布尔型 `boolean` 和地址 `address`。

Move 不支持字符串和浮点数。

## 整型

整型包括 `u8`、`u64` 和 `u128`，我们通过下面的例子来理解整型：

```Move
script {
    fun main() {
        // define empty variable, set value later
        let a: u8;
        a = 10;

        // define variable, set type
        let a: u64 = 10;

        // finally simple assignment
        let a = 10;

        // simple assignment with defined value type
        let a = 10u128;

        // in function calls or expressions you can use ints as constant values
        if (a < 10) {};

        // or like this, with type
        if (a < 10u8) {}; // usually you don't need to specify type
    }
}
```

### 运算符`as`

当需要比较值的大小或者当函数需要输入不同大小的整型参数时，你可以使用`as`运算符将一种整型转换成另外一种整型：

```Move
script {
    fun main() {
        let a: u8 = 10;
        let b: u64 = 100;

        // we can only compare same size integers
        if (a == (b as u8)) abort 11;
        if ((a as u64) == b) abort 11;
    }
}
```

## 布尔型

布尔类型就像编程语言那样，包含`false`和`true`两个值。

```Move
script {
    fun main() {
        // these are all the ways to do it
        let b : bool; b = true;
        let b : bool = true;
        let b = true
        let b = false; // here's an example with false
    }
}
```

## 地址

地址是区块链中交易发送者的标识符，转账和导入模块这些基本操作都离不开地址。

```Move
script {
    fun main() {
        let addr: address; // type identifier

        // in this book I'll use {{sender}} notation;
        // always replace `{{sender}}` in examples with VM specific address!!!
        addr = {{sender}};

        // in Diem's Move VM - 16-byte address in HEX
        addr = 0x...;

        // in dfinance's DVM - bech32 encoded address with `wallet1` prefix
        addr = wallet1....;
    }
}
```
