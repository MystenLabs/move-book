---
description: "Advanced Sui programmability: patterns, events, dynamic fields, capabilities, BCS serialization, and design patterns in Move."
---

# Advanced Programmability

In previous chapters we've covered [the basics of Move](./../move-basics) and
[Sui Storage Model](./../storage). Now it's time to dive deeper into the advanced topics of Sui
programmability. This chapter introduces more complex concepts, practices, and features of Move and
Sui that are essential for building more sophisticated applications.

The sections are ordered so that each builds on what came before, but they also form a few mostly
independent threads, and it is fine to follow the one you need right now:

- **The execution environment** - what a program can learn about the transaction it runs in and
  the system around it, and how it communicates with the outside world:
  [Sui Framework](./sui-framework), [Transaction Context](./transaction-context),
  [Module Initializer](./module-initializer), [Epoch and Time](./epoch-and-time),
  [Events](./events), and [Binary Canonical Serialization](./bcs).

- **Storage at scale** - from simple vector-based collections to dynamic fields, a primitive that
  attaches arbitrary data to objects and lifts static type and size limits:
  [Collections](./collections), [Wrapper Type](./wrapper-type-pattern),
  [Dynamic Fields](./dynamic-fields), [Dynamic Object Fields](./dynamic-object-fields), and
  [Dynamic Collections](./dynamic-collections).

- **Patterns of authority** - Move's answer to access control: from owned objects acting as
  permissions to guarantees backed by the system, and features built on top of them:
  [Capability](./capability), [Witness](./witness-pattern),
  [One Time Witness](./one-time-witness), [Publisher](./publisher), [Display](./display), and
  [Hot Potato](./hot-potato-pattern).

- **Assets and funds** - fungible value and the two ways to hold it, as objects and as balances
  attached directly to an address: [Balance and Coin](./balance-and-coin) and
  [Address Balances](./address-balances).

- **Code evolution** - what happens after the code ships: publishing new versions of a package,
  protecting shared state from old versions, and migrating data:
  [Package Upgrades](./package-upgrades).

> Many code samples in this chapter are written as [tests](./../move-basics/testing), and use
> test-only helpers from the framework: `tx_context::dummy()` creates a placeholder transaction
> context, and `std::unit_test::destroy` consumes any value at the end of a test. We cover testing
> techniques in detail in the [Testing](./../testing) chapter.
