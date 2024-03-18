# Visibility Modifiers

Every module member has a visibility. By default, all module members are *private* - meaning they are only accessible within the module they are defined in. However, you can add a visibility modifier to make a module member *public* - visible outside the module, or *friend* - visible in "friend" modules within the same package, or *entry* - can be called from a transaction but can't be called from other modules.

## Internal Visibility

A function or a struct defined in a module which has no visibility modifier is *private*.

```move
module book::internal_visbility {
    // This function can be called from other functions in the same module
    fun internal() { /* ... */ }

    // Same module -> can call internal()
    fun call_internal() {
        internal();
    }
}
```

Move compiler won't allow this code to compile:

<!-- TODO: add failure flag to example -->

```move
module book::try_calling_internal {
    use book::internal_visbility;

    // Different module -> can't call internal()
    fun try_calling_internal() {
        internal_visbility::internal();
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

## Friend Visibility

Modules within the same package can be declared as *friends* to each other, and that enables the *friend visibility* modifier. A function with *friend visibility* can be called by friend modules. However, to the rest of the packages and non-friend modules, it is *private*.

```move
module book::friend_visibility {
    friend book::try_calling_friend;

    // This function can be called from friend modules
    public(friend) fun friend_only() { /* ... */ }
}
```

A friend function can be called from a friend module, but not from a non-friend module:

```move
module book::try_calling_friend {
    use book::friend_visibility;

    // Same package, friend module -> can call friend()
    fun try_calling_friend() {
        friend_visibility::friend_only();
    }
}
```

## Package Visibility

> This feature of Move 2024 is not yet implemented.

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
