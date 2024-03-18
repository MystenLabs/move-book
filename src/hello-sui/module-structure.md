# Using Objects

Let's take a look at the code we've inserted into the `postcard.move` file. We will discuss the structure of the module and the code in more detail, and explain the way the `Postcard` object is created, used and stored.

## Module

First line of the file is the module declaration. The address of the module is `package` - a name defined in the `Move.toml` file. The module name is also `postcard`. The module body is enclosed in curly braces `{}`.

```move
{{#include ../../postcard/sources/postcard.move:module}}
```

## Imports

In the top of the module we import types and other modules from the [Standard Library](./../basic-syntax/standard-library.md) (std) and from the [Sui Framework](./../programmability/sui-framework.md) (sui). The Sui Framework is required to define and create objects as it contains the `UID` and `TxContext` types - two essential types for objects.

We also import the `sui::transfer` module - this module contains storage and transfer functions.

```move
{{#include ../../postcard/sources/postcard.move:imports}}
```

## Postcard is an Object

A public struct `Postcard`, that goes after imports, is an object. A struct with the `key` ability is an object on Sui. As such, its first field must be `id` of type `UID` (that we imported from the Sui Framework). The `id` field is the unique identifier and an [address](../concepts/address.md) of the object.

<!-- TODO: better wording -->

```move
{{#include ../../postcard/sources/postcard.move:struct}}
```

## Creating an Object

Sui has [no global storage](./../concepts/object-model.md), and the objects are stored independently of their package. This is why we defined a single `Postcard` and not a collection "Postcards". Objects have to be created and stored in the storage before they can be used.

The `new` function is a public function that creates a new instance of the `Postcard` object and returns it to the caller. It takes two arguments: the message of type `String`, which is the message on the postcard, and the `ctx` of type `TxContext`, a standard type that is automatically inserted by the Sui runtime.

```move
{{#include ../../postcard/sources/postcard.move:new}}
```

When initializing an instance of `Postcard` we pass the fields of the struct as arguments, the `id` is generated from the `TxContext` argument via the `ctx.new()` call. And the `message` is taken as-is from the `message` argument.

## Sending a Postcard

Objects can't be ignored, so when the function `new` is called, the returned `Postcard` needs to be stored. And here's when the `sui::transfer` module comes into play. The `sui::transfer::transfer` function is used to store the object at the specified address.

```move
{{#include ../../postcard/sources/postcard.move:send_to}}
```

The function takes the `Postcard` as the first argument and a value of the `address` type as the second argument. Both are passed into the `transfer` function to send — and hence, store — the object to the specified address.

## Keeping the Object

A very common scenario is transfering the object to the caller. This can be done by calling the `send_to` function with the sender address. It can be read from the `ctx` argument, which is a `TxContext` type.

```move
{{#include ../../postcard/sources/postcard.move:keep}}
```

## Updating the Object

The `update` function is another public function that takes a mutable reference to the `Postcard` and a `String` argument. It updates the `message` field of the `Postcard`. Because the `Postcard` is passed by a reference, the owner is not changed, and the object is not moved.

```move
{{#include ../../postcard/sources/postcard.move:update}}
```

## Next steps

In the next section we will write a simple test for the `Postcard` module to see how it works. Later we will publish the package on Sui DevNet and learn how to use the Sui CLI to interact with the package.
