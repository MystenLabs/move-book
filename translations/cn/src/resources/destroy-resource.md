# 取出和销毁 Resource

本章的最后一个函数是 `move_from`，它用来将 Resource 从账户下取出。我们将实现 `destroy` 函数，将 `Collection` 的 `T` Resource 从账户取出并且销毁它的内容。

```Move
// modules/Collection.move
module Collection {

    // ... skipped ...

    public fun destroy(account: &signer) acquires T {

        // account no longer has resource attached
        let collection = move_from<T>(Signer::address_of(account));

        // now we must use resource value - we'll destructure it
        let T { items: _ } = collection;

        // done. resource destroyed
    }
}
```

Resource 必需被`使用`。因此，从账户下取出 Resource 时，要么将其作为返回值传递，要么将其销毁。但是请记住，即使你将此 Resource 传递到外部并在脚本中获取，接下来能做的操作也非常有限。因为脚本上下文不允许你对结构体或 Resource 做任何事情，除非 Resource 模块中定义了操作 Resource 公开方法，否则只能将其传递到其它地方。知道这一点，就要求我们在设计模块时，为用户提供操作 Resource 的函数。

`move_from` 函数签名：
```Move
native fun move_from<T: resource>(addr: address): T;
```
