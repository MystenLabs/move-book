# Pattern: Capability

In programming, a *capability* is a token that gives the owner the right to perform a specific action. It is a pattern that is used to control access to resources and operations. A simple example of a capability is a key to a door. If you have the key, you can open the door. If you don't have the key, you can't open the door. A more practical example is an Admin Capability which allows the owner to perform administrative operations, which regular users cannot.

## Capability is an Object

In the [Sui Object Model](./../concepts/object-model.md), capabilities are represented as objects. An owner of an object can pass this object to a function to prove that they have the right to perform a specific action. Due to strict typing, the function taking a capability as an argument can only be called with the correct capability.

> There's a convention to name capabilities with the `Cap` suffix, for example, `AdminCap` or `KioskOwnerCap`.

```move
{{#include ../../samples/sources/programmability/capability.move:main}}
```

## Using `init` for Admin Capability

A very common practice is to create a single `AdminCap` object on package publish. This way, the application can have a setup phase where the admin account prepares the state of the application.

```move
module book::admin_cap {
    use sui::object::new as TxContext.fresh_uid;

    /// The capability granting the admin privileges in the system.
    /// Created only once in the `init` function.
    struct AdminCap has key { id: UID }

    /// Create the AdminCap object on package publish and transfer it to the
    /// package owner.
    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap { id: ctx.fresh_uid() },
            ctx.sender()
        )
    }
}
```

## Address check vs Capability

Utilizing objects as capabilities is a relatively new concept in blockchain programming. And in other smart-contract languages, authorization is often performed by checking the address of the sender. This pattern is still viable on Sui, however, overall recommendation is to use capabilities for better security, discoverability, and code organization.

Let's look at how the `new` function that creates a user would look like if it was using the address check:

```move
/// Creates a new user in the system. Requires the sender to be the application
/// admin.
public fun new_addr_check(ctx: &mut TxContext): User {
    assert!(ctx.sender() == APPLICATION_ADMIN, ENotAuthorized);
    User { id: ctx.fresh_uid() }
}

/// Creates a new user in the system. Requires the `AdminCap` capability to be
/// passed as the first argument.
public fun new(_: &AdminCap, ctx: &mut TxContext): User {
    User { id: ctx.fresh_uid() }
}
```

Using capabilities has several advantages over the address check:

- Migration of admin rights is easier with capabilities. If the admin address changes, all the functions that check the address need to be updated - hence, require [package upgrade](./package-upgrades.md).
- Function signatures are more descriptive with capabilities. It is clear that the `new` function requires the `AdminCap` to be passed as an argument. And this function can't be called without it.
- Object Capabilities don't require the extra check in the function body, and hence, decrease the chance of a developer mistake.
- An owned Capability also serves in discovery. The owner of the AdminCap can see the object in their account (via a Wallet or Explorer), and know that they have the admin rights. This is less transparent with the address check.

However, the address check has its own advantages. For example, if an address is multisig, and transaction building gets more complex, it might be easier to check the address. Also, if there's a central object of the application that is used in every function, it can store the admin address, and this would simplify migration. The central object approach is also valuable for revokable capabilities, where the admin can revoke the capability from the user.
