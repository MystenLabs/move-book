---
description: "What is a Sui Object: unique identifiers, types, ownership, and native operations like transfer and share for onchain digital assets."
---

# What is an Object?

An _object_ is the unit of storage on Sui. Where the original Move stored data under accounts, Sui
stores objects directly in the global state, each with its own identity, type, and owner recorded
by the system. Objects support native storage operations like _transfer_ and _share_, and are
designed to make the asset properties from the
[previous sections](./digital-assets) - ownership, non-copyability, non-discardability - practical
to work with.

In Move code, an object is not a new kind of value - it is a regular [struct](./../move-basics/struct)
with the `key` ability and a special `id` field:

```move
/// A game character; a struct like any other, made an object
/// by the `key` ability and the `id: UID` field.
public struct Hero has key {
    id: UID,
    level: u8,
}
```

Everything you know about structs still applies. What the object adds is the system-level metadata
attached to it in storage. We cover the definition rules in detail in the
[Using Objects](./../storage) chapter; here we focus on the properties every object has:

- **Type:** Every object has a type, defining the structure and behavior of the object. Objects of
  different types cannot be mixed or used interchangeably, ensuring objects are used correctly
  according to their type system.

- **Unique ID:** Each object has a unique identifier, distinguishing it from other objects. This ID
  is generated upon the object's creation and is immutable, so an object can be tracked and
  referenced across transactions and owners. This is the `id: UID` field in the definition above.

- **Owner:** Every object is associated with an owner, who has control over changes to the object.
  An object can be owned exclusively by an account, owned by another object, shared with the whole
  network, made immutable, or held in the _party_ state - a middle ground between exclusive and
  shared ownership. We discuss all five ownership states in detail in the
  [Ownership](./ownership) section.

  Note that ownership does not control the confidentiality of an object &mdash; it is always
  possible to read the contents of an onchain object from outside of Move. You should never store
  unencrypted secrets inside of objects.

- **Data:** Objects encapsulate their data, simplifying management and manipulation. The data
  structure and operations are defined by the object's type - the fields of the struct.

- **Version:** Every object carries a version number, which the system increments each time a
  transaction modifies the object. The version protects against _replay_: a transaction refers to
  its input objects at specific versions, so the same transaction - or a stale reference to an
  already-changed object - cannot be executed twice. It plays the role a _nonce_ plays in
  account-based blockchains, but per object rather than per account.

- **Digest:** Every object has a digest, which is a hash of the object's data. The digest is used
  to cryptographically verify the integrity of the object's data and ensure that it has not been
  tampered with. It is recalculated whenever the object's data changes.

## Summary

- Objects are the unit of storage on Sui: typed values stored in the global state with
  system-tracked identity and ownership.
- In Move code, an object is a struct with the `key` ability and an `id: UID` field.
- Every object has a type, unique ID, owner, data, version, and digest.

## Further Reading

- [Object Model](https://docs.sui.io/guides/developer/objects/object-model) in Sui Documentation.
