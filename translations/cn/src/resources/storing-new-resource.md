# 创建和移动 Resource

首先，让我们创建模块：

```Move
// modules/Collection.move
module Collection {


    struct Item {
        // we'll think of the properties later
    }

    resource struct T {
        items: vector<Item>
    }
}
```

> 一个模块里最主要的 Resource 通常命名为**T**。遵循这个惯例，你的模块将易于阅读和使用。

### 创建和移动

我们定义了一个 Resource 结构体`T`，该结构体将保存一个向量，向量里面存放`Item`类型的元素。现在，让我们看看如何创建新集合以及如何在 *account* 下存储 Resource。Resource 将永久保存在发送者的地址下，没有人可以从所有者那里修改或取走此 Resource。

```Move
// modules/Collection.move
module Collection {

    use 0x1::Vector;

    struct Item {}

    resource struct T {
        items: vector<Item>
    }

    /// note that &signer type is passed here!
    public fun start_collection(account: &signer) {
        move_to<T>(account, T {
            items: Vector::empty<T>()
        })
    }
}
```

还记得 `signer` 吗？现在，你将了解它的运作方式！移动 Resource 到 account 需要使用内建函数 *move_to*，需要 signer 作为第一个参数，T 作为第二个参数。move_to 函数的签名可以表示为：

```Move
native fun move_to<T: resource>(account: &signer, value: T);
```

总结一下上面所学的内容：

1. 你只能将 Resource 放在自己的帐户下。你无权访问另一个帐户的 `signer` 值，因此无法放置 Resource 到其它账户。
2. 一个地址下最多只能存储一个同一类型的 Resource。两次执行相同的操作是不行的，比如第二次尝试创建已有 Resource 将会导致失败。

### 查看 Resource 是否存在

Move 提供 `exists` 函数来查看某 Resource 是否存在于给定地址下，函数签名如下:

```Move
native fun exists<T: resource>(addr: address): bool;
```

通过使用泛型，此函数成为独立于类型的函数，你可以使用任何 Resource 类型来检查其是否存在于给定地址下。实际上，任何人都可以检查给定地址处是否存在 Resource。但是检查是否存在并不意味着能获取储 Resource ！

让我们编写一个函数来检查用户是否已经拥有 resource T：

```Move
// modules/Collection.move
module Collection {

    struct Item {}

    resource struct T {
        items: Item
    }

    // ... skipped ...

    /// this function will check if resource exists at address
    public fun exists_at(at: address): bool {
        exists<T>(at)
    }
}
````

现在你已经知道了如何创建 Resource，如何将其移动到发送者账户下以及如何检查 Resource 是否已经存在，现在是时候学习如何访问和修改 Resource 了。