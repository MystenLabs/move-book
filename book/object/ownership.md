---
description: "Object ownership types in Sui: single owner, shared state, immutable objects, and object-owned objects explained with examples."
---

# Ownership

Every object on Sui is in one of five ownership states: _single owner_, _shared_, _immutable
(frozen)_, _object owner_, or _party_. Each model offers unique characteristics and suits different
use cases, and - as we will see in the [next section](./fast-path-and-consensus) - the choice of
ownership also determines how transactions touching the object are executed.

See the [Storage Functions](../storage/storage-functions.md) section for details on how to change
the owner or ownership type of an object.

## Account Owner (or Single Owner)

The account owner, also known as the _single owner_ model, is the foundational ownership type in
Sui. Here, an object is owned by a single account, granting that account exclusive control over the
object within the behaviors associated with its type. This model embodies the concept of _true
ownership_: only the owner can use the object in a transaction - whether to read it, modify it, or
transfer it away - and nobody else can touch it. This level of ownership clarity is a significant
advantage over other blockchain systems, where ownership definitions can be more ambiguous, and
smart contracts may have the ability to alter or transfer assets without the owner's consent.

Think of it like your mobile phone: you can unlock and operate it, and others cannot. Sui enforces
this at the system level - there is no way to "crack the password" and use an object that belongs
to someone else, so no one can use your assets unless you authorize it.

## Shared State

The single owner model has its limitations. Consider a marketplace for digital assets: Alice owns
an asset X and wants to list it for sale, so that Bob - or anyone else - can come and buy it. With
only single-owner objects this is surprisingly hard to express: for the sale to happen without
Alice's participation, the asset has to sit in a place that both the seller and any future buyer
can access, and no single account can be its owner.

To solve the problem of shared data access, Sui offers the _shared_ ownership model. A shared
object belongs to the network: it can be read and modified by any account, and the rules of
interaction are defined by the module that implements the object. Typical uses for shared objects
are marketplaces, shared resources, escrows, and other scenarios where multiple accounts need
access to the same state.

## Party Objects

The newest ownership state, the _party_ object, sits between the two models above: like a
single-owner object, it has an owner - an address whose permission is required to use it - but,
like a shared object, transactions touching it are ordered by consensus. Today a party object is
always owned by a single address; the state is designed to eventually support more complex
configurations, with permissions split between multiple parties.

Party objects trade away the speed of exclusive ownership for the flexibility of consensus
ordering - useful for assets that are frequently touched by high-traffic services, where many
independent transfers to and from the same owner may be in flight at once. For most applications,
they are an advanced option rather than the starting point: begin with single-owner objects, and
reach for party objects when a concrete need arises.

> Party objects are listed here for the complete picture. Their transfer functions are covered in
> [Appendix C: Transfer Functions](./../appendix/transfer-functions#party), and the
> [`sui::party`](https://docs.sui.io/references/framework/sui/party) module documentation covers
> the details.

## Immutable (Frozen) State

Sui also offers the _frozen object_ model, where an object becomes permanently read-only. These
immutable objects, while readable, cannot be modified, transferred, or deleted, providing a stable
and constant state accessible to all network participants. Frozen objects are ideal for public
data, reference materials, and other use cases where state permanence is desirable.

## Object Owner

The last ownership model in Sui is the _object owner_: an object owned by another object. This
feature allows creating complex relationships between objects, storing large heterogeneous
collections, and implementing extensible and modular systems. Since transactions are initiated by
accounts, a transaction accesses the parent object first, and reaches the child objects through it.

A use case we love to mention is a game character. Alice can own the Hero object from a game, and
the Hero can own items: also represented as objects, like a "Map", or a "Compass". Alice may take
the "Map" from the "Hero" object, and then send it to Bob, or sell it on a marketplace. With object
owner, it becomes very natural to imagine how the assets can be structured and managed in relation
to each other.

> There are two mechanisms behind parent-child relations, both covered later in the book:
> [Dynamic Fields](./../programmability/dynamic-fields) and
> [Transfer to Object](./../storage/transfer-to-object).

## Summary

- **Single Owner:** Objects are owned by a single account, granting exclusive control over the
  object.
- **Shared State:** Objects can be shared with the network, allowing multiple accounts to read and
  modify the object.
- **Party:** Objects have a single owner but are sequenced through consensus - a newer, advanced
  option.
- **Immutable State:** Objects become permanently read-only, providing a stable and constant state.
- **Object Owner:** Objects can own other objects, enabling complex relationships and modular
  systems.

## Next Steps

In the next section we will talk about transaction execution paths in Sui, and how the ownership
models affect the transaction execution.
