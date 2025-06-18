# Visibility Modifiers

Every module member has a visibility. By default, all module members are _private_ - meaning they
are only accessible within the module they are defined in. However, you can add a visibility
modifier to make a module member _public_ - visible outside the module, or _public(package)_ -
visible in the modules within the same package, or _entry_ - can be called from a transaction but
can't be called from other modules.

## Internal Visibility

A function or a struct defined in a module which has no visibility modifier is _private_ to the
module. It can't be called from other modules.

```move
module book::internal_visibility;

// This function can be called from other functions in the same module
fun internal() { /* ... */ }

// Same module -> can call internal()
fun call_internal() {
    internal();
}
```

The following code will not compile:

<!-- TODO: add failure flag to example -->

```move
module book::try_calling_internal;

use book::internal_visibility;

// Different module -> can't call internal()
fun try_calling_internal() {
    internal_visibility::internal();
}
```

Note that just because a struct field is not visible from Move does not mean that its value is kept
confidential &mdash; it is always possible to read the contents of an on-chain object from outside
of Move. You should never store unencrypted secrets inside of objects.

## Public Visibility

A struct or a function can be made _public_ by adding the `public` keyword before the `fun` or
`struct` keyword.

```move
module book::public_visibility;

// This function can be called from other modules
public fun public_fun() { /* ... */ }
```

A public function can be imported and called from other modules. The following code will compile:

```move
module book::try_calling_public;

use book::public_visibility;

// Different module -> can call public_fun()
fun try_calling_public() {
    public_visibility::public_fun();
}
```

Unlike some languages, struct fields cannot be made public.

## Package Visibility

A function with _package_ visibility can be called from any module within the same package, but not
from modules in other packages. In other words, it is _internal_ to the package.

```move
module book::package_visibility;

public(package) fun package_only() { /* ... */ }
```

A package function can be called from any module within the same package:

```move
module book::try_calling_package;

use book::package_visibility;

// Same package `book` -> can call package_only()
fun try_calling_package() {
    package_visibility::package_only();
}
```

## Native Functions

Some functions in the [framework](./../programmability/sui-framework) and
[standard library](./standard-library) are marked with the `native` modifier. These functions are
natively provided by the Move VM and do not have a body in Move source code. To learn more about the
native modifier, refer to the
[Move Reference](./../../reference/functions?highlight=native#native-functions).

```move
module std::type_name;

public native fun get<T>(): TypeName;
```

This is an example from `std::type_name`, learn more about this module in the
[reflection chapter](./type-reflection).

## Further Reading

- [Visibility](./../../reference/functions#visibility) in the Move Reference.
