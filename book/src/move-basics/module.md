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

Module is the base unit of code organization in Move. Modules are used to group and isolate code,
and all of the members of the module are private to the module by default. In this section you will
learn how to define a module, how to declare its members and how to access them from other modules.

## Module declaration

Modules are declared using the `module` keyword followed by the package address, module name and the
module body inside the curly braces `{}`. The module name should be in `snake_case` - all lowercase
letters with underscores between words. Modules names must be unique in the package.

Usually, a single file in the `sources/` folder contains a single module. The file name should match
the module name - for example, a `donut_shop` module should be stored in the `donut_shop.move` file.
You can read more about coding conventions in the
[Coding Conventions](../special-topics/coding-conventions.md) section.

```Move
{{#include ../../../packages/samples/sources/move-basics/module.move:module}}
```

Structs, functions, constants and imports all part of the module:

- [Structs](./struct.md)
- [Functions](./function.md)
- [Constants](./constants.md)
- [Imports](./importing-modules.md)
- [Struct Methods](./struct-methods.md)

## Address / Named address

Module address can be specified as both: an address _literal_ (does not require the `@` prefix) or a
named address specified in the [Package Manifest](../concepts/manifest.md). In the example below,
both are identical because there's a `book = "0x0"` record in the `[addresses]` section of the
`Move.toml`.

```Move
{{#include ../../../packages/samples/sources/move-basics/module.move:address_literal}}
```

Addresses section in the Move.toml:

```toml
# Move.toml
[addresses]
book = "0x0"
```

## Module members

Module members are declared inside the module body. To illustrate that, let's define a simple module
with a struct, a function and a constant:

```Move
{{#include ../../../packages/samples/sources/move-basics/module.move:members}}
```

## Further reading

- [Modules](/reference/modules.html) in the Move Reference.
