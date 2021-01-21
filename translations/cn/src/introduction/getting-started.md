# 快速入门

与任何编程语言一样，Move应用程序也需要一组适当的工具来编译，运行和调试。由于Move语言是为区块链创建、并且仅在区块链中使用，因此在链外运行程序不是一件容易的事，因为每个应用都需要一个编辑环境，账户处理和编译-发布系统。

为了简化Move程序的开发，我在Visual Studio Code上开发了[Move IDE](https://github.com/damirka/vscode-move-ide) 扩展。该扩展可以满足开发者对开发环境的基本需求，它的功能包括Move语法突出显示和程序执行，以帮助开发者在发布之前调试应用程序。使用它后开发者可以专注于学习Move语言，而不必为客户端（CLI）苦苦挣扎。

## 安装 Move IDE

需要安装下面的软件:

1. VSCode (1.43.0 或者更高版本) - 可以在 [这里](https://code.visualstudio.com/download) 获取; 当然如果你的机器上已经安装了VSCode，可以直接进入下一步;
2. Move IDE - 安装VSCode后，请单击 [这里](https://marketplace.visualstudio.com/items?itemName=damirka.move-ide) 安装最新版本的IDE。

### 环境设置

Move IDE提供了单一的方法来组织目录结构。只需要创建一个新目录，并在VSCode中打开它，就可以得到如下目录结构：
```
modules/   - directory for our modules
scripts/   - directory for transaction scripts
out/       - this directory will hold compiled sources
```

另外，还需要创建一个名为`.mvconfig.json`的文件，该文件将配置您的工作环境。下面这个配置指向了`天秤座`网络:

```json
{
    "network": "libra",
    "sender": "0x1"
}
```

或者使用`dfinance`作为目标网络:

```json
{
    "network": "dfinance",
    "sender": "0x1"
}
```

> dfinance使用bech32"wallet1 ..."地址，天秤座使用16字节“0x ...”地址。对于本地运行或者测试，使用天秤座地址就可以了。但是在测试网或生产环境中使用真实的区块链时，需要使用所选网络的正确地址。
## 第一个Move应用

Move IDE使开发者可以在测试环境中运行程序。让我们通过一个例子，实现gimme_five()功能并在VSCode中运行它，来了解其工作原理。

### 创建模块

在项目的目录modules/内创建一个新文件hello_world.move。
```Move
// modules/hello_world.move
address 0x1 {
module HelloWorld {
    public fun gimme_five(): u8 {
        5
    }
}
}
```

> 如果您想使用自己的地址（而非0x1），请确保更改此文件中的0x1以及下面文件中的地址

### 写脚本

然后在scripts/目录中创建一个脚本me.move，调用上面的模块：
```Move
// scripts/run_hello.move
script {
    use 0x1::HelloWorld;
    use 0x1::Debug;

    fun main() {
        let five = HelloWorld::gimme_five();

        Debug::print<u8>(&five);
    }
}
```

然后，在保持脚本打开的同时，执行以下步骤：

1.通过按`⌘+Shift+P`（在Mac上）或`Ctrl+Shift+P`（在Linux / Windows上）来切换VSCode的命令选项板
2.键入：`>Move: Run Script`并在看到正确的选项时按Enter或单击。
现在，你应该会看到执行结果，输出日志中有“5”信息。如果没有看到此窗口，请再次浏览上面部分，看看有没有漏掉什么。

目录结构应如下所示：
```
modules/
  hello_world.move
scripts/
  run_hello.move
out/
.mvconfig.json
```

> modules目录下可以包含任意多的模块；所有这些模块都可以被你的脚本访问到，只要它们都被定义在.mvconfig.json所指定的地址下。
