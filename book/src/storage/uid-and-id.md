# UID and ID

The `UID` type is defined in the `sui::object` module and is a wrapper around an `ID` which, in
turn, wraps the `address` type. The UIDs on Sui are guaranteed to be unique, and can't be reused
after the object was deleted.

```move
// File: sui-framework/sources/object.move
/// UID is a unique identifier of an object
public struct UID has store {
    id: ID
}

/// ID is a wrapper around an address
public struct ID has store, drop {
    bytes: address
}
```

## Fresh UID generation

- UID is derived from the `tx_hash` and an `index` which is incremented for each new UID.
- The `derive_id` function is implemented in the `sui::tx_context` module, and that is why TxContext
  is required for UID generation.
- Sui Verifier will not allow using a UID that wasn't created in the same function. That prevents
  UIDs from being pre-generated and reused after the object was unpacked.

New UID is created with the `object::new(ctx)` function. It takes a mutable reference to TxContext
(an auto substituted argument in public and entry functions), and returns a new UID.

```move
public fun new(ctx: &mut TxContext) {
    let uid: UID = object::new(ctx);
    uid.delete();
}
```

On Sui, `UID` acts as a representation of an object, and allows defining behaviors and features of
an object. One of the key-features - [Dynamic Fields](./../programmability/dynamic-fields.md) - is
possible because of the `UID` type being present in the programming model. Additionally, it allows
[receiving objects sent to an object](./transfer-to-object.md) which we will explain later in this
chapter.

## UID lifecycle

The `UID` type is created with the `object::new(ctx)` function, and it is destroyed with the
`object::delete(uid)` function. The `object::delete` consumes the UID _by value_, and it is
impossible to delete it unless the value was unpacked from an Object.

> Sui Verifier prohibits packing new structs with a "non-fresh" `UID`, which makes it impossible to
> reuse the same `UID` instance for different objects. But there's no restriction on storing it
> elsewhere.

```move
public fun pack_unpack(ctx: &mut TxContext) {
    let char = Character {
        id: object::new(ctx)
    };

    let Character { id } = char;
    id.delete();
}
```

## Keeping the UID

The `UID` does not need to be deleted immediately after the object struct is unpacked. Sometimes it
may carry [Dynamic Fields](./../programmability/dynamic-fields.md) or objects transferred to it via
[Transfer To Object](./transfer-to-object.md). In such cases, the UID may be kept and stored in a
separate object.

## ID

When talking about `UID` we should also mention the `ID` type. It is a wrapper around the `address`
type, and is used to represent an address-pointer. Usually, `ID` is used to point at an object,
however, there's no restriction, and no guarantee that the `ID` points to an existing object.

> ID can be received as a transaction argument in a
> [Transaction Block](./../concepts/what-is-a-transaction.md). Alternatively, ID can be created from
> an `address` value using `to_id()` function.

```move
public fun id_morph(ctx: &mut TxContext) {
    let uid: UID = object::new(ctx);

    // get `ID` from a `UID`
    let id: ID = uid.to_id();

    // get address from `UID`
    let addr: address = uid.to_address();
    // alternatively, do it from `ID`
    let addr: address = id.to_address();

    // and reverse: address->ID conversion
    let id = addr.to_id();
    // but we cannot create a `UID` from `ID` or `address`!

    // uid doesn't have drop and must be used or unpacked
    uid.delete();
}
```

## Proof of Deletion

The ability to return the UID of an object may be utilized in pattern called _proof of deletion_. It
is a rarely used technique, but it may be useful in some cases, for example, the creator or an
application may incentivize the deletion of an object by exchanging the deleted IDs for some reward.

In framework development this method could be used to ignore / bypass certain restrictions on
"taking" the object. If there's a container that enforces certain logic on transfers, like Kiosk
does, there could be a special scenario of skipping the checks by providing a proof of deletion.

An example implementation of this pattern is as follows:

```move
module book::proof_of_deletion;

/// A Hot-Potato struct which serves an as obligation to unpack an object
/// and show its underlying UID.
public struct Promise(ID);

/// Present an object and receive an obligation to unpack it.
public fun show<T: key>(t: &T): Promise {
    // do some restricted logic, eg mint a Coin
    // or create a Capability

    Promise(object::id(t))
}

/// Prove that the object was unpacked by presenting its `UID` *by value*!
public fun prove_deletion(p: Promise, uid: UID) {
    let Promise(id) = p;
    assert!(id == uid.to_id());

    // in this example we delete, but it could be safely returned
    // to the sender, because we already confirmed `T` unpacking
    uid.delete();
}
```

This is one of the open topics for exploration and research. The pattern has a lot of potential and may find its application one day!

## fresh_object_address

TxContext provides the `fresh_object_address` function which can be utilized to create unique
addresses and `ID` - it may be useful in some application that assign unique identifiers to user
actions - for example, an order_id in a marketplace.
