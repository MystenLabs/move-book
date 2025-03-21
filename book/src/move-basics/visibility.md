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
public fun public() { /* ... */ }
```

A public function can be imported and called from other modules. The following code will compile:

```move
module book::try_calling_public {

use book::public_visibility;

// Different module -> can call public()
fun try_calling_public() {
    public_visibility::public();
}
```

Unlike some languages, struct fields cannot be made public.

## Package Visibility

Move 2024 introduces the _package visibility_ modifier. A function with _package visibility_ can be
called from any module within the same package. It can't be called from other packages.

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
