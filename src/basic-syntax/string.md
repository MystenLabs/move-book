# String

While Move does not have a built-in to represent strings, it does have a `string` module in the [Standard Library](./standard-library.md) that provides a `String` type. The `string` module represents UTF-8 encoded strings, and another module, `ascii`, provides an ASCII-only `String` type.

Sui execution environment also allows Strings as transaction arguments, so in many cases, String does not to be constructed in the [Transaction Block](./../concepts/what-is-a-transaction.md).

## Strings are bytes

No matter which type of string you use, it is important to know that strings are just bytes. The wrappers provided by the `string` and `ascii` modules are just that: wrappers. They do provide extra checks and functionality than a vector of bytes, but under the hood, they are just vectors of bytes.

```move
module book::string_bytes {
    /// Anyone can implement a custom string-like type by wrapping a vector.
    struct MyString {
        bytes: vector<u8>,
    }

    /// Implement a `from_bytes` function to convert a vector of bytes to a string.
    public fun from_bytes(bytes: vector<u8>): MyString {
        MyString { bytes }
    }

    /// Implement a `bytes` function to convert a string to a vector of bytes.
    public fun bytes(self: &MyString): &vector<u8> {
        &self.bytes
    }
}
```

Both standard types provide conversions from and to vectors of bytes.

## Working with UTF-8 Strings

While there are two types of strings in the standard library, the `string` module should be considered the default. It has native implementations of many common operations, and hence is more efficient than the `ascii` module. To create a string or perform operations on it, you must import the `string` module:

```move
module book::strings {
    use std::string::{Self, String};

    #[test]
    fun using_strings() {
        // strings are normally created using the `utf8` function
        let mut hello = string::utf8(b"Hello");
        let world = string::utf8(b", World!");

        // strings can be concatenated using the `append_utf8` function
        let hello_world = hello.append_utf8(*world.bytes());

        // just like any other type, strings can be compared
        assert!(hello_world == string::utf8(b"Hello, World!"), 0x0);
    }
}
```

## Safe UTF-8 Operations

The default `utf8` method is potentially unsafe, as it does not check that the bytes passed to it are valid UTF-8. If you are not sure that the bytes you are passing are valid UTF-8, you should use the `try_utf8` method instead. It returns an `Option<String>`, which is `None` if the bytes are not valid UTF-8:

> The `try_*` pattern is used throughout the standard library to indicate that a function may fail. For more information, see the [Error Handling](./error-handling.md) section.

```move
module book::safe_strings {
    use std::string::{Self, String};

    #[test]
    fun safe_strings() {
        // this is a valid UTF-8 string
        let hello = string::try_utf8(b"Hello");

        assert!(hello.is_some(), 0); // abort if the value is not valid UTF-8

        // this is not a valid UTF-8 string
        let invalid = string::try_utf8(b"\xFF");

        assert!(invalid.is_none(), 0); // abort if the value is valid UTF-8
    }
}
```

## ASCII Strings

TODO: ASCII strings

## Summary

TODO: summary
