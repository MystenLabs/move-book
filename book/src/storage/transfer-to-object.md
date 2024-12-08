# Transfer to Object

Previously, we have explained how [transfer](./storage-functions.md#transfer) works in relation to
accounts. However, there is an additional behaviour allowed by the
[Sui Object Model](./../object/object-model.md) - transferring objects to other objects. If certain
conditions are met (which we explain in this section), objects can be sent to and _received_ from
other objects.

<div class="warning">

Warning: recipient object must be implemented in a way that allows receiving. Attempt to send an
object to an object that does not implement receiving can result in asset loss.

</div>

## Background

Every object in Sui has its own `UID` which is represented by the
[address type](./../move-basics/address.md). This address can be used to query the object's data,
and to perform account queries, such as getting the list of owned objects. This property of the
system lays the foundation for the transfer to object feature.

> In this section, by _object address_ we mean the address value stored in the `UID` of the object.

## Transfer to Object

An object can be transferred to another object by calling the `transfer` function, or its public
version - `public_transfer`. The behaviour is identical to the transfer to account.

```move
// File: sui-framework/sources/transfer.move
module sui::transfer;

public fun transfer<T: key>(object: T, recipient: address) {}
public fun public_transfer<T: key + store>(object: T, recipient: address) {}
```

## Receiving Objects

While objects _owned by accounts_ can be used in the transaction directly (given that the sender of
the transaction is the owner), objects transferred to other objects first need to be _received_
through their owner. The owner object needs to implement a custom function that will call the
`receive` function from the `transfer` module.

```move
// File: sui-framework/sources/transfer.move
module sui::transfer;

/// Special type which cannot be constructed in Move but can be passed as a
/// special input to a PTB.
public struct Receiving<phantom T: key> has drop {
    id: ID,
    version: u64,
}

/// Private receiving function for `key`-only objects.
public fun receive<T: key>(parent: &mut UID, to_receive: Receiving<T>): T { /* ... */ }

/// Public receiving function for `key + store` objects.
public fun public_receive<T: key + store>(parent: &mut UID, to_receive: Receiving<T>): {
  /* ... */
}
```

The `Receiving` type is a special type that references an object-owned object. It cannot be
constructed in Move, and can only be passed as a special input to a
[Programmable Transaction Block (PTB)](../concepts/what-is-a-transaction.md). The `receive` (or
`public_receive`) function must be called in order to exchange the `Receiving` instance for the
actual object.

While this may seem overwhelming, we will demonstrate the feature in a simple example.

## Example

To demonstrate the feature, let's consider a simple `PostOffice` object that can receive any objects
transferred to it. Given that the transfer itself can be performed on the PTB level, or in a Move
function, we will focus on the receiving part.

```move
module book::post_office;

// While the `sui::transfer` module is implicitly imported, the `Receiving` type
// is not. We need to import it explicitly.
use sui::transfer::Receiving;

/// The `PostOffice` object that can receive any objects transferred to it via
/// a custom `receive` function.
public struct PostOffice has key {
    id: UID,
}

/// Voila! The `receive` function can now be called on the `PostOffice` object
/// to receive any objects transferred to it.
public fun public_receive<T: key + store>(
    po: &mut PostOffice,
    to_receive: Receiving<T>
): T {
    transfer::public_receive(&mut po.id, to_receive)
}

/// For objects without `store` (though, they would require special handling), we
/// can implement the non-public version of the `receive` function.
public fun receive<T: key>(po: &mut PostOffice, to_receive: Receiving<T>): T {
    transfer::receive(&mut po.id, to_receive)
}
```

In this example, we have defined a `PostOffice` object that can receive any objects transferred to
it. We ommitted the creation of the `PostOffice` for brevity; additionally, an implementation like
this would require some authorization to prevent unauthorized claims. We talk about authorization
patterns in the [Advanced Programmability](./../programmability/) chapter.

## Limitations

Transfer to Object must be used with caution, as the recipient object must be implemented in a way
that allows receiving. Worth noting, that objects owned by other objects must be taken by value, and
cannot be borrowed as references, unlike objects owned by accounts.

Transfer to Object is not the only way to create a relationship between objects. There are more
flexible and feature-rich ways, such as the
[Dynamic Fields](./../programmability/dynamic-fields.md), which we explore in the
[Advanced Programmability](./../programmability/) chapter.

## Summary

- Objects can be transferred to other objects by calling the `transfer` function.
- The recipient object must be able to `receive` transferred objects, otherwise the objects may be
  lost.
- The `Receiving` type is a special type that references an object-owned object. It is passed as a
  special input to a transaction and cannot be constructed dynamically.
- Once received, the object can be used normally, including being transferred again, even to the
  same parent object.
