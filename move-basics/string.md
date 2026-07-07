> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

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

```move
module book::custom_string;

/// Anyone can implement a custom string-like type by wrapping a vector.
public struct MyString {
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

```move
// The type of a string literal is inferred from the context:
// it can be a UTF-8 `String`...
let hello: std::string::String = "Hello";

// ...an ASCII `String`...
let ascii: std::ascii::String = "ASCII";

// ...or a plain vector of bytes.
let bytes: vector<u8> = "Hello";

// A byte string literal always yields a `vector<u8>`.
let bytes = b"Hello";

// So does a hex string literal: each pair of hex digits is one byte.
let bytes: vector<u8> = x"48656C6C6F"; // "Hello"
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

```move
// Special characters are written with the `\` escape: `\n` - newline,
// `\r` - carriage return, `\t` - tab, `\\` - backslash, `\"` - double
// quote, and `\xHH` - a byte written as two hex digits.
let escaped: std::string::String = "Quote: \"...\"\nNew line,\ttab, \\ and \x41 is 'A'";
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

```move
// the module is `std::string` and the type is `String`
use std::string::{Self, String};

// strings are normally created using the `utf8` function
// type declaration is not necessary, we put it here for clarity
let hello: String = string::utf8(b"Hello");

// The `.to_string()` alias on the `vector<u8>` is more convenient
let hello = b"Hello".to_string();
```

> The Sui execution environment automatically converts byte vectors into `String` in transaction
> inputs. As a result, in many cases, constructing a `String` directly within the
> [transaction](./../concepts/what-is-a-transaction) is unnecessary.

### Common Operations

The UTF-8 `String` provides a number of methods to work with strings. The most common operations on strings
are: concatenation, slicing, searching, and getting the length. Additionally, for custom string
operations, the `as_bytes()` method can be used to get the underlying byte vector.

```move
let mut str: String = "Hello,";
let another: String = " World!";

// `append(String)` adds the content to the end of the string.
str.append(another);
assert_eq!(str, "Hello, World!");

// `substring(start, end)` copies a slice of the string.
assert_eq!(str.substring(0, 5), "Hello");

// `index_of(&String)` returns the index of the first occurrence...
assert_eq!(str.index_of(&"World"), 7);

// ...or the length of the string if there is no occurrence.
assert_eq!(str.index_of(&"Rust"), str.length());

// Strings can be compared with `==` and `!=`; the comparison is
// done byte by byte.
assert!(str == "Hello, World!");

// `length()` returns the number of bytes in the string.
assert_eq!(str.length(), 13);

// Methods can also be chained! Get the length of a substring.
assert_eq!(str.substring(0, 5).length(), 5);

// `is_empty()` returns true if the string is empty.
assert_eq!(str.is_empty(), false);

// `as_bytes()` returns the underlying byte vector for custom operations.
let bytes: &vector<u8> = str.as_bytes();
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

```move
// Every unsigned integer type has a `to_string` method, which
// converts the number into its decimal representation.
assert_eq!(42u64.to_string(), "42");
assert_eq!(255u8.to_string(), "255");
assert_eq!(1000000u128.to_string(), "1000000");
```

### Safe UTF-8 Operations

The default `utf8` method may abort if the bytes passed into it are not valid UTF-8. If you are not
sure that the bytes you are passing are valid, you should use the `try_utf8` method instead. It
returns an `Option<String>`, which contains no value if the bytes are not valid UTF-8, and a string
otherwise.

> Hint: Functions with names starting with `try_*` typically return an `Option`. If the operation
> succeeds, the result is wrapped in `Some`. If it fails, the function returns `None`. This naming
> convention, commonly used in Move, is inspired by Rust.

```move
// `try_utf8` returns `Some(String)` if the bytes are valid UTF-8...
let hello = string::try_utf8(b"Hello");
assert_eq!(hello.is_some(), true);

// ...and `None` if they are not.
let invalid = string::try_utf8(b"\xFF");
assert_eq!(invalid.is_none(), true);

// The `.try_to_string()` alias on `vector<u8>` does the same.
let hello = b"Hello".try_to_string();
assert_eq!(hello.is_some(), true);
```

### UTF-8 Limitations

The `string` module does not provide a way to access individual characters in a string. This is
because UTF-8 is a variable-length encoding, and the length of a character can be anywhere from 1 to
4 bytes. Similarly, the `length()` method returns the number of bytes in the string, not the number
of characters.

```move
// `length()` returns the number of bytes, not characters!
let ascii_only: String = "hello"; // 5 characters, 5 bytes
let accented: String = "héllo"; // 5 characters, 6 bytes
let emoji: String = "🥳"; // 1 character, 4 bytes

assert_eq!(ascii_only.length(), 5);
assert_eq!(accented.length(), 6);
assert_eq!(emoji.length(), 4);
```

Byte positions matter for methods that take indices, such as `substring` and `insert`. These methods
validate character boundaries and abort if the specified index falls within the middle of a
character:

```move
#[test, expected_failure]
fun test_substring_aborts_mid_character() {
    let s: std::string::String = "héllo";
    // 'é' occupies bytes 1 and 2 - slicing through it aborts
    let _ = s.substring(0, 2);
}
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

```move
// The `.to_ascii_string()` alias on `vector<u8>` constructs an
// `ascii::String`; it aborts if any byte is not valid ASCII.
let hey = b"Hey".to_ascii_string();

// ASCII strings provide the same core operations as UTF-8 strings:
// `length`, `append`, `insert`, `substring`, `index_of`, and so on.
assert_eq!(hey.length(), 3);

// As well as some unique ones, like changing the case...
assert_eq!(hey.to_uppercase(), "HEY");
assert_eq!(hey.to_lowercase(), "hey");

// ...and checking if all characters are printable.
assert_eq!(hey.all_characters_printable(), true);

// An `ascii::String` can always be converted into a UTF-8 `String`,
let hey_utf8 = hey.to_string();

// and a UTF-8 `String` - into ASCII, if its contents allow it.
let hey_ascii = hey_utf8.to_ascii();
```

_See [full documentation for std::ascii][ascii-stdlib] module._

## Further Reading

- [std::string][string-stdlib] module documentation.
- [std::ascii][ascii-stdlib] module documentation.

[string-stdlib]: https://docs.sui.io/references/framework/std/string
[ascii-stdlib]: https://docs.sui.io/references/framework/std/ascii
