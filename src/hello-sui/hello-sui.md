# Hello Sui!

Just like we did with the [Hello World](../your-first-move/hello-world.md) example, we will start by initializing a new package using the Sui CLI, then we will implement a simple application that creates a "Postcard" - a digital postcard that can be sent to a friend.

## Create a new Sui package

Sui packages are no different to regular Move packages, and can be initialized using the `sui` CLI. The following command will create a new package called `postcard`:

```bash
$ sui new postcard
```

This will create a new directory called `postcard` with the following structure:

```plaintext
postcard
├── Move.toml
├── src/
│   └── postcard.move
└── tests/
    └── postcard_tests.move
```

The package manifest - `Move.toml` - already contains all required dependencies for Sui, and the `src/postcard.move` file is pre-created with a simple module layout.

> In case the `Move.toml` file does not feature the `edition` field, please, add it manually. The `edition` field under the `[package]` section should be set to `2024.beta`.
>
> Like this: `edition = "2024.beta"`


## Implement the Postcard application

The Postcard application will be a simple module that defines an [object](./../concepts/object-model.md), and a set of functions to create, modify and send the postcard to any [address](./../concepts/address.md).

Let's start by inserting the code. Replace the contents of the `src/postcard.move` file with the following:

```move
{{#include ../../postcard/sources/postcard.move:all}}
```

To make sure that everything is working as expected, run this command:

```bash
$ sui move build
```

You should see this output, indicating that the package was built successfully. There shouldn't be any errors following the `BUILDING postcard` line:

```plaintext
> $ sui move build
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING postcard
```

If you do see errors, please, double check the code and the steps you've taken to create the package. It's very likely a typo in one of the commands.

## Next steps

[In the next section](./module-structure.md) we will take a closer look at the structure of the `postcard.move` file and explain the code we've just inserted. We will also discuss the imports and the object definition in more detail.
