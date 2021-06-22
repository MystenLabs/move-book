# Abilities

Move 的类型系统非常灵活，每种类型都可以被四种限制符所修饰。这四种限制符我们称之为 abilities，它们定义了类型的值是否可以被复制、丢弃和存储。

> 这四种 abilities 限制符分别是: Copy, Drop, Store 和 Key.

它们的功能分别是：

- **Copy** - 被修饰的值可以被*复制*。 
- **Drop** - 被修饰的值在作用域结束时可以被*丢弃*。
- **Key** - 被修饰的值可以作为*键值*对全局状态进行访问。
- **Store** - 被修饰的值可以被*存储*到全局状态。

本章我们先介绍 `Copy` 和 `Drop` ability；关于 `Key` 和 `Store` ability 我们将会在 *Resources* 一章介绍. 

### Abilities 语法

> 基本类型和内建类型的 abilities 是预先定义好的并且不可改变: integers, vector, addresses 和 boolean 类型的值先天具有 *copy*，*drop* 和 *store* ability。

然而，结构体的 ability 可以由开发者按照下面的语法进行添加：

```Move
struct NAME has ABILITY [, ABILITY] { [FIELDS] }
```

下面是一些例子:

```Move
module Library {
    
    // each ability has matching keyword
    // multiple abilities are listed with comma
    struct Book has store, copy, drop {
        year: u64
    }

    // single ability is also possible
    struct Storage has key {
        books: vector<Book>
    }

    // this one has no abilities 
    struct Empty {}
}
```

### 不带 Abilities 限制符的结构体

在进入 abilities 的具体用法之前, 我们不妨先来看一下，如果结构体不带任何 abilities 会发生什么？

```Move
module Country {
    struct Country {
        id: u8,
        population: u64
    }
    
    public fun new_country(id: u8, population: u64): Country {
        Country { id, population }
    }
}
```

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000);
    }   
}
```

运行上面的代码会报如下错误：
```
error: 
   ┌── scripts/main.move:5:9 ───
   │
 5 │     Country::new_country(1, 1000000);
   │     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

方法 `Country::new_country()` 创建了一个值，这个值没有被传递到任何其它地方，所以它应该在函数结束时被丢弃。但是 Country 类型没有 *Drop* ability，所以运行时报错了。现在让我们加上 *Drop* 限制符试试看。

### Drop

按照 abilities 语法我们为这个结构体增加 `drop` ability，这个结构体的所有实例将可以被丢弃。 

```Move
module Country {
    struct Country has drop { // has <ability>
        id: u8,
        population: u64
    }
    // ...
}
```

现在，`Country` 可以被丢弃了，代码也可以成功执行了。

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000); // value is dropped
    }   
}
```

> **注意** [*Destructuring*](/advanced-topics/struct.html#destructing-structures) 并不需要 Drop ability.

### Copy

我们学习了如何创建一个结构体 `Country` 并在函数结束时丢弃它。但是如果我们想要复制一个结构体呢？缺省情况下结构体是按值传递的，制造一个结构体的副本需要借助关键字 `copy` (我们会在 [下一章](/advanced-topics/ownership-and-references.html) 更加深入的学习)：

```Move
script {
    use {{sender}}::Country;

    fun main() {
        let country = Country::new_country(1, 1000000);
        let _ = copy country;
    }   
}
```

```
   ┌── scripts/main.move:6:17 ───
   │
 6 │         let _ = copy country;
   │                 ^^^^^^^^^^^^ Invalid 'copy' of owned value without the 'copy' ability
   │
```

正如所料，缺少 `copy` ability 限制符的类型在进行复制时会报错：

```Move
module Country {
    struct Country has drop, copy { // see comma here!
        id: u8,
        population: u64
    }
    // ...
}
```

修改后的代码就可以成功执行了。

### 小结

- 基本类型缺省具有 store, copy 和 drop 限制。
- 缺省情况下结构体不带任何限制符。
- Copy 和 Drop 限制符定义了一个值是否可以被复制和丢弃。
- 一个结构体有可能带有所有4种限制符。

### 进一步阅读

- [Move Abilities 描述](https://github.com/diem/diem/blob/main/language/changes/3-abilities.md)
