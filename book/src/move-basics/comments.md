# Comments

<!--

Chapter: Basic Syntax
Goal: Introduce comments.
Notes:
    - doc comments are used in docgen
    - only public members are documented
    - doc comments are placed in between attributes and the definition
    - doc comments are allowed for: modules, structs, functions, constants
    - give an example of how doc comments are translated
 -->

Comments are a way to add notes or document your code. They are ignored by the compiler and don't
result in Move bytecode. You can use comments to explain what your code does, add notes to
yourself or other developers, temporarily remove a part of your code, or generate
documentation. There are three types of comments in Move: line comments, block comments, and doc
comments.

## Line comment

You can use a double slash `//` to comment out the rest of the line. Everything after `//` will be
ignored by the compiler.

```Move
{{#include ../../../packages/samples/sources/move-basics/comments-line.move:main}}
```

## Block comment

Block comments are used to comment out a block of code. They start with `/*` and end with `*/`.
Everything between `/*` and `*/` will be ignored by the compiler. You can use block comments to
comment out a single line or multiple lines. You can even use them to comment out a part of a line.

```Move
{{#include ../../../packages/samples/sources/move-basics/comments-block.move:main}}
```

This example is a bit extreme, but it shows all the ways that you can use block comments.

## Doc comment

Documentation comments are special comments that are used to generate documentation for your code.
They are similar to block comments but start with three slashes `///` and are placed before
the definition of the item they document.

```Move
{{#include ../../../packages/samples/sources/move-basics/comments-doc.move:main}}
```

## Whitespace

Unlike some languages, whitespace (spaces, tabs, and newlines) have no impact
on the meaning of the program.

<!-- TODO: docgen, which members are in the documentation -->
