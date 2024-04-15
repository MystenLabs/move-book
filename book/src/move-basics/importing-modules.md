# Importing Modules

<!--
    TODO: create a better example for:
        1. Importing a module in general
        2. Importing a member
        3. Importing multiple members
        4. Grouping imports
        5. Self keyword for groups
-->

<!--

Goals:
    - Show the import syntax
    - Local dependencies
    - External dependencies
    - Importing modules from other packages

 -->

Move achieves high modularity and code reuse by allowing module imports. Modules within the same
package can import each other, and a new package can depend on already existing packages and use
their modules too. This section will cover the basics of importing modules and how to use them in
your own code.

## Importing a Module

Modules defined in the same package can import each other. The `use` keyword is followed by the
module path, which consists of the package address (or alias) and the module name separated by `::`.

```move
// File: sources/module_one.move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:module_one}}
```

Another module defined in the same package can import the first module using the `use` keyword.

```move
// File: sources/module_two.move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:module_two}}
```

## Importing Members

You can also import specific members from a module. This is useful when you only need a single
function or a single type from a module. The syntax is the same as for importing a module, but you
add the member name after the module path.

```move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:members}}
```

## Grouping Imports

Imports can be grouped into a single `use` statement using the curly braces `{}`. This is useful
when you need to import multiple members from the same module. Move allows grouping imports from the
same module and from the same package.

```move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:grouped}}
```

Single function imports are less common in Move, since the function names can overlap and cause
confusion. A recommended practice is to import the entire module and use the module path to access
the function. Types have unique names and should be imported individually.

To import members and the module itself in the group import, you can use the `Self` keyword. The
`Self` keyword refers to the module itself and can be used to import the module and its members.

```move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:self}}
```

## Resolving Name Conflicts

When importing multiple members from different modules, it is possible to have name conflicts. For
example, if you import two modules that both have a function with the same name, you will need to
use the module path to access the function. It is also possible to have modules with the same name
in different packages. To resolve the conflict and avoid ambiguity, Move offers the `as` keyword to
rename the imported member.

```move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:conflict}}
```

## Adding an External Dependency

Every new package generated via the `sui` binary features a `Move.toml` file with a single
dependency on the _Sui Framework_ package. The Sui Framework depends on the _Standard Library_
package. And both of these packages are available in default configuration. Package dependencies are
defined in the [Package Manifest](./../concepts/manifest.md) as follows:

```toml
[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
Local = { local = "../my_other_package" }
```

The `dependencies` section contains a list of package dependencies. The key is the name of the
package, and the value is either a git import table or a local path. The git import contains the URL
of the package, the subdirectory where the package is located, and the revision of the package. The
local path is a relative path to the package directory.

If a dependency is added to the `Move.toml` file, the compiler will automatically fetch (and later
refetch) the dependencies when building the package.

## Importing a Module from Another Package

Normally, packages define their addresses in the `[addresses]` section, so you can use the alias
instead of the address. For example, instead of `0x2::coin` module, you would use `sui::coin`. The
`sui` alias is defined in the Sui Framework package. Similarly, the `std` alias is defined in the
Standard Library package and can be used to access the standard library modules.

To import a module from another package, you use the `use` keyword followed by the module path. The
module path consists of the package address (or alias) and the module name separated by `::`.

```move
{{#include ../../../packages/samples/sources/move-basics/importing-modules.move:external}}
```
