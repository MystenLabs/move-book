# 什么是 Resource

Move 白皮书中详细描述了 Resource 这个概念。最初，它是作为一种名为 resource 的结构体类型被实现，自从引入 ability 以后，它被实现成拥有 `Key` 和 `Store` 两种 ability 的结构体。Resource 可以安全的表示数字资产，它不能被复制，也不能被丢弃或重新使用，但是它却可以被安全地存储和转移。

### 定义

Resource 是一种用 `key` 和 `store` ability 限制了的结构体:

```Move
module M {
    struct T has key, store {
        field: u8
    }
}
```

### Resource 的限制

在代码中，Resource 类型有几个主要限制：

1. Resource 存储在帐户下。因此，只有在分配帐户后才会*存在*，并且只能通过该帐户*访问*。
2. 一个帐户同一时刻只能容纳一个某类型的 Resource。
3. Resource 不能被复制；与它对应的是一种特殊的`kind`：`resource`，它与`copyable`不同，这一点在泛型章节中已经介绍。
4. Resource 必需被`使用`，这意味着必须将新创建的 Resource `move`到某个帐户下，从帐户移出的Resource 必须被解构或存储在另一个帐户下。

理论就这么多，下面让我们看看实际的例子！