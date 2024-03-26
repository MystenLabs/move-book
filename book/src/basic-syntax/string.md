# String

While Move does not have a built-in to represent strings, it does have a `string` module in the [Standard Library](./standard-library.md) that provides a `String` type. The `string` module represents UTF-8 encoded strings, and another module, `ascii`, provides an ASCII-only `String` type.

Sui execution environment also allows Strings as transaction arguments, so in many cases, String does not to be constructed in the [Transaction Block](./../concepts/what-is-a-transaction.md).

## Bytestring Literal

TODO:

- reference vector
- reference literals - [Expression](./expression.md#literals)

## Strings are bytes

No matter which type of string you use, it is important to know that strings are just bytes. The wrappers provided by the `string` and `ascii` modules are just that: wrappers. They do provide extra checks and functionality than a vector of bytes, but under the hood, they are just vectors of bytes.

```move
{{#include ../../../packages/samples/sources/basic-syntax/string.move:custom}}
```

Both standard types provide conversions from and to vectors of bytes.

## Working with UTF-8 Strings

While there are two types of strings in the standard library, the `string` module should be considered the default. It has native implementations of many common operations, and hence is more efficient than the `ascii` module. To create a string or perform operations on it, you must import the `string` module:

```move
{{#include ../../../packages/samples/sources/basic-syntax/string.move:utf8}}
```

## Safe UTF-8 Operations

The default `utf8` method is potentially unsafe, as it does not check that the bytes passed to it are valid UTF-8. If you are not sure that the bytes you are passing are valid UTF-8, you should use the `try_utf8` method instead. It returns an `Option<String>`, which is `None` if the bytes are not valid UTF-8:

> The `try_*` pattern is used throughout the standard library to indicate that a function may fail. For more information, see the [Error Handling](./error-handling.md) section.

```move
{{#include ../../../packages/samples/sources/basic-syntax/string.move:safe_utf8}}
```

## ASCII Strings

TODO: ASCII strings

```move
{{#include ../../../packages/samples/sources/basic-syntax/string.move:ascii}}
```

## Summary

TODO: summary
