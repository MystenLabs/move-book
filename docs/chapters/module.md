# Module

Module is set of functions and types packed together which developer publishes under his address. In prevous chapters we only used scripts, though script can only operate with published modules or standard library which itself is a set of modules published under `0x0` address.

> Module is published under its sender's address. Standard library is published under `0x0` address.

> When publishing a module, none of its functions are executed. To use module - use scripts.

Module starts with `module` keyword, which is followed by module name and curly braces - inside them module contents is placed.

```Move
module Math {

    // module contents

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
```

> Module is the only way to publish code accessible for others; new types and resources can too only be defined within module context.

By default your module will be compiled and published from your address. However if you need to use some modules locally (e.g. for testing or developing) or want to specify your address inside module file, use `address <ADDR> {}` syntax:

```Move
address 0x1 {
module Math {
    // module contents

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
}
```
*Like shown in example: best practice is to keep module line without indentation*

## Imports

Default context in Move is empty: the only types you can use are primitives (integers, bool and address), and the only thing you can do within empty context is operate these types and variables while being unable to do something meaningful or useful.

To change that you can import published modules (or standard library).

### Keyword use

Import is marked with keyword `use`, like this:

```Move
use <Address>::<ModuleName>;
```
In here `<Address>` is a publisher's address and `<ModuleName>` is a name of a module. Pretty simple. I'll give you one real example of importing module `Transaction` from standard library:

```Move
use 0x0::Transaction;
```

### Accessing module's contents

To access imported module's methods (or types) use `::` notation. Simple as that - modules can only have one level of definitions so everything you define in module (publicly) can be accessed via double colon.

```Move
script {
    use 0x0::Transaction;

    fun main(addr: address) {
        // here we use method assert() of module Transaction
        // the same way we'd access any other method of any other module
        Transaction::assert(addr == 0x1, 1);
    }
}
```

### Import in script

In scripts imports must be placed inside `script {}` block:

```Move
script {
    use 0x0::Transaction;

    // in just the same way you can import any
    // other module(s). as many as you want!

    fun main() {
        Transaction::assert(true, 1);
    }
}
```

### Import in module

Module imports must be specified inside `module {}` block:

```Move
module Math {
    use 0x0::Transaction;

    // the same way as in scripts
    // you are free to import any number of modules

    public fun equal_or_fail(a: u64, b: u64) {
        Transaction::assert(a == b, 1);
    }
}

```

### Use meets as

To resolve naming conflicts (when 2 or more modules have same names) and to shorten you code you can change name of the imported module using keyword `as`.

Syntax:
```Move
use <Address>::<ModuleName> as <Alias>;
```

In script:
```Move
script {
    use 0x0::Transaction as Tx; // Tx now means Transaction

    fun check_assert() {
        Tx::assert(true, 11);
    }
}
```

The same in module:
```Move
module Math {
    use 0x0::Vector as Vec;

    fun length(&v: vector<u8>): u64 {
        Vec::length(&v)
    }
}
