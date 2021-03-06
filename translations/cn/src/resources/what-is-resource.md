# 什么是 Resource

Resource 是一种类型，它可以安全的表示数字资产。我们知道，不能被复制，也不能被丢弃或重新使用，是对资产属性的一般性描述。那么如何用 Move 语言来实现这些属性呢？下面我们就介绍给大家。

### 定义

Resource 的定义与结构体类似:

```Move
module M {
    resource struct T {
        field: u8
    }
}
```

就像结构体一样，Resource 只能在模块中定义，并且只能被其模块里的函数操作。实际上，Resource 是一种特殊的结构体，因此结构的所有属性都被 Resource 继承。

### Resource 的限制

在代码中，Resource 类型有几个主要限制：

1. Resource 存储在帐户下。因此，只有在分配帐户后才会*存在*，并且只能通过该帐户*访问*。
2. 一个帐户同一时刻只能容纳一个某类型的 Resource。
3. Resource 不能被复制；与它对应的是一种特殊的`kind`：`resource`，它与`copyable`不同，这一点在泛型章节中已经介绍。
4. Resource 必需被`使用`，这意味着必须将新创建的 Resource `move`到某个帐户下，从帐户移出的Resource 必须被解构或存储在另一个帐户下。

理论就这么多，下面让我们看看实际的例子！