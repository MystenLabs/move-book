# Upgradeability Practices

To talk about best practices for upgradeability, we need to first understand what can be upgraded in
a package. The base premise of upgradeability is that an upgrade should not break public
compatibility with the previous version. The parts of the module which can be used in dependent
packages should not change their static signature. This applies to modules - a module can not be
removed from a package, public structs - they can be used in function signatures and public
functions - they can be called from other packages.

```move
// module can not be removed from the package
module book::upgradable {
    // dependencies can be changed (if they are not used in public signatures)
    use std::string::String;
    use sui::event; // can be removed

    // public structs can not be removed and can't be changed
    public struct Book has key {
        id: UID,
        title: String,
    }

    // public structs can not be removed and can't be changed
    public struct BookCreated has copy, drop {
        /* ... */
    }

    // public functions can not be removed and their signature can never change
    // but the implementation can be changed
    public fun create_book(ctx: &mut TxContext): Book {
        create_book_internal(ctx)

        // can be removed and changed
        event::emit(BookCreated {
            /* ... */
        })
    }

    // package-visibility functions can be removed and changed
    public(package) fun create_book_package(ctx: &mut TxContext): Book {
        create_book_internal(ctx)
    }

    // entry functions can be removed and changed as long they're not public
    entry fun create_book_entry(ctx: &mut TxContext): Book {
        create_book_internal(ctx)
    }

    // private functions can be removed and changed
    fun create_book_internal(ctx: &mut TxContext): Book {
        abort 0
    }
}
```

<!--
## Using entry and friend functions

TODO: Add a section about entry and friend functions
-->

## Versioning objects

<!-- This practice is for function version locking based on a shared state -->

To discard previous versions of the package, the objects can be versioned. As long as the object
contains a version field, and the code which uses the object expects and asserts a specific version,
the code can be force-migrated to the new version. Normally, after an upgrade, admin functions can
be used to update the version of the shared state, so that the new version of code can be used, and
the old version aborts with a version mismatch.

```move
module book::versioned_state {

    const EVersionMismatch: u64 = 0;

    const VERSION: u8 = 1;

    /// The shared state (can be owned too)
    public struct SharedState has key {
        id: UID,
        version: u8,
        /* ... */
    }

    public fun mutate(state: &mut SharedState) {
        assert!(state.version == VERSION, EVersionMismatch);
        // ...
    }
}
```

## Versioning configuration with dynamic fields

<!-- This practice is for versioning the contents / structure of objects -->

There's a common pattern in Sui which allows changing the stored configuration of an object while
retaining the same object signature. This is done by keeping the base object simple and versioned
and adding an actual configuration object as a dynamic field. Using this _anchor_ pattern, the
configuration can be changed with package upgrades while keeping the same base object signature.

```move
module book::versioned_config {
    use sui::vec_map::VecMap;
    use std::string::String;

    /// The base object
    public struct Config has key {
        id: UID,
        version: u16
    }

    /// The actual configuration
    public struct ConfigV1 has store {
        data: Bag,
        metadata: VecMap<String, String>
    }

    // ...
}
```

## Modular architecture

This section is coming soon!

<!-- TODO: add two patterns for modular architecture: object capability (SuiFrens) and witness registry (SuiNS) -->
