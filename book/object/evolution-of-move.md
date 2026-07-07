---
description: "The evolution of Move from Diem to Sui: how the storage model changed from account-based to the object-based model."
---

# Evolution of Move

Move was created at [Diem](https://www.diem.com/en-us) to manage digital assets, and its original
storage model reflected the design of that blockchain. Storage was _account-based_: every piece of
data - called a _resource_ - lived under an account address, and a module could store, read, and
remove resources only under the accounts that interacted with it. In its original form, Move had
dedicated global storage operators for this, and a resource could only be placed under an account
if that account agreed to it by signing a transaction.

This model had practical consequences that made everyday asset operations surprisingly hard:

- There was no built-in _transfer_ operation. If Alice wanted to send an asset X to Bob, the module
  defining X had to implement transfer logic itself: Bob first had to publish an "empty" resource
  under his account (agreeing to receive the asset), and only then could Alice's transaction move
  the balance into it. Every module reinvented this dance.
- Assets were stored per-type, per-account. Managing a heterogeneous collection - say, a single
  account holding many different kinds of items - required significant effort and preparation for
  each new type.
- Because data lived under accounts, an asset did not have an identity of its own: there was no way
  to point at "this specific item" and follow it across owners.

Sui addressed these challenges by redesigning the storage model around the assets themselves. In
Sui, the unit of storage is not an account but an _object_ - a typed value with its own unique
identifier and an owner recorded by the system. Ownership and _transfer_ became native operations:
Alice can directly transfer asset X to Bob, without Bob preparing anything in advance, and Bob can
hold any number of assets of any types. The global storage operators of the original Move are
absent in Move on Sui - in the [Using Objects](./../storage) chapter, we will see that they are
replaced by functions operating on objects.

These changes laid the foundation for the Object Model, which we describe in the next section.

## Summary

- Original Move used account-based global storage: resources lived under account addresses, there
  was no native transfer operation, and heterogeneous collections were hard to manage.
- Sui redesigned storage around _objects_ - typed values with their own identity and
  system-tracked ownership - making transfer a native operation.
- Move on Sui removes the global storage operators, replacing them with object storage functions.

## Further Reading

- [Why We Created Sui Move](https://blog.sui.io/why-we-created-sui-move/) by Sam Blackshear
