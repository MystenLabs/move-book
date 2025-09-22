# UID and ID

The use of the `UID` type is required by the Sui Verifier on all types that have the
[`key`](./key-ability.md) ability. Here we go deeper into `UID` and its usage.

## Definition

The `UID` type is defined in the `sui::object` module and is a wrapper around an `ID` which, in
turn, wraps the `address` type. The UIDs on Sui are guaranteed to be unique, and can't be reused
after the object was deleted.

```move
module sui::object;

/// UID is a unique identifier of an object
public struct UID has store {
    id: ID
}

/// ID is a wrapper around an address
public struct ID has store, drop {
    bytes: address
}
```

## Fresh UID Generation

- `UID` is _derived_ from the `tx_hash` and an `index` which is incremented for each new UID.
- The `derive_id` function is implemented in the `sui::tx_context` module, and that is why
  [TxContext](./../programmability/transaction-context.md) is required for `UID` generation.
- Sui Verifier will not allow using a UID that wasn't created in the same function. That prevents
  UIDs from being pre-generated or reused after the object was unpacked.

New UID is created with the `object::new` function. It takes a mutable reference to `TxContext`, and
returns a new `UID`.

```move
public fun uid(ctx: &mut TxContext) {
  let id = object::new(ctx); // Create a fresh UID from TxContext.
  id.delete(); // Delete the UID.
}
```

`UID` acts as a representation of an object, and allows defining behaviors and features of an
object. One of the key features - [Dynamic Fields](./../programmability/dynamic-fields) - is
possible because of the `UID` type being explicit. Additionally, it allows receiving objects sent to
other objects. This feature is called [Transfer to Object (TTO)](./transfer-to-object.md), and we
will explain later in this chapter.

## UID Derivation

Sui allows deriving UID's from other UIDs using _derivation keys_. This functionality is implemented
in the [`sui::derived_object`][derived-object] module and allows generating predictable and
deterministic `UIDs` for easier off-chain discovery. UID for each pair of parent + key can be
generated only once!

```move
use sui::derived_object;

/// Some central application object.
public struct Base has key { id: UID }

/// Derived Object.
public struct Derived has key { id: UID }

/// Create and share a new Derived object using `address` as a `key`.
public fun derive(base: &mut Base, key: address) {
    let id = derived_object::claim(&mut base.id, key);
    transfer::share_object(Derived { id })
}
```

Derived addresses reduce the load on off-chain indexers, since it is enough to store the ID of the
parent object and get derived IDs using a derivation function. ID derivation function is part of the
most SDKs, and also present in Move:

```move
module sui::derived_object;

/// Checks if a UID was derived with `key` at `parent`.
public fun exists<K: copy + drop + store>(parent: &UID, key: K): bool;

/// Derive inner `address` of a UID, regardless of whether it was created.
public fun derive_address<K: copy + drop + store>(parent: ID, key: K): address;
```

The same derivation functionality is used to generate UIDs of
[dynamic fields](./../programmability/dynamic-fields.md).

## UID Lifecycle

The `UID` type is created with the `object::new` function, and deleted with the `object::delete`
function. The `object::delete` consumes the UID _by value_, hence, it is only possible to delete
object's UID after the object [was unpacked](./../move-basics/struct.md#unpacking-a-struct).

```move
public struct Character has key { id: UID }

public fun character(ctx: &mut TxContext) {
    // Instantiate `Character` object.
    let char = Character { id: object::new(ctx) };

    // Unpack object to get its UID.
    let Character { id } = char;

    // Delete the UID.
    id.delete();
}
```

## Keeping the UID

The `UID` does not need to be deleted immediately after the object struct is unpacked. Sometimes it
may carry [Dynamic Fields](./../programmability/dynamic-fields) or objects transferred to it via
[Transfer To Object](./transfer-to-object.md). In such cases, the UID may be kept and stored in a
separate object.

## Proof of Deletion

The ability to return the UID of an object may be utilized in pattern called _proof of deletion_. It
is a rarely used technique, but it may be useful in some cases, for example, the creator or an
application may incentivize the deletion of an object by exchanging the deleted IDs for some reward.

In framework development this method could be used to ignore / bypass certain restrictions on
"taking" the object. If there's a container that enforces certain logic on transfers, like Kiosk
does, there could be a special scenario of skipping the checks by providing a proof of deletion.

This is one of the open topics for exploration and research, and it may be used in various ways.

## ID

When talking about `UID` we should also mention the `ID` type. It is a wrapper around the `address`
type, and is used to represent an address-pointer. Usually, `ID` is used to point at an object,
however, there is no restriction, and no guarantee that the `ID` points to an existing object.

> ID can be received as a transaction argument in a
> [Transaction Block](./../concepts/what-is-a-transaction). Alternatively, ID can be created from an
> `address` value using `to_id()` function.

```move
public fun conversion_methods(ctx: &mut TxContext) {
    let uid: UID = object::new(ctx);
    let id: ID = uid.to_inner();

    let addr_from_uid: address = uid.to_address();
    let addr_from_id: address = id.to_address();

    uid.delete();
}
```

This example demonstrates different conversion methods: `UID.to_inner` creates a copy of underlying
`ID`, and `UID.to_address` returns inner address. Another often useful method `ID.to_address` copies
inner value from the `ID` type.

## Fresh Object Address

[`TxContext`](./../programmability/transaction-context.md) provides the `fresh_object_address`
function which can be utilized to create unique addresses and `ID` - it may be useful in some
application that assign unique identifiers to user actions - for example, an order_id in a
marketplace.

## Links

- [`sui::object`][object] module documentation
- [`sui::derived_object`][derived-object] module documentation
- [Derived Objects](https://docs.sui.io/concepts/sui-move-concepts/derived-objects) in Sui
  Documentation

[object]: https://docs.sui.io/references/framework/sui_sui/object
[derived-object]: https://docs.sui.io/references/framework/sui_sui/derived_object
