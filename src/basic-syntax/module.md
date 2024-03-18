# Module

<!--

Chapter: Base Syntax
Goal: Introduce module keyword.
Notes:
    - modules are the base unit of code organization
    - module members are private by default
    - types internal to the module have special access rules
    - only module can pack and unpack its types

 -->

Module is the base unit of code organization in Move. Modules are used to group and isolate code, and all of the members of the module are private to the module by default. In this section you will learn how to define a module, how to declare its members and how to access them from other modules.

## Module declaration

Modules are declared using the `module` keyword followed by the package address, module name and the module body inside the curly braces `{}`. The module name should be in `snake_case` - all lowercase letters with underscores between words. Modules names must be unique in the package.

Usually, a single file in the `sources/` folder contains a single module. The file name should match the module name - for example, a `donut_shop` module should be stored in the `donut_shop.move` file. You can read more about coding conventions in the [Coding Conventions](../special-topics/coding-conventions.md) section.

```Move
{{#include ../../samples/sources/syntax-basics/module.move:4:6}}
```

Structs, functions and constants, imports and friend declarations are all part of the module:

- [Structs](./struct.md)
- [Functions](./function.md)
- [Constants](./constants.md)
- [Imports](./importing-modules.md)
- [Friend declarations]() <!-- TODO -->
- [Method Aliases](./struct-methods.md)

## Address / Named address

Module address can be specified as both: an address *literal* (does not require the `@` prefix) or a named address specified in the [Package Manifest](../getting-started/package-manifest.md). In the example below, both are identical because there's a `book = "0x0"` record in the `[addresses]` section of the `Move.toml`.

```Move
{{#include ../../samples/sources/syntax-basics/module.move:4:10}}
```

## Module members

Module members are declared inside the module body. To illustrate that, let's define a simple module with a struct, a function and a constant:

```Move
{{#include ../../samples/sources/syntax-basics/module_with_members.move:4:}}
```

## Address block

Before the introduction of the `address::module_name` syntax, modules were organized into `address {}` blocks. This way of code organization is still available today, but is not used widely. Modern practices imply having a single module per file, so the `address {}` block is rather a redundant construct.

> Module addresses can be omitted if modules are organized into `address {}` blocks.

```Move
{{#include ../../samples/sources/syntax-basics/module.move:12:}}
```

The modules defined in this code sample will be accessible as:

- `book::another_module`
- `book::yet_another_module`
