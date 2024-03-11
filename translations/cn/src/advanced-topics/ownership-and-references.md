# 所有权和引用

Move VM 实现了类似 Rust 的所有权功能。关于所有权的详细描述，可以参考 [Rust Book](https://doc.rust-lang.org/stable/book/ch04-01-what-is-ownership.html) 。

Rust 语法不同于 Move，某些示例可能不容易理解，但还是建议大家先阅读一下 Rust Book 中的所有权一章。当然，关于所有权的关键点本书也会逐一介绍。

> 每个变量只有一个所有者作用域。当所有者作用域结束时，变量将被删除。

变量的寿命与它的作用域一样长，我们曾经在表达式一章中看到过这种行为，大家还有没有印象？现在是了解其内部机制的绝佳时机了。

所有者是*拥有*某变量的作用域。变量可以在作用域内定义（例如，在脚本中使用关键字 let），也可以作为参数传递给作用域。由于 Move 中唯一的作用域是函数的作用域，所以除了这两种方法，没有其它方法可以将变量放入作用域。

每个变量只有一个所有者，这意味着当把变量作为参数传递给函数时，该函数将成为*新所有者*，并且第一个函数不再*拥有*该变量。或者可以说，第二个函数接管了变量的*所有权*。

```Move
script {
    use {{sender}}::M;

    fun main() {
        // Module::T is a struct
        let a : Module::T = Module::create(10);

        // here variable `a` leaves scope of `main` function
        // and is being put into new scope of `M::value` function
        M::value(a);

        // variable a no longer exists in this scope
        // this code won't compile
        M::value(a);
    }
}
```
让我们看一下将变量传递给 value() 函数时，Move 内部发生的情况：

```Move
module M {
    // create_fun skipped
    struct T { value: u8 }

    public fun create(value: u8): T {
        T { value }
    }

    // variable t of type M::T passed
    // `value()` function takes ownership
    public fun value(t: T): u8 {
        // we can use t as variable
        t.value
    }
    // function scope ends, t dropped, only u8 result returned
    // t no longer exists
}
```
我们可以看到，当函数 value() 结束时，t 将不复存在，返回的只是一个 u8 类型的值。如何让t仍然可用呢？当然，一种快速的解决方案是返回一个元组，该元组包含原始变量和其它结果，但是 Move 还有一个更好的解决方案。

## move 和 copy

首先，我们了解一下 Move VM 的工作原理，以及将值传递给函数时会发生什么。Move VM 里有两个字节码指令：*MoveLoc* 和 *CopyLoc*，反映到 Move 语言层面，它们分别对应关键字`move`和`copy`。

将变量传递到另一个函数时，MoveLoc 指令被使用，它会被 *move*。我们可以像下面这样显式使用 *move* 关键字：

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        M::value(move a); // variable a is moved

        // local a is dropped
    }
}
```
这段代码是没有问题的，但是我们平常并不需要显示使用 *move*，缺省 a 会被 *move*。那么 *copy* 又是怎么回事呢？

### 关键字 `copy`

如果想保留变量的值，同时仅将值的副本传递给某函数，则可以使用关键字 `copy`。

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        // we use keyword copy to clone structure
        // can be used as `let a_copy = copy a`
        M::value(copy a);
        M::value(a); // won't fail, a is still here
    }
}
```
上例中，我们第一次调用函数 value() 时，将变量 a 的副本传递给函数，并保留 a 在本地作用域中，以便第二次调用函数时再次使用它。

使用 *copy* 后，我们实际上复制了变量值从而增加了程序占用内存的大小。但是如果复制数据数据量比较大，它的内存消耗可能会很高。这里要注意了，在区块链中，交易执行时占用的内存资源是消耗交易费的，每个字节都会影响交易执行费用。因此不加限制的使用 copy 会浪费很多交易费。

现在，是时候学习`引用`了，它可以帮助我们避免不必要的` copy` 从而节省一些费用。

## 引用

许多编程语言都支持`引用`。*引用*是指向变量（通常是内存中的某个片段）的链接，你可以将其传递到程序的其他部分，而无需移动变量值。

> 引用（标记为＆）使我们可以使用值而无需拥有所有权。

我们修改一下上面的示例，看看如何使用引用。

```Move
module M {
    struct T { value: u8 }
    // ...
    // ...
    // instead of passing a value, we'll pass a reference
    public fun value(t: &T): u8 {
        t.value
    }
}
````

我们在参数类型 T 前添加了＆符号，这样就可以将参数类型T转换成了 T 的引用&T。

> Move 支持两种类型的引用：不可变引用 &（例如&T）和可变引用 &mut（例如&mut T）。

不可变的引用允许我们在不更改值的情况下读取值。可变引用赋予我们读取和更改值的能力。

```Move
module M {
    struct T { value: u8 }

    // returned value is of non-reference type
    public fun create(value: u8): T {
        T { value }
    }

    // immutable references allow reading
    public fun value(t: &T): u8 {
        t.value
    }

