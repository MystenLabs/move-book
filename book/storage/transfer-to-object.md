---
description: "Transfer to Object (TTO) in Sui: send objects to other objects and receive them using the Receiving type in Move."
---

# Receiving as Object

The [address owned](./storage-functions.md#transfer) object state supports two types of owners: an
account and another object. If an object was transferred to another object, Sui provides a way to
_receive_ this object through its owner's [`UID`][uid].

> This feature is also known as _"Transfer to Object"_ or TTO.

## Definition

Receiving functionality is implemented in the [`sui::transfer`][transfer] module. It consists of a
special type `Receiving` which is instantiated through a special transaction argument, and the
`receive` function which takes a [`UID`][uid] of the parent.

> The `T` in `transfer::receive` is subject to the [Internal Constraint][internal]. The public
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

Because `receive` requires a mutable reference to the parent's `UID`, receiving is only possible
through the module that defines the parent - or through the access it chooses to expose. An object
whose module provides no receiving implementation cannot release the objects sent to it, so this
feature should be used with caution and in a controlled setting.

## Example

As an illustration of _transfer_ and _receive_, consider a `PostOffice` that registers post boxes
and lets anyone send objects to them:

```move file=packages/samples/sources/storage/transfer-to-object.move anchor=main

```

## Use Cases

Transferring to objects is a powerful feature that lets objects act as owners of other objects,
and it enables designs that plain address ownership cannot express:

- **Controlled receiving.** Because receiving goes through the parent's module, extra logic can be
  attached to it - the `PostOffice` above could, for example, charge a fee for every received
  item.
- **Objects as containers.** A parent object collects assets sent to it and can itself be
  transferred, carrying its entire "inventory" along - without ever listing the contents in a
  transaction.
- **Deferred delivery.** Assets can be sent to an object before its owner is ready to claim them -
  a post-box that accumulates items until the user activates their account.
- **Account-like objects.** An object with an ID that receives and releases assets behaves much
  like an account, which makes TTO a building block for account-abstraction designs.

Sending _to an object_ is also naturally parallel: transfers to an object ID are plain transfers -
they do not reference the parent in the transaction, and therefore do not contend on it.

## Next Steps

This section concludes the Using Objects chapter: you can now define objects, place them into any
ownership state, manage their identity, and even make objects own other objects. The
[Advanced Programmability](./../programmability) chapter builds on all of it - starting with the
execution environment, and returning to object composition with
[Dynamic Fields](./../programmability/dynamic-fields), the second mechanism behind parent-child
object relationships.

## Further Reading

- [Transfer to Object](https://docs.sui.io/guides/developer/objects/transfers/transfer-to-object) in Sui
  Documentation
- [`sui::transfer`][transfer] module documentation

[transfer]: https://docs.sui.io/references/framework/sui/transfer
[key]: ./key-ability.md
[store]: ./store-ability.md
[uid]: ./uid-and-id.md
[internal]: ./internal-constraint.md
[storage-funs]: ./storage-functions.md
