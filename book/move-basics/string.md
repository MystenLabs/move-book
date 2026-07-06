---
description: "Strings in Move: string literals, the UTF-8 and ASCII String types, common operations, and conversions between them in Sui smart contracts."
---

# String

While Move does not have a built-in type to represent strings, it does have two standard
implementations for strings in the [Standard Library](./standard-library). The `std::string` module
defines a `String` type and methods for UTF-8 encoded strings, and the second module, `std::ascii`,
provides an ASCII `String` type and its methods.

> Both types are named `String`, which may be confusing at first. When the distinction matters, we
> refer to them by their module: `string::String` and `ascii::String`. In most application code, the
> UTF-8 `string::String` is the type to use.

## Strings Are Bytes

No matter which type of string you use, it is important to know that strings are just bytes. The
wrappers provided by the `string` and `ascii` modules are just that: wrappers. They do provide
safety checks and methods to work with strings, but at the end of the day, they are just vectors of
bytes.

```move file=packages/samples/sources/move-basics/string.move anchor=custom

```

Both standard string types follow this exact pattern - a struct holding a `vector<u8>`. What makes
them different from a plain byte vector, and from each other, is the _guarantee_ they carry about
the contents:

- `ascii::String` guarantees that every byte is a valid ASCII character. ASCII is the oldest and
  simplest character encoding: it defines 128 characters - Latin letters, digits, and punctuation -
  and each character takes exactly one byte.
- `string::String` guarantees that the bytes are valid UTF-8. UTF-8 is the modern standard encoding:
  it can represent any Unicode character - alphabets, hieroglyphs, emoji - using one to four bytes
  per character.

UTF-8 is backward compatible with ASCII: every ASCII string is also a valid UTF-8 string, but not
the other way around.

## String Literals