    // mutable references allow reading and changing the value
    public fun change(t: &mut T, value: u8) {
        t.value = value;
    }
}
```

现在，让我们看看如何使用升级后的模块 M。

```Move
script {
    use {{sender}}::M;

    fun main() {
        let t = M::create(10);

        // create a reference directly
        M::change(&mut t, 20);

        // or write reference to a variable
        let mut_ref_t = &mut t;

        M::change(mut_ref_t, 100);

        // same with immutable ref
        let value = M::value(&t);

        // this method also takes only references
        // printed value will be 100
        0x1::Debug::print<u8>(&value);
    }
}
```

> 使用不可变引用（＆）从结构体读取数据，使用可变引用（＆mut）修改它们。通过使用适当类型的引用，我们可以更加安全的读取模块，因为它能告诉代码的阅读者，该变量是否会被修改。

### Borrow 检查

Move 通过"Borrow 检查"来控制程序中"引用"的使用，这样有助于防止意外出错。为了理解这一点，我们看一个例子。

```Move
module Borrow {

    struct B { value: u64 }
    struct A { b: B }

    // create A with inner B
    public fun create(value: u64): A {
        A { b: B { value } }
    }

    // give a mutable reference to inner B
    public fun ref_from_mut_a(a: &mut A): &mut B {
        &mut a.b
    }

    // change B
    public fun change_b(b: &mut B, value: u64) {
        b.value = value;
    }
}
```

```Move
script {
    use {{sender}}::Borrow;

    fun main() {
        // create a struct A { b: B { value: u64 } }
        let a = Borrow::create(0);

        // get mutable reference to B from mut A
        let mut_a = &mut a;
        let mut_b = Borrow::ref_from_mut_a(mut_a);

        // change B
        Borrow::change_b(mut_b, 100000);

        // get another mutable reference from A
        let _ = Borrow::ref_from_mut_a(mut_a);
    }
}
```
上面代码可以成功编译运行，不会报错。这里究竟发生了什么呢？首先，我们使用 A 的可变引用（&mut A）来获取对其内部 struct B 的可变引用（&mut B）。然后我们改变 B。然后可以再次通过 &mut A 获取对 B 的可变引用。

但是，如果我们交换最后两个表达式，即首先尝试创建新的 &mut A，而 &mut B 仍然存在，会出现什么情况呢？

```Move
let mut_a = &mut a;
let mut_b = Borrow::ref_from_mut_a(mut_a);

let _ = Borrow::ref_from_mut_a(mut_a);

Borrow::change_b(mut_b, 100000);
```

编译器将会报错：

```Move
    ┌── /scripts/script.move:10:17 ───
    │
 10 │         let _ = Borrow::ref_from_mut_a(mut_a);
    │                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invalid usage of reference as function argument. Cannot transfer a mutable reference that is being borrowed
    ·
  8 │         let mut_b = Borrow::ref_from_mut_a(mut_a);
    │                     ----------------------------- It is still being mutably borrowed by this reference
    │
```

该代码不会编译成功。为什么？因为 &mut A 已经被 &mut B 借用。如果我们再将其作为参数传递，那么我们将陷入一种奇怪的情况，A 可以被更改，但 A 同时又被引用。而 mut_b 应该指向何处呢？

我们得出一些结论：

1. 编译器通过所谓的"借用检查"（最初是Rust语言的概念）来防止上面这些错误。编译器通过建立"借用图"，不允许被借用的值被"move"。这就是 Move 在区块链中如此安全的原因之一。
2. 可以从引用创建新的引用，老的引用将被新引用"借用"。可变引用可以创建可变或者不可变引用，而不可变引用只能创建不可变引用。
3. 当一个值被引用时，就无法"move"它了，因为其它值对它有依赖。

### 取值运算

可以通过`取值`运算`*`来获取引用所指向的值。

> 取值运算实际上是产生了一个副本，要确保这个值具有 `Copy` ability。

```Move
module M {
    struct T has copy {}

    // value t here is of reference type
    public fun deref(t: &T): T {
        *t
    }
}
```

> 取值运算不会将原始值 move 到当前作用域，实际上只是生成了一个副本。

有一个技巧用来复制一个结构体的字段：就是使用`*&`，引用并取值。我们来看一个例子：

```Move
module M {
    struct H has copy {}
    struct T { inner: H }

    // ...

    // we can do it even from immutable reference!
    public fun copy_inner(t: &T): H {
        *&t.inner
    }
}
```
通过使用*&（编译器会建议这样做），我们复制了结构体的内部值。

### 引用基本类型

基本类型非常简单，它们不需要作为引用传递，缺省会被复制。当基本类型的值被传给函数时，相当于使用了`copy`关键字，传递进函数的是它们的副本。当然你可以使用`move`关键字强制不产生副本，但是由于基本类型的大小很小，复制它们其实开销很小，甚至比通过引用或者"move"传递它们开销更小。

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a = 10;
        M::do_smth(a);
        let _ = a;
    }
}
```
也就是说，即使我们没有将`a`作为引用传递，该脚本也会编译。我们也无需添加`copy`，因为 VM 已经帮组我们添加了。

