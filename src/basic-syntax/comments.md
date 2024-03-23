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

Comments are a way to add notes or document your code. They are ignored by the compiler and don't end up in the Move bytecode. When published to a network, anyone with access to that network can view the bytecode. You can use comments to explain what your code does, to add notes to yourself or other developers, to temporarily remove a part of your code, or to generate documentation. 

There are three types of comments in Move: 
- line comment
- block comment
- doc comment

## Line comment

```Move
{{#include ../../samples/sources/basic-syntax/comments.move:line}}
```

You can use double slash `//` to comment out the rest of the line. The compiler ignores everything after `//`.

```Move
{{#include ../../samples/sources/basic-syntax/comments.move:line_2}}
```

## Block comment

Use block comments to comment out a block of code. They start with `/*` and end with `*/`. The compiler ignores everything between `/*` and `*/`. You can use block comments to comment out a single line or multiple lines. You can even use them to comment out a part of a line.

```Move
{{#include ../../samples/sources/basic-syntax/comments.move:block}}
```
<!-- Might add why this might not be the best approach. Perhaps mention code might get to this point in development, but to clean up for easier maintenance. -->

This example is a bit extreme, but it shows how you can use block comments to comment out a part of a line.

## Doc comment

Documentation comments are special comments that are used to generate documentation for your code. They are similar to block comments, but they start with three slashes `///` and are placed before the definition of the item they document.

```Move
{{#include ../../samples/sources/basic-syntax/comments.move:doc}}
```

<!-- TODO: docgen, which members are in the documentation --> 
<!-- ^ Yes -->