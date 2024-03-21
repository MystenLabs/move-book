# Hello World

<!-- TODO: redo the tutorial based on new CLI scaffold features -->

<!--

- Hello World
    - copy-paste the example
    - explain the structure of the code
    - explain the module
    - explain the function
    - run sui move build
    - compare the output
    - leave a hint, show that there's more to it

-->

<!-- Could use more here. ...start with HW, publish, exact results, etc. -->

It's time to write your first Move program. We'll start with the classic "Hello World" program, which returns a String.

## Initialize a project

First, you need to initialize a new project. Assuming [you have Sui installed](../before-we-begin/install-sui.md), run the following command:

```bash
$ sui move new hello_world
```

Sui CLI has a `move` subcommand that you use to work with Move packages. The `move new` subcommand creates a new package with the given name in a new directory. In our case, the package name is `hello_world`, and it is located in the `hello_world` directory.

To make sure that the package is created successfully, we can check the contents of the current directory, and see that there is a new `hello_world` path.

```bash
$ ls | grep hello_world
hello_world
```

<!--
    Revisit, decide if we should go that deep and detailed;
    Expect the user to know how to use a terminal and a text editor?
-->

If the console dispalys the `hello_world` directory, then everything is fine and we can proceed. The folder structure of the package is the folowing:

<!-- This is not the folder structure after running the command. Will need to make that more explicit...instruct user to create tests folder, etc. or just mention that the final structure will look like this -->

```bash
hello_world
├── Move.toml
├── sources/
│   └── hello_world.move
└── tests/
    └── hello_world_tests.move
```

The address this book uses is always `0x0` and the name for it is "book". You can use any address you want, but make sure to change it in the examples. To make the examples work as is, add the following address to the `[addresses]` section in the `Move.toml`:

```toml
# Move.toml
[addresses]
std = "0x1"
book = "0x0"
```

## Create a module

Let's create a new module called `hello_world`. To do so, create a new file in the `sources` folder called `hello_world.move`. So that the structure looks like this:

```bash
sources/
    hello_world.move
Move.toml
```

And then add the following code to the `hello_world.move` file:

<!-- what if code changes and the lines don't match anymore? Manual check or some other process? -->

```Move
// sources/hello_world.move
{{#include ../../samples/sources/your-first-move/hello_world.move:4:9}}
{{#include ../../samples/sources/your-first-move/hello_world.move:16:16}}
```

While it's not a hard restriction, it's considered a good practice to name the module the same as the file. So, in our case, the module name is `hello_world` and the file name is `hello_world.move`.

The module name and function names should be in `snake_case` - all lowercase letters with underscores between words. You can read more about coding conventions in the [Coding Conventions](../special-topics/coding-conventions.md) section.

## Dive into the code

Let's take a closer look at the code we just wrote:

```Move
{{#include ../../samples/sources/your-first-move/hello_world.move:4:4}}
{{#include ../../samples/sources/your-first-move/hello_world.move:16:16}}
```
<!-- nice para -->
The first line of code declares a module called `hello_world` stored at the address `book`. The contents of the module go inside the curly braces `{}`. The last line closes the module declaration with a closing curly brace `}`. We will go through the module declaration in more detail in the [Modules](../basic-syntax/modules.md) section.

<!-- std is a package but book is an address? Might seem confusing --> 
Then we import two members of the `std::string` module (which is part of the `std` package). The `string` module contains the `String` type, and the `Self` keyword imports the module itself, so we can use its functions.

```Move
{{#include ../../samples/sources/your-first-move/hello_world.move:5:5}}
```

Then we define a `hello_world` function using the keyword `fun`, which takes no arguments and returns a `String` type. The `public` keyword marks the visibility of the function - "public" functions can be accessed by other modules. The function body is inside the curly braces `{}`.

> The [Function](../basic-syntax/function.md) section teaches more about functions.

```Move
{{#include ../../samples/sources/your-first-move/hello_world.move:7:9}}
```

<!-- I think some more context around bytestring literals is called for if the topic is biased towards novices -->
The function body consists of a single function call to the `string::utf8` function and returns a `String` type. The expression is a bytestring literal `b"Hello World!"`.

## Compile the package

<!-- Why am I compiling? What does it meant to compile? -->

To compile the package, run the following command:

```bash
$ sui move build
```

<!-- Worth mentioning what happens if you don't see this output? -->

If you see output similar to the following, then the code compiled successfully:

```bash
> UPDATING GIT DEPENDENCY https://github.com/move-language/move.git
> INCLUDING DEPENDENCY MoveStdlib
> BUILDING Book
```

Congratulations! You've just compiled your first Move program. Now, let's add a test and some logging so we know that it works.
