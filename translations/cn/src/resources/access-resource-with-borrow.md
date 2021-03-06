# 读取和修改 Resource

Move 有两个内建函数用来读取和修改 Resource。它们的功能就像名字一样：borrow_global 和 borrow_global_mut。

## 不可变借用 `borrow_global`

在 [所有权和引用](/advanced-topics/ownership-and-references.md) 一章，我们已经了解了可变引用（＆mut）和不可变的引用（＆）。现在是时候实践这些知识了！

```Move
// modules/Collection.move
module Collection {

    // added a dependency here!
    use 0x1::Signer;
    use 0x1::Vector;

    struct Item {}
    resource struct T {
        items: vector<Item>
    }

    // ... skipped ...

    /// get collection size
    /// mind keyword acquires!
    public fun size(account: &signer): u64 acquires T {
        let owner = Signer::address_of(account);
        let collection = borrow_global<T>(owner);

        Vector::length(&collection.items)
    }
}
```

这里发生了很多事情。首先，让我们看一下函数的签名。全局函数 borrow_global<T> 返回了对 Resource T 的不可变引用。其签名如下：

```Move
native fun borrow_global<T: resource>(addr: address): &T;
```

通过使用此功能，我们可以读取存储在特定地址的 Resource。这意味着该模块（如果实现了此功能）具有读取任何地址上任何 Resource 的能力，当然这里的 Resource 指的是该模块内定义的任何 Resource。

另一个结论：由于 `Borrow` 检查，你不能返回对 Resource 的引用或对其内容的引用（因为对 Resource 的引用将在函数作用域结束时消失）。

> 由于 Resource 是不可复制的类型，因此不能在其上使用取值运算符 “*”。

### Acquires 关键字

还有另一个值得解释的细节：关键字 `acquires`。该关键字放在函数返回值之后，用来显式定义此函数获取的所有 Resource。我们必须指定所有获取的 Resource，即使它实际上是子函数所获取的 Resource，即父函数必须在其获取列表中包含子函数的获取列表。

acquires 使用方法如下：

```Move
fun <name>(<args...>): <ret_type> acquires T, T1 ... {
```

## 可变借用 `borrow_global_mut`

要获得对 Resource 的可变引用，请添加 `_mut` 到 `borrow_global` 后，仅此而已。让我们添加一个函数，将新的 Item 添加到集合中。

```Move
module Collection {

    // ... skipped ...

    public fun add_item(account: &signer) acquires T {
        let collection = borrow_global_mut<T>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }
}
```

对 Resource 的可变引用允许创建对其内容的可变引用。这就是为什么我们可以在此示例中修改内部向量 items 的原因。

```Move
native fun borrow_global_mut<T: resource>(addr: address): &mut T;
```


