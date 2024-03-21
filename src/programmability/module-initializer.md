# Module Initializer

A common case in many applications is to run some just once when the package is published. Imagine a simple store module that needs to create the main Store object when it is published. On Sui it is achieved by defining an `init` function in the module. The function will get automatically called when the module is published.

> All of the modules' `init` functions are called during publish. Currently, this only applies to publish command and not to [package upgrades](./package-upgrades.md).

```move
module book::store {
    use fun object.new as TxContext.fresh_uid;

    /// The Capability which grants the store owner the right to manage
    /// the store.
    struct StoreOwnerCap has key, store { id: UID }

    /// The store itself, one and only, created in the `init` function.
    struct Store has key {
        id: UID,
        /* ... */
    }

    // Will be called only once, when the module is published. Has to be
    // private, so it is not callable from the outside.
    fun init(ctx: &mut TxContext) {
        // transfer the StoreOwnerCap to the sender (publisher)
        transer::transfer(StoreOwnerCap {
            id: ctx.fresh_uid()
        }, ctx.sender());

        // share the Store object
        transfer::share_object(Store {
            id: ctx.fresh_uid()
        })
    }
}
```

In the same package another module can have its own `init` function with its own logic.

```move
// same package with the `store` module
module book::bank {
    use fun object.new as TxContext.fresh_uid;

    struct Bank has key {
        id: UID,
        /* ... */
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Bank {
            id: ctx.fresh_uid()
        })
    }
}
```

## `init` features

The function is called on publish, if it is present in the module and follows the rules:

- The function has to be named `init`, be private and have no return values.
- Takes one or two arguments: [One Time Witness](./one-time-witness.md) (optional) and [TxContext](./transaction-context.md). With `TxContext always being the last argument.

```move
fun init(ctx: &mut TxContext) { /* ... */}
fun init(otw: OTW, ctx: &mut TxContext) { /* ... */ }
```

TxContext can also be passed as immutable reference: `&TxContext`. However, practically speaking, it should always be `&mut TxContext` since the `init` function is the only place where new objects can be created, and it does not have access to existing objects.

## Trust and security

While `init` function can be used to create sensitive objects once, it is important to know that the same `AdminCap` can still be created in another function. Especially given that new functions can be added to the module during the upgrade. So the `init` function is a good place to set up the initial state of the module, but it is not a security measure on its own.

There are ways to guarantee that the object was created only once, such as the [One Time Witness](./one-time-witness.md). And there are ways to limit or disable the upgrade of the module, which we will cover in the [Package Upgrades](./package-upgrades.md) chapter.

## Next steps

As follows from the definition, the `init` function is guaranteed to be called only once when the module is published. So it is a good place to put the code that initializes module's objects and sets up the environment and configuration.

For example, if there's a [Capability](./capability.md) which is required for certain actions, it should be created in the `init` function. In the next chapter we will talk about the `Capability` pattern in more detail.
