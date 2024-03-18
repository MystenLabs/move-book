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

TODO: public visibility

## Friend Visibility

TODO: friend visibility

## Package Visibility

TODO: 2024 `public(package)`
