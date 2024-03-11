# 模块

模块是发布在特定地址下的打包在一起的一组函数和结构体。前几章里，我们已经使用了脚本，脚本需要与已发布的模块或标准库一起运行，而标准库本身就是在 0x1 地址下发布的一组模块。

> 模块在发布者的地址下发布。标准库在 0x1 地址下发布。

> 发布模块时，不会执行任何函数。要使用模块就得使用脚本。

模块以`module`关键字开头，后面跟随模块名称和大括号，大括号中放置模块内容。

```Move
module Math {

    // module contents

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
```

> 模块是发布代码供他人访问的唯一方法。新的类型和 Resource 也只能在模块中定义。

默认情况下，模块将在发布者的地址下进行编译和发布。但如果只是测试或开发，或者想要在模块中指定地址，请使用以下address <ADDR> {}语法：

```Move
address 0x1 {
module Math {
    // module contents

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
}
```
*如示例所示：最佳实践是保持模块行不缩进*

## 导入

Move 在默认上下文中只能使用基本类型，也就是整型、布尔型和地址，可以执行的有意义或有用的操作也就是操作这些基本类型，或者基于基本类型定义新的类型。

除此之外还可以导入已发布的模块（或标准库）。

### 直接导入

可以直接在代码中按其地址使用模块：

```Move
script {
    fun main(a: u8) {
        0x1::Debug::print(&a);
    }
}
```

在此示例中，我们从地址0x1（标准库）导入了 Debug 模块，并使用了它的 print 方法。

### 关键字 use

要使代码更简洁（注意，0x1 是特殊的地址，实际地址是很长的），可以使用关键字use：

```Move
use <Address>::<ModuleName>;
```

这里 `<Address>` 是模块发布者的地址，`<ModuleName>` 是模块的名字。非常简单，例如，我们可以像下面这样从 `0x1` 地址导入 `Vector` 模块。

```Move
use 0x1::Vector;
```

### 访问模块的内容

要访问导入的模块的方法（或类型），需要使用::符号。非常简单，模块中定义的所有公开成员都可以通过双冒号进行访问。

```Move
script {
    use 0x1::Vector;

    fun main() {
        // here we use method empty() of module Vector
        // the same way we'd access any other method of any other module
        let _ = Vector::empty<u64>();
    }
}
```

### 在脚本中导入

在脚本中，模块导入必须放在 `script {}` 块内：

```Move
script {
    use 0x1::Vector;

    // in just the same way you can import any
    // other module(s). as many as you want!

    fun main() {
        let _ = Vector::empty<u64>();
    }
}
```

### 在模块中导入

在模块中导入模块必须在 `module {}` 块内进行:

```Move
module Math {
    use 0x1::Vector;

    // the same way as in scripts
    // you are free to import any number of modules

    public fun empty_vec(): vector<u64> {
        Vector::empty<u64>();
    }
}
```

### 成员导入

导入语句还可以进一步被扩展，可以直接导入模块的成员:

```Move
script {
    // single member import
    use 0x1::Signer::address_of;

    // multi member import (mind braces)
    use 0x1::Vector::{
        empty,
        push_back
    };

    fun main(acc: &signer) {
        // use functions without module access
        let vec = empty<u8>();
        push_back(&mut vec, 10);

        // same here
        let _ = address_of(acc);
    }
}
```

### 使用 `Self` 来同时导入模块和模块成员

导入语句还可以进一步扩展，通过使用 `Self` 来同时导入模块和模块成员，这里 `Self` 代表模块自己。

```Move
script {
    use 0x1::Vector::{
        Self, // Self == Imported module
        empty
    };

    fun main() {
        // `empty` imported as `empty`
        let vec = empty<u8>();

        // Self means Vector
        Vector::push_back(&mut vec, 10);
    }
}
```

### 使用 use as

当两个或多个模块具有相同的名称时，可以使用关键字as更改导入的模块的名称，这样可以在解决命名冲突的同时缩短代码长度。

语法：

```Move
use <Address>::<ModuleName> as <Alias>;
```

在脚本中：

```Move
script {
    use 0x1::Vector as V; // V now means Vector

    fun main() {
        V::empty<u64>();
    }
}
```

在模块中：

```Move
module Math {
    use 0x1::Vector as Vec;

    fun length(&v: vector<u8>): u64 {
        Vec::length(&v)
    }
}
```

脚本中的例子：

```Move
script {
    use 0x1::Vector::{
        Self as V,
        empty as empty_vec
    };

    fun main() {
        // `empty` imported as `empty_vec`
        let vec = empty_vec<u8>();

        // Self as V = Vector
        V::push_back(&mut vec, 10);
    }
}
```
