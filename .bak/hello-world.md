Hello World!
Assuming you have already installed Sui and set up your IDE environment, let's jump right into it.

Create a New Package
To create a new program, we will use the sui move new command followed by the name of the application.

In this and other chapters, if you see the code blocks including $ (dollar sign), it means that the following command should be run in terminal. The sign should not be included. It's a common way of showing commands in the terminals.

sui move new hello_sui
The sui move command gives access to the Move CLI - a built in compiler and test runner environment. The new command followed by the name of the package will create a new package in a new folder. In our case, the folder name is hello_sui.

$ cd hello_sui
$ tree hello_sui
Directory Structure
Move CLI will create a scaffold of the application and pre-create all necessary files. Let's see what's inside.

hello-world
├── Move.toml
├── sources
│   └── hello-world.move
└── tests
    └── hello-world_tests.move
Manifest
The Move.toml file is called the package manifest, we will explain it in detail the concepts chapter. However, what is important to know is that it's the file that contains definitions and configuration for the package. Compiler uses it to read the package metadata, fetch dependencies and register named addresses. The latter you can see used in the source/hello_world.move module.

Sources
The sources/ directory contains the source files. Move source files have .move extension, and typically named after the module defined in the file. For example, in our case, the file name is hello_world and inside it Move CLI has already placed commented out structure:

/*
/// Module: hello_world
module hello_world::hello_world {

}
*/
The file names should usually match the name of the module. And the module name has to be a valid Move identifier: alphanumeric with underscores to separate words. A common convention is to call modules (and functions) in snake_case - all lowercase, with underscores. Coding conventions are important for readability and maintainability of the code, we summarize them in the Coding Conventions section.

Tests
The tests/ directory normally contains package tests. Compiler excludes these files in the regular build process, but includes in test and dev modes.

Other Folders
Also, compiler has built-in support for the examples/ folder, the files there are treated similarly to the ones places under the tests/ path - they're only built in the test and dev modes. And it is intended to be used for examples of usage of the package or its integration with other packages.

Compiling the Package
Move is a compiled language, and as such, it requires compilation of source files into Move Bytecode. The bytecode contains only necessary information about module, its members and types, and excludes comments and some identifiers (for example, for constants).

To demonstrate these features, let's replace the contents of the sources/hello_world.move file with the following:

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
During compilation the code is built but it's not run. A compiled package only offers functions which then can be called by other modules or in a transaction. We will explain these concepts in the Concepts chapter. But now, let's see what happens when we run the sui move build.

# run from the `hello_world` folder
$ sui move build

# alternatively, if you didn't `cd` into it
$ sui move build --path hello_world
The output would be:

TODO: insert out
During the compilation, Move Compiler automatically creates a build folder where it places all fetched and compiled dependencies as well as the bytecode for the modules of the current package.

If you're using a versioning system, such as Git, build folder should be ignored. For example, using a .gitignore file with build specified in it.

$ tree build
Running Tests
Before we get to testing, we should add a test. Move Compiler supports tests written in Move and provides the execution environment. The tests can be placed in both the source files and in the tests/ folder. Tests are marked with the #[test] attribute and are automatically discovered by the compiler. We explain tests in depth in the Testing section.

Replace the contents of the tests/hello_world_tests.move with the following content:

Here we import the hello_world module, and call its hello_world function to test that the output is indeed the string "Hello World!". Now, that we have tests in place, let's compile the package in the test mode and run tests. Move CLI has the test command for this:

# from `hello_world` folder
$ sui move test

# outside
$ sui move test --path hello_world
Next Steps
In this section we explained the basics of the Move package: its structure, the manifest, the build and test flows. On the next page, we will write an application and see how the code is structured and what the language can do.
