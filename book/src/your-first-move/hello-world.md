# Hello, World!

This chapter will guide you through the process using the Move CLI to create a new package, write a simple module, compile it, and run tests. It is expected that you have already [installed Sui](./../before-we-begin/install-sui.md) and set up your [IDE environment](./../before-we-begin/ide-support.md).

The structure of the chapter is as follows:

- [Create a New Package](#create-a-new-package)
- [Directory Structure](#directory-structure)
- [Compiling the Package](#compiling-the-package)
- [Running Tests](#running-tests)

## Create a New Package

To create a new program, we will use the `sui move new` command followed by the name of the application. Our first program will be called `hello_world`.

> Note: In this and other chapters, if you see the code blocks with lines starting with `$` r(dollar sign), it means that the following command should be run in terminal. The sign should not be included. It's a common way of showing commands in the terminal.

```bash
sui move new hello_world
```

The `sui move` command gives access to the Move CLI - a built-in compiler, test runner and a utility for all things Move. The `new` command followed by the name of the package will create a new package in a new folder. In our case, the folder name is "hello_world".

```bash
$ cd hello_world
```

We can view the contents of the folder to see that the package was created successfully.

```bash
$ ls -l hello_world
```

## Directory Structure

Move CLI will create a scaffold of the application and pre-create the directory structure and all necessary files. Let's see what's inside.

```plaintext
hello-world
├── Move.toml
├── sources
│   └── hello-world.move
└── tests
    └── hello-world_tests.move
```

## Manifest

The `Move.toml` file is called the [package manifest](./../concepts/manifest.md), we will explain it in detail the [concepts chapter](./../concepts). However, what is important to know is that it is the file that contains definitions and configuration for the package. Compiler uses it to read the package metadata, fetch dependencies and register _named addresses_. By default, the package features one named address - the name of the package.

```toml
[addresses]
hello_world = "0x0"
```

## Sources

The `sources/` directory contains the source files. Move source files have _.move_ extension, and typically named after the module defined in the file. For example, in our case, the file name is _hello_world.move_ and inside it Move CLI has already placed commented out code:

```move
/*
/// Module: hello_world
module hello_world::hello_world {

}
*/
```

> The `/*` and `*/` are the comment delimiters in Move. Everything in between is ignored by the compiler and can be used for documentation or notes. We explain all ways to comment the code in the [Basic Syntax](./../move-basics/comments.md).

The commented out code is a module definition, it starts with the keyword `module` followed by a named address (or an address literal), and the module name. The module name is a unique identifier for the module and has to be unique within the package. The module name is used to reference the module from other modules or transactions.

<!-- And the module name has to be a valid Move identifier: alphanumeric with underscores to separate words. A common convention is to call modules (and functions) in snake_case - all lowercase, with underscores. Coding conventions are important for readability and maintainability of the code, we summarize them in the Coding Conventions section. -->

## Tests

The `tests/` directory contains package tests. Compiler excludes these files in the regular build process, but uses them in _test_ and _dev_ modes. The tests are written in Move and are marked with the `#[test]` attribute, tests can be grouped in a separate module (then it's usually called _module_name_tests.move_), or inside the module they're testing.

The _hello_world_tests.move_ file contains a commented out test:

```move
/*
#[test_only]
module hello_world::hello_world_tests {
    // uncomment this line to import the module
    // use hello_world::hello_world;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_hello_world() {
        // pass
    }

    #[test, expected_failure(abort_code = hello_world::hello_world_tests::ENotImplemented)]
    fun test_hello_world_fail() {
        abort ENotImplemented
    }
}
*/
```

## Other Folders

Additionally, Move CLI supports `examples/` folder. The files there are treated similarly to the ones places under the tests/ path - they're only built in the _test_ and _dev_ modes. And it is intended to be used for examples of usage of the package or its integration with other packages. It's mostly used for documentation purposes and for library packages.

## Compiling the Package

Move is a compiled language, and as such, it requires compilation of source files into Move Bytecode. The bytecode contains only necessary information about module, its members and types, and excludes comments and some identifiers (for example, for constants).

To demonstrate these features, let's replace the contents of the sources/hello_world.move file with the following:

```move
/// The module `hello_world` under named address `hello_world`.
/// The named address is set in the `Move.toml`.
module hello_world::hello_world {
    // Imports the `String` type from the Standard Library
    use std::string::String;

    /// Returns the "Hello World!" as a `String`.
    public fun hello_world(): String {
        b"Hello World!".to_string()
    }
}
```

During compilation the code is built but it's not run. A compiled package only offers functions which then can be called by other modules or in a transaction. We will explain these concepts in the Concepts chapter. But now, let's see what happens when we run the sui move build.

```bash
# run from the `hello_world` folder
$ sui move build

# alternatively, if you didn't `cd` into it
$ sui move build --path hello_world
```

<!-- The output would be: -->
<!-- TODO: insert out -->


## Running Tests

During the compilation, Move Compiler automatically creates a build folder where it places all fetched and compiled dependencies as well as the bytecode for the modules of the current package.

> If you're using a versioning system, such as Git, build folder should be ignored. For example, using a `.gitignore` file with `build` added to it.

```bash
$ tree build
Running Tests
```

Before we get to testing, we should add a test. Move Compiler supports tests written in Move and provides the execution environment. The tests can be placed in both the source files and in the tests/ folder. Tests are marked with the #[test] attribute and are automatically discovered by the compiler. We explain tests in depth in the Testing section.

<!-- Replace the contents of the tests/hello_world_tests.move with the following content: -->

Here we import the hello_world module, and call its hello_world function to test that the output is indeed the string "Hello World!". Now, that we have tests in place, let's compile the package in the test mode and run tests. Move CLI has the test command for this:

```bash
# from `hello_world` folder
$ sui move test

# outside
$ sui move test --path hello_world
```

## Next Steps

In this section we explained the basics of the Move package: its structure, the manifest, the build and test flows. [On the next page](), we will write an application and see how the code is structured and what the language can do.

## Further Reading

- [Package Manifest](./../concepts/manifest.md) section
- Package in [The Move Reference](/reference/packages.html)

## Summary

In this chapter, we have created a new package, explained its structure and contents, and compiled it. We have also added a test and ran it. In the next chapter, we will write a simple application and see how the code is structured and what the language can do.
