---
description: "How to use line comments, block comments, and doc comments in Move for documentation and code annotation."
---

# Comments

Comments are a way to add notes or document your code. They are ignored by the compiler and don't
result in Move bytecode. You can use comments to explain what your code does, add notes to yourself
or other developers, temporarily remove a part of your code, or generate documentation. There are
three types of comments in Move: line comments, block comments, and doc comments.

## Line Comment

You can use a double slash `//` to comment out the rest of the line. Everything after `//` will be
ignored by the compiler.

```move file=packages/samples/sources/move-basics/comments-line.move anchor=main

```

## Block Comment

Block comments are used to comment out a block of code. They start with `/*` and end with `*/`.
Everything between `/*` and `*/` will be ignored by the compiler. You can use block comments to
comment out a single line or multiple lines. You can even use them to comment out a part of a line.

```move file=packages/samples/sources/move-basics/comments-block.move anchor=main

```

This example is a bit extreme, but it shows all the ways that you can use block comments.

## Doc Comment

Documentation comments are special comments that are used to generate documentation for your code.
They are similar to line comments but start with three slashes `///` and are placed before the
definition of the item they document - a module, a struct, a function, or a constant.

```move file=packages/samples/sources/move-basics/comments-doc.move anchor=main

```

Documentation tooling collects doc comments of the public members into reference pages - the
[standard library and framework documentation](https://docs.sui.io/references/framework) linked
throughout this book is generated exactly this way. A well-written doc comment states what the
function does, and under which conditions it aborts.

## Whitespace

Unlike some languages, whitespace (spaces, tabs, and newlines) has no impact on the meaning of the
program.
