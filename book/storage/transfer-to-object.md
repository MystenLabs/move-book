# Receiving as Object

[Address owned](./storage-functions.md#transfer) Object state supports two types of owners: an
account and another Object. If an object was transferred to another object, Sui provides a way to
_receive_ this object through its owner's [`UID`][uid].

## Definition

Receiving functionality is implemented in the [`sui::transfer`][transfer] module. It consists of a
special type `Receiving` which is instantiated through a special transaction argument, and the
`receive` function which takes a [`UID`][uid] of the parent.

> Currently, `T` in the `transfer::receive` is a subject to [Internal Constraint][internal]. Public
> version of `receive` is called `public_receive`, and like other [storage functions][storage-funs]
> it requires `T` to have [`store`][store].

```move
module sui::transfer;

// An ephemeral wrapper around `Receiving` argument. Provided as a special input
// in a Transaction Block.
// Note: this type should be explicitly imported to be used!
public struct Receiving<phantom T: key> has drop {
    id: ID,
    version: u64,
}

/// Receive `T` from parent `UID` through special type `Receiving`.
public fun receive<T: key>(parent: &mut UID, to_receive: Receiving<T>): T;
```

Due to the `UID` type requirement, receiving cannot be performed on an arbitrary object that does
not provide access or special receiving implementation. This feature should be used be used with
caution and in a controlled setting.

## Example

As an illustration for _transfer_ and _receive_ consider an example: `PostOffice` allows registering
Post Boxes and sending to accounts' post boxes.

```move
module book::receiving;

use sui::derived_object;
use sui::transfer::Receiving; // not imported by default!

/// Base derivation object to create derived `PostBox`-es.
public struct PostOffice has key { id: UID }

/// Object with derived UID which receives objects sent to an address.
public struct PostBox has key { id: UID, owner: address }

/// Transfer functionality. Anyone can come to the PostOffice and send to a specific
/// recipient's PostBox. Items can be received from the `PostBox` by the recipient.
public fun send<T: key + store>(office: &PostOffice, parcel: T, recipient: address) {
    let postbox = derived_object::derive_address(office.id.to_inner(), recipient);
    transfer::public_transfer(parcel, postbox)
}

/// Receive the parcel. Requires the sender to be the owner of the `PostBox`!
public fun receive<T: key + store>(
    box: &mut PostBox,
    to_receive: Receiving<T>,
    ctx: &TxContext
): T {
    assert!(box.owner == ctx.sender());

    // Receive `to_receive` from `PostBox`.
    let parcel = transfer::public_receive(&mut box.id, to_receive);
    parcel
}

/// If user hasn't claimed their `PostBox` yet, create it.
/// Note: this is not a requirement for transferring assets!
/// Parcels can be sent even to unregistered post boxes, see `send` implementation.
public fun register_address(office: &mut PostOffice, ctx: &mut TxContext) {
    transfer::share_object(PostBox {
        id: derived_object::claim(&mut office.id, ctx.sender()),
        owner: ctx.sender()
    })
}

// Create a PostOffice on module publish.

fun init(ctx: &mut TxContext) {
    transfer::share_object(PostOffice { id: object::new(ctx) });
}
```

## Use Cases

Transferring to objects is a powerful feature which allows objects to act as owners of other
objects. One of the reasons to use it is the extra authorization performed upon receiving, eg the
`PostOffice` in the example above could charge a receiving fee.

- Allows parallel execution of transfers to multiple objects without referencing them in the
  transaction;
- Parent objects can also be transferred, acting as a container;
- PostBox-like applications, where user gets assets only after activating their account;
- Account abstraction-like applications where an object is mocking an account.

## Links

- [Transfer to Object](https://docs.sui.io/concepts/transfers/transfer-to-object) in Sui
  Documentation
- [`sui::transfer`][transfer] module documentation

[transfer]: https://docs.sui.io/references/framework/sui_sui/transfer
[key]: ./key-ability.md
[store]: ./store-ability.md
[uid]: ./uid-and-id.md
[internal]: ./internal-constraint.md
