# 可编程 Resource

这一章，我们终于要学习 Move 的关键功能 `Resource` 了。它使 Move 变得独一无二，安全且强大。

首先，让我们看一下 Diem 开发者网站上的关于 `Resource` 的要点（将 Libra 改名为 Diem 后，原页面已删除）：

> Move 的主要功能是提供了自定义 Resource 类型。*Resource 类型为安全的数字资产编码具提供了丰富的可编程性*。
> *Resource 在Move语言中就是普通的值*。它们可以作为数据结构被存储，作为参数被传递给函数，也可以从函数中返回。

Resource 是一种特殊的*结构体*，可以在 Move 代码中定义和创建，也可以使用现有的 Resource。因此，我们可以像使用任何其它数据（比如向量或结构体）那样来管理数字资产。

> Move 类型系统为 Resource 提供了特殊的安全保证。Resource 永远不能被复制，重用或丢弃。Resource 类型只能由定义该类型的模块创建或销毁。这些检查由 Move 虚拟机通过字节码校验强制执行。Move 虚拟机将拒绝运行任何尚未通过字节码校验的代码。

在*所有权和引用*一章中，我们学习了 Move 如何保护作用域以及如何控制变量的所有者作用域。在泛型一章，我们了解到有一种特殊的*Kind*匹配方式可以将*可复制*和*不可复制*类型分开。所有这些功能同时也为 Resource 类型提供了强大的安全性。

> 所有 Diem 货币都使用 *Diem<CoinType>* 类型实现。例如：假设的美元稳定币被表示为 *Diem<XUS>*。*Diem<CoinType>* 在 Move 中并没有特殊地位，每个 Move Resource 都享有相同的安全保护。

就像 Diem 货币一样，其它代币或其它类型的资产也可以在 Move 中表示。

### 扩展阅读

- [Move 白皮书](https://developers.diem.com/docs/technical-papers/move-paper/)
