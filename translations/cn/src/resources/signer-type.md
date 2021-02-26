# 发件人作为 Signer

在开始使用*Resource*之前，我们需要了解`signer`类型以及这种类型存在的原因。

> Signer 是一种原生的类似 Resource 的不可复制的类型，它包含了交易发送者的地址。

Signer 类型代表了发送者权限。换句话说，使用 signer 意味着可以访问发送者的地址和资源。它与*signature*没有直接关系，就Move VM而言，它仅表示发送者。


### 脚本的 Signer

Signer 是原生类型，使用前必须先创建。与 vector 这样的原生类型不同，signer 不能直接在代码中创建，但是可以作为脚本参数传递：

```Move
script {
    // signer is a reference type here!
    fun main(account: &signer) {
        let _ = account;
    }
}
```

Signer 参数无需手动将其传递到脚本中，VM会自动将它放入你的脚本中。而且，signer 自始至终都只是引用，虽然标准库中可以访问签名者的实际值，但使用此值的函数是私有的，无法在其他任何地方使用或传递signer值。

> 当前，约定俗成的 signer 类型的变量名是*account*

### 标准库中的 Signer 模块

原生类型离不开原生方法, signer 的原生方法包含在`0x1::Signer`模块中。这个模块相对比较简单，具体可以参考Diem标准库Signer模块的[实现](https://github.com/diem/diem/blob/master/language/stdlib/modules/Signer.move):

```Move
module Signer {
    // Borrows the address of the signer
    // Conceptually, you can think of the `signer`
    // as being a resource struct wrapper arround an address
    // ```
    // resource struct Signer { addr: address }
    // ```
    // `borrow_address` borrows this inner field
    native public fun borrow_address(s: &signer): &address;

    // Copies the address of the signer
    public fun address_of(s: &signer): address {
        *borrow_address(s)
    }
}
```

如你所见，有两个方法，其中一个是原生方法，另一个 Move 方法使用更方便，因为它使用了取值运算符来复制地址。

该模块的用法也很简单：


```Move
script {
    fun main(account: &signer) {
        let _ : address = 0x1::Signer::address_of(account);
    }
}
```

### 模块中的 Signer

```Move
module M {
    use 0x1::Signer;

    // let's proxy Signer::address_of
    public fun get_address(account: &signer): address {
        Signer::address_of(account)
    }
}
```

> 使用`&signer`作为参数的方法明确表明它正在使用发送者的地址。

引入`signer`类型的原因之一是要明确显示哪些方法需要发送者权限，哪些不需要。因此，方法不能欺骗用户未经授权访问其资源。


### 扩展阅读

- [Diem 社区关于 signer 的讨论](https://community.diem.com/t/signer-type-and-move-to/2894)
- [引入 signer 的原因](https://github.com/diem/diem/issues/3679)
- [引入 signer 的 PR](https://github.com/diem/diem/pull/3819)
