# Script and Module

There are two types of code transactions in Move: module and script. Module is a deployment of new model (which then will be accessible under the address of sender); Script is a transaction-as-code in which you can use deployed modules as well as the standard library as dependencies.

Module code starts with `module` keyword and its code looks like this. Inside module you can define: new *types* (as structs), *methods* and `resource structs`.

```Move
// written in Move
module MyModule {
    struct hi_fives {
        count: u8
    }

    public fun high_five(): u8 {
        5
    }
}
```

Script must contain `main` function and usually uses deployed modules. See [imports](/move-language-reference/imports.md) on how to import modules.

```Move
// assume that sender address was 0xAF
use {{sender}}::MyModule;

fun main() {
    MyModule::high_five();
}
```

