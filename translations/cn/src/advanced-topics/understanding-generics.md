# 了解泛型

泛型对于 Move 语言是必不可少的，它使得 Move 语言在区块链世界中如此独特，它是 Move 灵活性的重要来源。

首先，让我来引用 [Rust Book](https://doc.rust-lang.org/stable/book/ch10-00-generics.html) 对于泛型得定义：*泛型是具体类型或其他属性的抽象替代品*。实际上，泛型允许我们只编写单个函数，而该函数可以应用于任何类型。这种函数也被称为模板 —— 一个可以应用于任何类型的模板处理程序。

Move 中泛型可以应用于结构体和函数的定义中。

### 结构体中的泛型

首先，我们将创建一个可容纳`u64`整型的 Box ：

```Move
module Storage {
    struct Box {
        value: u64
    }
}
```
这个 Box 只能包含`u64`类型的值，这一点是非常清楚的。但是，如果我们想为`u8`类型或 bool类型创建相同的 Box 该怎么办呢？分别创建`u8`类型的 Box1 和`bool`型 Box2 吗？答案是否定的，因为可以使用泛型。

```Move
module Storage {
    struct Box<T> {
        value: T
    }
}
```

我们在结构体名字的后面增加`<T>`。尖括号`<..>`里面用来定义泛型，这里`T`就是我们在结构体中模板化的类型。在结构体中，我们已经将`T`用作常规类型。类型T实际并不存在，它只是任何类型的占位符。

### 函数中的泛型

现在让我们为上面的结构体创建一个构造函数，该构造函数将首先使用u64类型。


```Move
module Storage {
    struct Box<T> {
        value: T
    }

    // type u64 is put into angle brackets meaning
    // that we're using Box with type u64
    public fun create_box(value: u64): Box<u64> {
        Box<u64>{ value }
    }
}
```

带有泛型的结构体的创建稍微有些复杂，因为它们需要指定类型参数，需要把常规结构体 Box 变为 Box<u64>。Move没有任何限制什么类型可以被放进尖括号中。但是为了让`create_box`方法更通用，有没有更简单的方法？有的，在函数中使用泛型！

```Move
module Storage {
    // ...
    public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }

    // we'll get to this a bit later, trust me
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }
}
```

### 函数调用中使用泛型

上例中在定义函数时，我们像结构体一样在函数名之后添加了尖括号。如何使用它呢？就是在函数调用中指定类型。

```Move
script {
    use {{sender}}::Storage;
    use 0x1::Debug;

    fun main() {
        // value will be of type Storage::Box<bool>
        let bool_box = Storage::create_box<bool>(true);
        let bool_val = Storage::value(&bool_box);

        assert(bool_val, 0);

        // we can do the same with integer
        let u64_box = Storage::create_box<u64>(1000000);
        let _ = Storage::value(&u64_box);

        // let's do the same with another box!
        let u64_box_in_box = Storage::create_box<Storage::Box<u64>>(u64_box);

        // accessing value of this box in box will be tricky :)
        // Box<u64> is a type and Box<Box<u64>> is also a type
        let value: u64 = Storage::value<u64>(
            &Storage::value<Storage::Box<u64>>( // Box<u64> type
                &u64_box_in_box // Box<Box<u64>> type
            )
        );

        // you've already seed Debug::print<T> method
        // which also uses generics to print any type
        Debug::print<u64>(&value);
    }
}
```

这里我们用三种类型使用了 Box：`bool`, `u64` 和 `Box<u64>`。最后一个看起来有些复杂，但是一旦你习惯了，并且理解了泛型是如何工作的，它成为你日常工作的好帮手。

继续下一步之前，让我们做一个简单的回顾。我们通过将泛型添加到`Box`结构体中，使`Box`变得抽象了。与 Box 能提供的功能相比，它的定义相当简单。现在，我们可以使用任何类型创建`Box`，u64 或 address，甚至另一个 Box 或另一个结构体。

### abilities 限制符

我们已经学习了 [abilities](/advanced-topics/types-with-abilities.md)，它们可以作为泛型的限制符来使用，限制符的名称和 ability 相同。

```Move
fun name<T: copy>() {} // allow only values that can be copied
fun name<T: copy + drop>() {} // values can be copied and dropped
fun name<T: key + store + drop + copy>() {} // all 4 abilities are present
```

也可以在结构体泛型参数中使用:

```Move
struct name<T: copy + drop> { value: T } // T can be copied and dropped
struct name<T: stored> { value: T } // T can be stored in global storage
```

> 请记住 `+` 这个语法符号，第一眼看上去可能不太适应，因为很少有语言在关键字列表中使用 `+`。

下面是一个使用限制符的例子：

```Move
module Storage {

    // contents of the box can be stored
    struct Box<T: store> has key, store {
        content: T
    }
}
```

另一个需要被提及的是结构体的成员必须和结构体具有相同的 abilities （除了`key`以外）。这个很容易理解，如果结构体具有 **copy** ability，那么它的成员也必须能被 **copy**，否则结构体作为一个整体不能被 **copy**。Move 编译器允许代码不遵守这样的逻辑，但是运行时会出问题。

```Move
module Storage {
    // non-copyable or droppable struct
    struct Error {}
    
    // constraints are not specified
    struct Box<T> has copy, drop {
        contents: T
    }

    // this method creates box with non-copyable or droppable contents
    public fun create_box(): Box<Error> {
        Box { contents: Error {} }
    }
}
```

这段代码可以成功编译和发布，但是如果你运行它就会出问题。

```Move
script {
    fun main() {
        {{sender}}::Storage::create_box() // value is created and dropped
    }   
}
```

运行结果是报错 Box 不能被 drop。
```
   ┌── scripts/main.move:5:9 ───
   │
 5 │   Storage::create_box();
   │   ^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

原因是创建结构体时所使用的成员值没有 drop ability。也就是 contents 不具备 Box 所要求的 abilities - copy 和 drop。

> 但是为了避免犯错，应该尽可能使泛型参数的限制符和结构体本身的 abilities 显式的保持一致。

所以下面这种定义的方法更安全：

```Move
// we add parent's constraints
// now inner type MUST be copyable and droppable
struct Box<T: copy + drop> has copy, drop {
    contents: T
}
```

### 泛型中包含多个类型

我们也可以在泛型中使用多个类型，像使用单个类型一样，把多个类型放在尖括号中，并用逗号分隔。我们来试着添加一个新类型`Shelf`，它将容纳两个不同类型的`Box`。

```Move
module Storage {

    struct Box<T> {
        value: T
    }

    struct Shelf<T1, T2> {
        box_1: Box<T1>,
        box_2: Box<T2>
    }

    public fun create_shelf<Type1, Type2>(
        box_1: Box<Type1>,
        box_2: Box<Type2>
    ): Shelf<Type1, Type2> {
        Shelf {
            box_1,
            box_2
        }
    }
}
```

`Shelf`的类型参数需要与结构体字段定义中的类型顺序相匹配，而泛型中的类型参数的名称则无需相同，选择合适的名称即可。正是因为每种类型参数仅仅在其作用域范围内有效，所以无需使用相同的名字。

多类型泛型的使用与单类型泛型相同：

```Move
script {
    use {{sender}}::Storage;

    fun main() {
        let b1 = Storage::create_box<u64>(100);
        let b2 = Storage::create_box<u64>(200);

        // you can use any types - so same ones are also valid
        let _ = Storage::create_shelf<u64, u64>(b1, b2);
    }
}
```

*你可以在函数或结构体定义中最多使用 18,446,744,073,709,551,615 (u64 最大值) 个泛型。你绝对不会达到此限制，因此可以随意使用。

### 未使用的类型参数

并非泛型中指定的每种类型参数都必须被使用。看这个例子：

```Move
module Storage {

    // these two types will be used to mark
    // where box will be sent when it's taken from shelf
    struct Abroad {}
    struct Local {}

    // modified Box will have target property
    struct Box<T, Destination> {
        value: T
    }

    public fun create_box<T, Dest>(value: T): Box<T, Dest> {
        Box { value }
    }
}
```

也可以在脚本中使用 :

```Move

script {
    use {{sender}}::Storage;

    fun main() {
        // value will be of type Storage::Box<bool>
        let _ = Storage::create_box<bool, Storage::Abroad>(true);
        let _ = Storage::create_box<u64, Storage::Abroad>(1000);

        let _ = Storage::create_box<u128, Storage::Local>(1000);
        let _ = Storage::create_box<address, Storage::Local>(0x1);

        // or even u64 destination!
        let _ = Storage::create_box<address, u64>(0x1);
    }
}
```

在这里，我们使用泛型标记类型，但实际上并没有真正使用它。当你了解resource概念后，就会知道为什么这种定义很重要。目前，就当这只是使用泛型的一种方法。
<!--
### Kind 和 copyable

在[所有权](/advanced-topics/ownership-and-references.md)一章中，我们了解了 VM 中的复制和移动操作。Move 中所有的值都可以移动，但是并非每个值都可以复制。在即将学习的`Resource`一章中，我们将了解哪些值不可复制。但是在学习它之前，让我们先来了解一下`Kind`是什么。

`Kind`可以用来限制传递给函数的泛型类型。`Kind`有两种：`copyable`和`resource`。

### Copyable

Copyable（可复制的）`Kind`是这样一类类型：其值可以被复制。结构体，数组和基本类型是三大类可以用`Copyable`修饰的类型。

要了解为什么Move需要`Copyable`修饰符，请看以下示例：

```Move
module M {
    public fun deref<T>(t: &T): T {
        *t
    }
}
```

通过对引用使用*取值*操作，我们可以复制原始值并将其作为返回值返回。但是，如果我们在此示例中尝试使用使用 *resource*，会出现什么情况？*resource* 无法复制，预示着代码将会失败。当然编译器不会让我们编译通过，并且用于管理这种情况的`Kind`已经存在了，那就是`copyable`。

```Move
module M {
    public fun deref<T: copyable>(t: &T): T {
        *t
    }
}
```

我们在泛型定义中增加了`copyable`，现在 typeT 必须是可复制的。所以，现在的函数只接受结构体，数组和基本类型作为参数。编译器通过 *copyable* 修饰符对已使用类型的安全性进行检查，在此处传递不可复制的值是不可能的。

### Resource

另一种 kind `resource` 用来限制参数类型只能是`Resource`，使用方法跟`copyable`类似。

```Move
module M {
    public fun smth<T: resource>(t: &T) {
        // do smth
    }
}
```

此处的示例仅用于展示语法，我们很快会接触到 Resource，并学习`resource`修饰符的实际使用。-->

