# Visibility Modifiers

Every module member has a visibility. By default, all module members are *private* - meaning they are only accessible within the module they are defined in. However, you can add a visibility modifier to make a module member *public* - visible outside the module, or *public(package)* - visible in the modules within the same package, or *entry* - can be called from a transaction but can't be called from other modules.

## Internal Visibility

A function or a struct defined in a module which has no visibility modifier is *private* to the module. It can't be called from other modules.

```move
module book::internal_visibility {
    // This function can be called from other functions in the same module
    fun internal() { /* ... */ }

    // Same module -> can call internal()
    fun call_internal() {
        internal();
    }
}
```

<!-- Move compiler won't allow this code to compile: -->

<!-- TODO: add failure flag to example -->

```move
module book::try_calling_internal {
    use book::internal_visibility;

    // Different module -> can't call internal()
    fun try_calling_internal() {
        internal_visibility::internal();
    }
}
```

## Public Visibility

A struct or a function can be made *public* by adding the `public` keyword before the `fun` or `struct` keyword.

```move
module book::public_visibility {
    // This function can be called from other modules
    public fun public() { /* ... */ }
}
```

A public function can be imported and called from other modules. The following code will compile:

```move
module book::try_calling_public {
    use book::public_visibility;

    // Different module -> can call public()
    fun try_calling_public() {
        public_visibility::public();
    }
}
```

## Package Visibility

Move 2024 introduces the *package visibility* modifier. A function with *package visibility* can be called from any module within the same package. It can't be called from other packages.

```move
module book::package_visibility {
    public(package) fun package_only() { /* ... */ }
}
```

A package function can be called from any module within the same package:

```move
module book::try_calling_package {
    use book::package_visibility;

    // Same package `book` -> can call package_only()
    fun try_calling_package() {
        package_visibility::package_only();
    }
}
```
