# Pattern: Capability

In programming, a *capability* is a token that gives the owner the right to perform a specific action. It is a pattern that is used to control access to resources and operations. A simple example of a capability is a key to a door. If you have the key, you can open the door. If you don't have the key, you can't open the door. A more practical example is an Admin Capability which allows the owner to perform administrative operations, which regular users cannot.

## Capability is an Object

In the [Sui Object Model](./../concepts/object-model.md), capabilities are represented as objects. An owner of an object can pass this object to a function to prove that they have the right to perform a specific action. Due to strict typing, the function taking a capability as an argument can only be called with the correct capability.

```move
module book::capability {
    use std::string::String;

    use sui::object::new as TxContext.fresh_uid;

    /// The capability granting the application admin the right to create new
    /// accounts in the system.
    struct AdminCap has key, store { id: UID }

    /// The user account in the system.
    struct Account has key, store {
        id: UID,
        name: String
    }

    /// Creates a new account in the system. Requires the `AdminCap` capability
    /// to be passed as the first argument.
    public fun new(_: &AdminCap, name: String, ctx: &mut TxContext): Account {
        Account {
            id: ctx.fresh_uid(),
            name,
        }
    }
}
```
