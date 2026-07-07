---
description: "Understand Move packages — the unit of code organization containing modules, dependencies, and addresses published on the Sui blockchain."
---

# Package

Move is a language for writing smart contracts - programs that are stored and run on the blockchain.
A single program is organized into a package. A package is published on the blockchain and is
identified by an [address](./address). A published package can be interacted with by sending
[transactions](./what-is-a-transaction) calling its functions. It can also act as a dependency for
other packages.

> To create a new package, use the `sui move new` command. To learn more about the command, run
> `sui move new --help`.

A package consists of modules - separate scopes that contain functions, types, and other items.

```
package 0x...
    module a
        struct A1
        fun hello_world()
    module b
        struct B1
        fun hello_package()
```

## Package Structure

Locally, a package is a directory with a `Move.toml` file and a `sources` directory. The `Move.toml`
file - called the "package manifest" - contains metadata about the package, and the `sources`
directory contains the source code for the modules. A package usually looks like this:

```
sources/
    my_module.move
    another_module.move
    ...
tests/
    ...
examples/
    using_my_module.move
Move.toml
```

The `tests` directory is optional and contains tests for the package. Code placed into the `tests`
directory is not published onchain and is only available in tests. The `examples` directory can be
used for code examples, and is also not published onchain.

## Published Package

During development, a package doesn't have an address yet, and `0x0` is used in its place. Once a
package is published, it gets a single unique [address](./address) on the blockchain containing its
modules' bytecode. A published package becomes _immutable_ and can be interacted with by sending
transactions.

```
0x...
    my_module: <bytecode>
    another_module: <bytecode>
```

While the published bytecode can never be changed, a package can be _upgraded_: an upgrade
publishes a new version of the package at a new address, leaving the old version intact. We touch
on the implications throughout the book: the
[Package Upgrades](./../programmability/package-upgrades) section explains the mechanics, and the
[Upgradeability Practices](./../guides/upgradeability-practices) guide covers how to design for
upgrades.

## Further Reading

- [Package Manifest](./manifest)
- [Address](./address)
- [Packages](./../../reference/packages) in the Move Reference.
