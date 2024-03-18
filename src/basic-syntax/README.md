<!--


    This is an attempt to structure the narrative in a way that makes sense, and so that it builds
    up to the next section.

    Then why would we give "The first Move section" ?
        - it's great to give a taste of Move overall, without linking it to storage / specific blockchain
        - maybe it can be confusing; though if we call the first section "Hello Move", and the second
          "Hello Sui", then the reader would differentiate between the two
        // marking the above as an open question for now



    Introduction

    Foreword
        - this book is a product of collaboration between people who love Move and
          education and people who are incredibly smart and build the language

    What is Sui

    Setting Up the Environment
        - Install Sui
        - Set up your IDE
        - Project Setup         ??? not sure about this one
        - Manifest              ??? this one is also not sure

    Your First Move
        // goal: showcase main features of the CLI / compiler
        // note: this section is not about Sui, but about Move; it is interactive and
                can be run by anyone to get a taste of Move as a language and Sui CLI
                as a tool; it's pretty neat that Move has tests, and that there's a
                documentation generator, and that there's a way to debug the code;






 -->

<!--

The `name` field contains the name of the package. It is not a published name, but a name of the package when it is imported by other packages. The `edition` field contains the edition of the Move language, the "2024" edition is the most recent one. The `dependencies` section contains package dependencies. To run meaningful applications on Sui, you need to have the `Sui` package as a dependency.

The addresses section contains named aliases for addresses. Not yet published package always has the address `0x0`, but when it is published, the address should be changed to the actual address. Compiler will replace the aliases with the actual addresses when compiling the package. -->

<!-- This is a good example for why the book format is great -->

<!-- For convenience and readability, addresses section should contain at least one alias for the package address. It allows you to use the alias instead of the address when you need to access the package; it also splits the configuration and code, allowing you to change the value in one place. For example, instead of `0x0::module::member` you can use `book::module::member`.

Package is imported with its addresses - the `Sui` import will add `sui` and `std` aliases. They're standard aliases for Sui Framework - 0x2, and Standard Library - 0x1. -->

<!-- ## Module

While package can be considered an organizational unit, module is where the code lives. Module is a collection of functions, types, constants and other items. Module is declared with the `module` keyword:


The module declaration consists of the `module` keyword followed by the module path - a package address and a module name separated by `::`. The module path is followed by the module body - a collection of items inside curly braces `{}`. The module body is a scope, and all items inside it are inaccesible from outside the module by default.

Modules are stored in the `sources` directory (and its subdirectories). File system path doesn't affect the module path and will be omitted when publishing, so the module path is `book::my_module` regardless of the file system path. For example, if you have a directory structure like this:

```
sources/
    basics/
        my/
            module.move
Move.toml
```

The module path will be `book::my_module`, and **not** `book::basics::my::module`.

Modules can import other modules and access public functions and types. The dependency needs to be declared in the package manifest, so that the compiler knows where to find it. We will learn more about imports in the [Import](../syntax-basics/import.md) section.

Directories other than `sources` will not be compiled by default and hence won't be published. You can use them to store tests, documentation, examples, and other files. Though all folders are scanned when compiling in "test mode", so examples and tests can be checked for compilation errors.

Modules compiled in test mode won't be published, so there's no way to make a mistake publishing what wasn't meant to be published.

## Interaction with the blockchain

Function is a block of code that contains a sequence of statements and expressions. Function can take arguments and return a value. Function is declared with the `fun` keyword.


Like any module member, functions are accessed via a path. The path consists of the module path and the function name separated by `::`. For example, if you have a function called `my_function` in the `my_module` module in the `book` package, the path to it will be `book::my_module::my_function`.

Functions can be called in a transaction. User can send a transaction containing a call to a function, and the function will be executed on the blockchain. We will learn more about transactions in the [Transaction](../syntax-basics/transaction.md) section. Any public function can be called in a transaction.

So, if we made the `my_function` public, we can call it in a transaction:

To call it, a user would need to send a transaction containing a "move-call", which would roughly look like this:

```bash
sui client call \
    --package 0x... \
    --module book::my_module \
    --function my_function \
    --gas-budget 10000000
```

Having said that, Move modules define the interface of the package. For example, if there's a need to implement a database-like system with addition, modification and deletion of records, the module would define a matching set of functions. And users would be able to call those functions in transactions.

## Storage

Move is an object-oriented language, and as such, it stores data in objects. Objects are instances of types with the `key` ability and are stored in the blockchain storage. Every Object has a `UID` - a unique identifier that is used to access the object. The `UID` is a 32-byte value, and it is generated when the object is created. The internal value of the UID also contains an address.

> Package is also an immutable (unchangeable) object stored in the blockchain storage. However, it is a special case, and can't be used to store data except for the package bytecode.

## Accounts

Accounts are the main way to interact with the blockchain. Accounts are identified by addresses and can send transactions to the blockchain. An account is generated from a private key, and the private key is used to sign transactions. Every account has a standard 32-byte address.

Every transaction has a sender - an account that signed the transaction. The sender is identified by their address. Accounts can own objects

## End to end example

<!--
    After we explained the basics of the code organization. I think it makes sense to give an example,
    Rust Book does it. It's a good way to show how the code is organized and how it works. And it will
    leave the reader with something to play with.

    So that when we get to the next section, they will be able to modify the code and see how it works.
    And it will be a good way to introduce the next section.

    The example should be simple and short. It should be something that can be explained in a few
    sentences. It should be something that can be modified and played with. It should be something
    that can be used as a base for the next section.

    Maybe that's the point where we introduce objects and storage? They won't appear any time soon, but
    some bits can be illustrated upfront to create this anticipation for what is possible.
-->

## Getting Ready

Now that we know what a package, account and storage are, let's get to the basics and learn to write some code.

This section covers:

- types
- functions
- structs
- constants
- control flow
- tests

<!-- TODO: rewrite the intro for the chapter -->