A [literal](./expression#literals) is a value written directly in the source code. Move offers two
syntaxes for writing strings: the string literal `"..."` and the byte string literal `b"..."`. The
byte string always yields a `vector<u8>`, while the type of a string literal is _inferred_ from the
context - it becomes whichever of the three byte-carrying types (`vector<u8>`, `string::String`, or
`ascii::String`) the compiler expects in that spot:

```move file=packages/samples/sources/move-basics/string.move anchor=literals

```

The compiler also checks the contents of the literal against the expected type at compile time. A
string literal used as an `ascii::String` must contain only ASCII characters, and the following code
will not compile:

```move
let s: std::ascii::String = "héllo";
//                          ^ error! 'é' is not a valid ASCII character
```

If the compiler cannot tell the type from the context, the literal defaults to `vector<u8>`, and a
warning is emitted. This is also why a method cannot be called directly on a bare literal -
`"Hello".to_string()` does not compile, because the compiler cannot infer the type of the literal
before resolving the method. A `vector<u8>` is not yet a string - both string modules provide
functions to convert bytes into strings at runtime, which we show below.

### Escape Sequences

Some characters cannot be typed into a literal directly: a newline, a tab, or the `"` character
itself, which would end the literal. Like most languages, Move uses the backslash `\` to _escape_
special characters. Arbitrary bytes can also be written as `\x` followed by two hex digits.

```move file=packages/samples/sources/move-basics/string.move anchor=escapes

```

## Working with UTF-8 Strings

While there are two types of strings in the standard library, the `string` module should be
considered the default. It has native implementations of many common operations, leveraging
low-level, optimized runtime code for superior performance. In contrast, the `ascii` module is fully
implemented in Move, relying on higher-level abstractions and making it less suitable for
performance-critical tasks.

### Definition

The `String` type in the `std::string` module is defined as follows:

```move
module std::string;

/// A `String` holds a sequence of bytes which is guaranteed to be in utf8 format.
public struct String has copy, drop, store {
    bytes: vector<u8>,
}
```

_See [full documentation for std::string][string-stdlib] module._

### Creating a String

A string literal, as shown above, is the most common way to create a `String`. Alternatively, an
existing `vector<u8>` can be turned into a `String` at runtime with the `string::utf8` function, or
its convenient alias `.to_string()` on the `vector<u8>` type. Both abort if the bytes are not valid
UTF-8.

```move file=packages/samples/sources/move-basics/string.move anchor=utf8

```

> The Sui execution environment automatically converts byte vectors into `String` in transaction
> inputs. As a result, in many cases, constructing a `String` directly within the
> [transaction](./../concepts/what-is-a-transaction) is unnecessary.

### Common Operations

The UTF-8 `String` provides a number of methods to work with strings. The most common operations on strings
are: concatenation, slicing, searching, and getting the length. Additionally, for custom string
operations, the `as_bytes()` method can be used to get the underlying byte vector.

```move file=packages/samples/sources/move-basics/string.move anchor=common_ops

```

Note the behavior of `index_of` when there is no occurrence: instead of aborting or returning an
`Option`, it returns the length of the string - an index just past the last byte. Also note what is
_not_ on the list: Move has no string interpolation or formatting, and no way to split a string by a
separator. Strings in a smart contract are typically stored and displayed, not parsed.

> Older code may use the `sub_string` and `bytes` functions - they are deprecated aliases of
> `substring` and `as_bytes`.

### Converting Numbers to Strings

A common practical task is building a string out of numbers - for a name, a label, or an error
message. Every unsigned integer type has a `to_string` method that converts the number into its
decimal representation.

```move file=packages/samples/sources/move-basics/string.move anchor=number_to_string

```

### Safe UTF-8 Operations

The default `utf8` method may abort if the bytes passed into it are not valid UTF-8. If you are not
sure that the bytes you are passing are valid, you should use the `try_utf8` method instead. It
returns an `Option<String>`, which contains no value if the bytes are not valid UTF-8, and a string
otherwise.

> Hint: Functions with names starting with `try_*` typically return an `Option`. If the operation
> succeeds, the result is wrapped in `Some`. If it fails, the function returns `None`. This naming
> convention, commonly used in Move, is inspired by Rust.

```move file=packages/samples/sources/move-basics/string.move anchor=safe_utf8

```

### UTF-8 Limitations

The `string` module does not provide a way to access individual characters in a string. This is
because UTF-8 is a variable-length encoding, and the length of a character can be anywhere from 1 to
4 bytes. Similarly, the `length()` method returns the number of bytes in the string, not the number
of characters.

```move file=packages/samples/sources/move-basics/string.move anchor=limitations

```

Byte positions matter for methods that take indices, such as `substring` and `insert`. These methods
validate character boundaries and abort if the specified index falls within the middle of a
character:

```move file=packages/samples/sources/move-basics/string.move anchor=substring_abort

```

> One more consequence of "strings are bytes": two strings that look identical on screen may have
> different byte representations. For example, "é" can be encoded as a single character or as "e"
> followed by a combining accent mark - they render the same, but compare as different, because `==`
> compares bytes, not what the reader sees.

## ASCII Strings

The `ascii::String` type is a good fit for values that are known to be plain Latin letters, digits,
and punctuation: tickers, symbols, identifiers, or URLs. For example, the
[Sui Framework](./../programmability/sui-framework) uses `ascii::String` for the `symbol` field of
the `CoinMetadata` type.

What the ASCII encoding lacks in expressiveness, it makes up for in simplicity: every character is
exactly one byte. This lifts the limitations of UTF-8 strings - `ascii::String` allows operating on
individual characters (represented by the `ascii::Char` type), and offers methods that would be
ambiguous for UTF-8, such as changing the case of a string.

An ASCII string is created the same way as a UTF-8 one: with a string literal, or by converting a
`vector<u8>` at runtime - this time with the `ascii::string` function or the `.to_ascii_string()`
alias on `vector<u8>`. There is a `try_string` counterpart as well, following the same `try_*`
convention described above.

The two string types can be converted into one another. Since every ASCII string is also valid
UTF-8, `to_string()` on an `ascii::String` always succeeds; the reverse conversion - `to_ascii()` -
aborts if the string contains non-ASCII characters.

```move file=packages/samples/sources/move-basics/string.move anchor=ascii

```

_See [full documentation for std::ascii][ascii-stdlib] module._

## Further Reading

- [std::string][string-stdlib] module documentation.
- [std::ascii][ascii-stdlib] module documentation.

[string-stdlib]: https://docs.sui.io/references/framework/std/string
[ascii-stdlib]: https://docs.sui.io/references/framework/std/ascii
