---
description:
  'Modules are the building blocks of Move: learn how to declare, organize, and compile modules in
  your Sui smart contracts.'
---

# Module

A module is the base unit of code organization in Move. Modules are used to group and isolate code,
and all members of the module are private to the module by default. This makes the module a boundary
of trust: as later sections will show, only the module that defines a type can create, modify, and
destroy its values. In this section you will learn how to define a module, declare its members, and
access it from other modules.

## Module Declaration

Modules are declared using the `module` keyword followed by the package address and the module name,
separated by `::`, then a semicolon and the module body. The module name should be in `snake_case` -
all lowercase letters with underscores between words. Module names must be unique in the package.

Usually, a single file in the `sources/` folder contains a single module. The file name should match
the module name - for example, a `donut_shop` module should be stored in the `donut_shop.move` file.
You can read more about coding conventions in the
[Coding Conventions](./../guides/code-quality-checklist) section.

> If you need to declare more than one module in a file, you must use [Module Block](#module-block)
> syntax.

```move file=packages/samples/sources/move-basics/module-label.move anchor=module

```

## Address and Named Address

The module address can be specified in two ways: as an address _literal_ (which does not require the
`@` prefix) or as a package name declared in the [Package Manifest](./../concepts/manifest).

```move file=packages/samples/sources/move-basics/module.move anchor=address_literal

```

Package section in the Move.toml:

```toml
[package]
name = "book"
edition = "2024"
```

## Module Members

Module members are declared inside the module body. To illustrate this, let's define a simple module
with an import, a constant, a struct, and a function:

```move file=packages/samples/sources/move-basics/module-members.move anchor=members

```

Each member starts with its own keyword: `use` brings other modules into scope
([Importing Modules](./importing-modules)), `const` defines a value that never changes
([Constants](./constants)), `struct` declares a custom data type ([Struct](./struct)), and `fun`
declares a function ([Function](./function)). Don't worry about the details yet - each of these has
a dedicated section in this chapter; for now, it is enough to recognize the keywords and know that
all of them live at the module level.

## Module Block

The pre-2024 edition of Move required the body of the module to be a _module block_ - the contents
of the module surrounded by curly braces `{}`. The block syntax is still supported, and the only
reason to prefer it over the _label_ syntax shown above is declaring more than one module in a
file - which is rarely needed, and not a recommended practice.

```move file=packages/samples/sources/move-basics/module.move anchor=members

```

## Further Reading

- [Modules](./../../reference/modules) in the Move Reference.
