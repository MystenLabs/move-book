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

Comments are a way to add notes or document your code. They are ignored by the compiler and don't result in the Move bytecode. You can use comments to explain what your code does, to add notes to yourself or other developers, to temporarily remove a part of your code, or to generate documentation. There are three types of comments in Move: line comment, block comment, and doc comment.

## Line comment

```Move
{{#include ../../samples/sources/syntax-basics/comments_line.move:4:}}
```

You can use double slash `//` to comment out the rest of the line. Everything after `//` will be ignored by the compiler.

```Move
{{#include ../../samples/sources/syntax-basics/comments_line_2.move:4:}}
```

## Block comment

Block comments are used to comment out a block of code. They start with `/*` and end with `*/`. Everything between `/*` and `*/` will be ignored by the compiler. You can use block comments to comment out a single line or multiple lines. You can even use them to comment out a part of a line.

```Move
{{#include ../../samples/sources/syntax-basics/comments_block.move:4:}}
```

This example is a bit extreme, but it shows how you can use block comments to comment out a part of a line.

## Doc comment

Documentation comments are special comments that are used to generate documentation for your code. They are similar to block comments, but they start with three slashes `///` and are placed before the definition of the item they document.

```Move
{{#include ../../samples/sources/syntax-basics/comments_doc.move:4:}}
```

<!-- Documentation comments are  -->
