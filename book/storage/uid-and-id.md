---
description: "UID and ID in Sui Move: unique object identifiers, how they are created, used for dynamic fields, and guaranteed to be unique."
---

# UID and ID

The use of the `UID` type is required by the Sui Verifier on all types that have the
[`key`](./key-ability) ability. Here we go deeper into `UID` and its usage.

## Definition

The `UID` type is defined in the `sui::object` module and is a wrapper around an `ID` which, in
turn, wraps the `address` type. The UIDs on Sui are guaranteed to be unique, and can't be reused
after the object was deleted.

```move
module sui::object;

/// UID is a unique identifier of an object.
public struct UID has store {
    id: ID
}

/// ID is a wrapper around an address; freely copyable.
public struct ID has copy, drop, store {
    bytes: address
}
```

Note the difference in abilities: an `ID` is plain, copyable data - a pointer that can name any
object (or even a non-existent one) without any special privileges. A `UID` can be neither copied
nor dropped: it is the identity of an object, and both its creation and its destruction are
explicit, controlled operations.

## Fresh UID Generation

A new `UID` is created with the `object::new(ctx)` function:

- `UID` is _derived_ from the transaction digest and a counter of IDs created so far in the
  transaction, which is incremented with each new UID.
- The counter lives in the transaction context, which is why
  [TxContext](./../programmability/transaction-context) is required - as a mutable reference - for
  UID generation.
- The `id` field of a newly created object must be a _fresh_ UID - one produced by `object::new`
  in the same transaction. The Sui Verifier rejects packing an object with a UID taken from
  another, unpacked object - so an identity can never be reused, even by the module that owns it.

`UID` acts as the representation of an object, and enables features attached to the object's
identity. One of the key ones - [Dynamic Fields](./../programmability/dynamic-fields) - is
possible because the `UID` is explicit. Another - [Transfer to Object](./transfer-to-object),
covered at the end of this chapter - allows an object to receive other objects sent to its ID.

## UID Lifecycle

The `UID` is created with `object::new`, and deleted with the `object::delete` function. The
`delete` function consumes the UID _by value_, so it can only be called after the object was
[unpacked](./../move-basics/struct#unpacking-a-struct) - which, in turn, only the defining module
can do:

```move file=packages/samples/sources/storage/uid-and-id.move anchor=lifecycle

```

### Keeping the UID

The `UID` does not have to be deleted immediately after the object is unpacked. It may carry
[Dynamic Fields](./../programmability/dynamic-fields), or hold objects sent to it via
[Transfer to Object](./transfer-to-object) - deleting the UID would make those unreachable. For
such cases, the UID can be kept: stored as a plain `UID` field (not as `id`!) in another struct,
until the associated data is dealt with and the UID can be safely deleted.

> The ability to keep a UID after its object is gone enables a niche technique known as _proof of
> deletion_: the returned UID is evidence that the object was destroyed, which an application can
> exchange for a reward, or use to bypass restrictions that applied to the live object.

## UID Derivation

Sui allows deriving UIDs from other UIDs using _derivation keys_. This functionality is
implemented in the [`sui::derived_object`][derived-object] module, and produces predictable,
deterministic IDs for easier offchain discovery. The UID for each parent + key pair can be
claimed only once:

```move file=packages/samples/sources/storage/uid-and-id.move anchor=derived

```

Derived addresses reduce the load on offchain indexers: it is enough to know the ID of the parent
object, and the IDs of derived objects can be computed with a derivation function - present in
most SDKs, and in Move itself:

```move
module sui::derived_object;

/// Checks if a UID was derived with `key` at `parent`.
public fun exists<K: copy + drop + store>(parent: &UID, key: K): bool;

/// Derive the inner `address` of a UID, regardless of whether it was claimed.
public fun derive_address<K: copy + drop + store>(parent: ID, key: K): address;
```

The same derivation mechanism is used internally to generate IDs for
[dynamic fields](./../programmability/dynamic-fields).

## ID

When talking about `UID` we should also mention the `ID` type. It is a freely copyable wrapper
around `address`, used to _point_ at an object. Usually an `ID` refers to some object, but there
is no restriction - and no guarantee - that the ID points to an existing object.

> An ID can be received as a transaction argument in a
> [Transaction Block](./../concepts/what-is-a-transaction). Alternatively, an ID can be created
> from an `address` value using the `to_id()` function.

```move file=packages/samples/sources/storage/uid-and-id.move anchor=conversions

```

## Fresh Object Address

[`TxContext`](./../programmability/transaction-context) provides the `fresh_object_address`
function, which produces a unique address using the same derivation as `object::new` - without
creating a `UID`. It is useful for applications that need unique identifiers for offchain
entities - for example, an `order_id` in a marketplace.

## Summary

- `UID` is the non-copyable, non-droppable identity of an object; `ID` is a freely copyable
  pointer.
- Fresh UIDs come from `object::new(ctx)` and can never be reused for a new object.
- A UID is deleted with `object::delete` after unpacking - or kept, if data is still attached to
  it.
- Derived UIDs (`sui::derived_object`) make object IDs predictable and discoverable offchain.

## Further Reading

- [`sui::object`][object] module documentation.
- [`sui::derived_object`][derived-object] module documentation.
- [Derived Objects](https://docs.sui.io/guides/developer/objects/derived-objects) in Sui
  Documentation.

[object]: https://docs.sui.io/references/framework/sui/object
[derived-object]: https://docs.sui.io/references/framework/sui/derived_object
