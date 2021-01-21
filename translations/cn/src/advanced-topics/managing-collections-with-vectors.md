# 用 Vector 管理集合

我们已经非常熟悉结构体类型了，它使我们能够创建自己的类型并存储复杂数据。但是有时我们需要动态、可扩展和可管理的功能。为此，Move 提供了向量 Vector。

Vector 是用于存储数据集合的内置类型。集合的数据可以是任何类型（但仅一种）。Vector 功能实际上是由VM提供的，不是由Move语言提供的，使用它的唯一方法是使用标准库和 native 函数。

```Move
script {
    use 0x1::Vector;

    fun main() {
        // use generics to create an emtpy vector
        let a = Vector::empty<&u8>();
        let i = 0;

        // let's fill it with data
        while (i < 10) {
            Vector::push_back(&mut a, i);
            i = i + 1;
        }

        // now print vector length
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);

        // then remove 2 elements from it
        Vector::pop_back(&mut a);
        Vector::pop_back(&mut a);

        // and print length again
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);
    }
}
```

Vector 最多可以存储 18446744073709551615u64（u64最大值）个非引用类型的值。要了解它如何帮助我们管理大型数据，我们试着编写一个模块。

```Move
module Shelf {

    use 0x1::Vector;

    struct Box<T> {
        value: T
    }

    struct Shelf<T> {
        boxes: vector<Box<T>>
    }

    public fun create_box<T>(value: T): Box<T> {
        Box { value }
    }

    public fun value<T: copyable>(box: &Box<T>): T {
        *&box.value
    }

    public fun create<T>(): Shelf<T> {
        Shelf {
            boxes: Vector::empty<Box<T>>()
        }
    }

    // box value is moved to the vector
    public fun put<T>(shelf: &mut Shelf<T>, box: Box<T>) {
        Vector::push_back<Box<T>>(&mut shelf.boxes, box);
    }

    public fun remove<T>(shelf: &mut Shelf<T>): Box<T> {
        Vector::pop_back<Box<T>>(&mut shelf.boxes)
    }

    public fun size<T>(shelf: &Shelf<T>): u64 {
        Vector::length<Box<T>>(&shelf.boxes)
    }
}
```
我们将创建一个 Shelf，为其提供几个 Box，并观察如何在模块中使用 vector：

```Move
script {
    use {{sender}}::Shelf;

    fun main() {

        // create shelf and 2 boxes of type u64
        let shelf = Shelf::create<u64>();
        let box_1 = Shelf::create_box<u64>(99);
        let box_2 = Shelf::create_box<u64>(999);

        // put both boxes to shelf
        Shelf::put(&mut shelf, box_1);
        Shelf::put(&mut shelf, box_2);

        // prints size - 2
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));

        // then take one from shelf (last one pushed)
        let take_back = Shelf::remove(&mut shelf);
        let value     = Shelf::value<u64>(&take_back);

        // verify that the box we took back is one with 999
        assert(value == 999, 1);

        // and print size again - 1
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));
    }
}
```

向量非常强大，它使我们可以存储大量数据，并可以在索引的存储中使用它。

### 内联 Vector 定义的十六进制数组和字符串

Vector 也可以表示字符串。VM支持将`vector<u8>`作为参数传递给`main`脚本中的函数。

也可以使用十六进制字面量（literal）在脚本或模块中定义`vector<u8>`：

```Move
script {

    use 0x1::Vector;

    // this is the way to accept arguments in main
    fun main(name: vector<u8>) {
        let _ = name;

        // and this is how you use literals
        // this is a "hello world" string!
        let str = x"68656c6c6f20776f726c64";

        // hex literal gives you vector<u8> as well
        Vector::length<u8>(&str);
    }
}
```

更简单的方法是使用字符串字面量：

```Move
script {

    fun main() {
        let _ = b"hello world";
    }
}
```

它们被视为ASCII字符串，也被解释为vector<u8>。

### Vector 速查表

这是标准库中 Vector 方法的简短列表：

- 创建一个类型为`<E>`的空向量
```Move
Vector::empty<E>(): vector<E>;
```
- 获取向量的长度
```Move
Vector::length<E>(v: &vector<E>): u64;
```
- 将元素 e 添加到向量末尾
```Move
Vector::push_back<E>(v: &mut vector<E>, e: E);
```
- 获取对向量元素的可变引用。不可变引用可使用`Vector::borrow()`
```
Vector::borrow_mut<E>(v: &mut vector<E>, i: u64): &E;
```
- 从向量的末尾取出一个元素
```
Vector::pop_back<E>(v: &mut vector<E>): E;
```

标准库中的 Vector 模块：

- Diem [diem/diem](https://github.com/diem/diem/blob/master/language/stdlib/modules/vector.move)
- Dfinance [dfinance/dvm](https://github.com/dfinance/dvm/blob/master/lang/stdlib/vector.move)

