---
description: "Migrate your Move code to the 2024 edition: module labels, let mut, public structs, method syntax, enums and match, macros, clever errors, and step-by-step instructions."
---

# Move 2024 Migration Guide

Move 2024 is the current edition of the Move language maintained by Mysten Labs, and the edition
this book teaches. This guide is written for readers migrating code - or knowledge - from the
original edition (referred to below as _Move 2020_): it lists what changed, feature by feature,
with a before-and-after example for each.

> This guide is a high-level overview. Every feature listed here has a dedicated section in the
> book, linked from its heading - refer to them for the full story.

## Using the 2024 Edition

The edition is specified in the `[package]` section of the [Package Manifest](./../concepts/manifest).
The stable `2024` edition is the default choice and the one to prefer; the `2024.beta` and
`2024.alpha` editions give early access to features that are still in development and may change:

```toml
[package]
name = "my_package"
edition = "2024"
```

## Migration Tool

The Move CLI has a migration tool that updates legacy code to the new edition. To use the migration
tool, run the following command in the package directory:

```bash
$ sui move migrate
```

The migration tool handles the mechanical changes: the `let mut` syntax, the `public` modifier on
structs, and the `public(package)` visibility in place of `friend` declarations.

## Module Label

_See [Module](./../move-basics/module#module-block)._

A module no longer needs to wrap its body in a block: the _module label_ syntax declares the module
once, and everything that follows belongs to it - saving a level of indentation in the entire file.
The block syntax is still supported, but only useful for declaring multiple modules in one file,
which is not a recommended practice:

```move
// Move 2020: module block
module book::my_module {
    public struct Book {}
}

// Move 2024: module label
module book::my_module;

public struct Book {}
```

## Mutable Bindings with `let mut`

_See [Primitive Types](./../move-basics/primitive-types#variables-and-assignment)._

Move 2024 requires the `mut` keyword to declare a variable that can be reassigned or mutably
borrowed. The compiler emits an error on an attempt to change a variable declared without `mut`:

```move
// Move 2020
let x: u64 = 10;
x = 20;

// Move 2024
let mut x: u64 = 10;
x = 20;
```

Additionally, the `mut` keyword is used in tuple destructuring and function arguments, placed
before the variable name:

```move
// takes by value and mutates
fun takes_by_value_and_mutates(mut v: Value): Value {
    v.field = 10;
    v
}

// in tuple destructuring
fun destruct() {
    let (mut x, y) = point::get_point();
}

// in struct unpack
fun unpack() {
    let Point { x, mut y } = point::get_point();
}
```

## Struct Visibility

_See [Custom Types with Struct](./../move-basics/struct#defining-a-struct)._

In Move 2024, struct declarations require a visibility modifier. Currently, the only available
visibility is `public`:

```move
// Move 2020
struct Book {}

// Move 2024
public struct Book {}
```

Note that `public` applies to the struct _type_ - the fields stay internal to the module, and only
the defining module can pack and unpack the struct, exactly as before.

## Friends Are Deprecated

_See [Visibility Modifiers](./../move-basics/visibility#package-visibility)._

The `friend` declarations and the `public(friend)` visibility are deprecated. In their place, the
`public(package)` visibility makes a function callable from any module of the same package - with
no declaration required. The `friend book::module_name;` statements are gone entirely:

```move
// Move 2020
friend book::friend_module;
public(friend) fun protected_function() {}

// Move 2024: no friend declaration needed
public(package) fun protected_function() {}
```

## Method Syntax

_See [Struct Methods](./../move-basics/struct-methods)._

Functions whose first argument is a type defined in the same module become _methods_ of that type,
callable with the dot syntax anywhere the type is used:

```move
public fun count(c: &Counter): u64 { /* ... */ }

fun use_counter(c: &Counter) {
    // Move 2020
    let count = counter::count(c);

    // Move 2024
    let count = c.count();
}
```

The standard library and the Sui Framework make full use of this: native and standard types come
with associated methods out of the box:

```move
// vector to string and ascii string
let str: String = b"Hello, World!".to_string();
let ascii: ascii::String = b"Hello, World!".to_ascii_string();

// address to bytes
let bytes = @0xa11ce.to_bytes();
```

## `use fun` and Method Aliases

_See [Struct Methods](./../move-basics/struct-methods#method-aliases)._

The `use fun` declaration associates a function with a type under a chosen method name. An alias
can be declared for any type locally to the module; or publicly - with `public use fun` - if the
type is defined in the same module:

```move
// Local: the type is foreign to the module
use fun my_custom_function as vector.do_magic;

// Exported: the type is defined in the same module
public use fun kiosk_owner_cap_for as KioskOwnerCap.kiosk;
```

## Index Syntax for Borrowing

_See [Vector](./../move-basics/vector#reading-elements) and
[Index Syntax](./../../reference/index-syntax) in the Move Reference._

Square brackets replace explicit `borrow` and `borrow_mut` calls on collection types:

```move
fun play_vec() {
    let mut v = vector[1, 2, 3, 4];
    let first = &v[0];         // calls vector::borrow(&v, 0)
    let first_mut = &mut v[0]; // calls vector::borrow_mut(&mut v, 0)
    let first_copy = v[0];     // calls *vector::borrow(&v, 0)
}
```

The syntax is supported by `vector` and the collection types of the Sui Framework: `VecMap`,
`Table`, `Bag`, `ObjectTable`, `ObjectBag`, and `LinkedTable`. A custom type can implement it by
marking its borrow functions with the `#[syntax(index)]` attribute:

```move
#[syntax(index)]
public fun borrow<T>(c: &List<T>, key: String): &T { /* ... */ }

#[syntax(index)]
public fun borrow_mut<T>(c: &mut List<T>, key: String): &mut T { /* ... */ }
```

## String Literals

_See [String](./../move-basics/string#string-literals)._

Move 2020 offered only byte-string literals, and constructing a `String` required an explicit
conversion. The new edition adds the string literal `"..."`, with the type _inferred_ from context -
it becomes a `String`, an `ascii::String`, or a `vector<u8>`, whichever is expected:

```move
// Move 2020: bytes, converted at runtime
let str: String = string::utf8(b"Hello");

// Move 2024: the literal is checked and typed at compile time
let str: String = "Hello";
let ascii: std::ascii::String = "ASCII";
```

The contents are validated at compile time: a literal used as an `ascii::String` must contain only
ASCII characters, or the code will not compile.

## Enums and `match`

_See [Enums and Match](./../move-basics/enum-and-match)._

Move 2024 introduces _enums_ - user-defined types with multiple variants - and the `match`
expression for handling them. Together they allow expressing varying data structures under a single
type, something previously emulated with multiple structs and runtime checks:

```move
/// One type - three different shapes of data.
public enum Segment has copy, drop {
    Empty,
    String(String),
    Special { content: vector<u8>, encoding: u8 },
}

public fun is_empty(s: &Segment): bool {
    match (s) {
        Segment::Empty => true,
        _ => false,
    }
}
```

The `match` expression is not limited to enums: it works on primitive values and structs as well,
requires the arms to be exhaustive, and supports the `_` wildcard for the remaining cases.

## Macros

_See [Macro Functions](./../move-basics/macros)._

Move 2024 introduces _macro functions_ - functions expanded at the call site during compilation,
which can take _lambdas_ as arguments. Macro names are followed by the `!` mark:

```move
// can be called as `for!(0, 10, |i| call(i));`
macro fun for($start: u64, $stop: u64, $body: |u64|) {
    let mut i = $start;
    let stop = $stop;
    while (i < stop) {
        $body(i);
        i = i + 1
    }
}
```

The familiar `assert!` is no longer special-cased compiler magic - it is a regular macro, and its
error-code argument is now optional. The standard library ships a rich set of macros which quickly
became the idiomatic way to write iteration:

```move
let v = vector[1, 2, 3];

// instead of a hand-written while loop:
let doubled = v.map!(|n| n * 2);
let sum = v.fold!(0, |acc, n| acc + n);
v.do!(|n| std::debug::print(&n));
```

## Abort Without a Code

_See [Aborting Execution](./../move-basics/assert-and-abort#omitting-the-abort-code)._

The abort code is now optional: a bare `abort` (and `assert!` without a second argument) derives
the code automatically, encoding the module and source line of the failure. It is a good fit for
branches that are not expected to be reachable:

```move
// Move 2020: a code was always required
if (!is_valid) abort 0;

// Move 2024
if (!is_valid) abort;
assert!(is_valid);
```

## Clever Errors

_See [Aborting Execution](./../move-basics/assert-and-abort#error-messages)._

Error constants marked with the `#[error]` attribute can carry a human-readable message - a
`vector<u8>` instead of a bare `u64`. On abort, tooling decodes the constant name, the message, and
the source line, removing the need to look up numeric codes:

```move
#[error]
const ENotAuthorized: vector<u8> = "The caller is not authorized to perform this action";

public fun protected_action(/* ... */) {
    assert!(is_authorized, ENotAuthorized);
}
```

## Extending Modules in Tests

_See [Extending Modules](./../testing/extend-foreign-module)._

The `extend module` declaration adds test-only members to an existing module - including a module
from a foreign package - with full access to its private types. It solves the long-standing problem
of testing against dependencies that ship no test utilities:

```move
#[test_only]
extend module pyth::price_info;

// Functions defined here can pack and unpack the private
// types of `pyth::price_info` - in tests only.
```

> Module extensions are still in development and currently require the `2024.alpha` edition.

## Further Reading

- [Move 2024 Migration Guide](https://blog.sui.io/move-2024-migration-guide) on the Sui Blog.
