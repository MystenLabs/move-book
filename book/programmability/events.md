---
description: "Emit and test events in Sui Move: notify offchain listeners about onchain activity in your smart contracts."
---

# Events

Onchain storage keeps the _current_ state of the application: objects, their fields, and their
owners. What it does not keep is the history of actions that led to this state. A marketplace
module stores listed items, but once an item is sold and the object changes hands, there is no
onchain trace of the purchase - the price paid, the time of the sale, or the parties involved.
Applications, however, often need exactly that: an activity feed, a trading history, or analytics.

_Events_ are the mechanism for this. An event is a piece of data attached to the result of a
successful transaction and stored offchain. Emitting an event does not modify any objects and
costs no storage fees; instead, events are indexed by full nodes, and offchain services can query
or subscribe to them. Events are the main way for a Move program to communicate with the outside
world.

## Definition

Events are emitted with the `emit` function defined in the [`sui::event`][event-framework] module
of the [Sui Framework](./sui-framework):

```move
module sui::event;

/// Emit a custom Move event, sending the data offchain.
///
/// Used for creating custom indexes and tracking onchain
/// activity in a way that suits a specific application the most.
///
/// The type `T` is the main way to index the event, and can contain
/// phantom parameters, eg `emit(MyEvent<phantom T>)`.
public native fun emit<T: copy + drop>(event: T);
```

An event can be any custom type with the [copy](./../move-basics/copy-ability) and
[drop](./../move-basics/drop-ability) abilities. Additionally, the Sui Verifier requires the type
to be [_internal to the module_](./../storage/internal-constraint) that emits it: it is impossible to emit a type defined in another
module, and, even though they satisfy the `copy + drop` requirement,
[primitive types](./../move-basics/primitive-types) cannot be emitted either. This rule makes the
event type an unforgeable label - an `ItemPurchased` event can only ever originate from the module
that declares it.

## Emitting Events

To emit an event, define a struct for it and pass an instance of the struct to `event::emit`. The
event data is passed by value and sent offchain as part of the transaction result:

```move file=packages/samples/sources/programmability/events.move anchor=emit

```

The type of the event serves as the primary filter for offchain queries - services subscribe to
`ItemPurchased` events by naming the type. This suggests a simple design principle: emit a
dedicated type per action, and name it after the action that happened, in past tense -
`ItemPurchased`, `AuctionStarted`, `ConfigUpdated`. Inside the event, include the values an
indexer would need to make sense of the action without fetching anything else: the IDs of the
objects involved, amounts, and the relevant addresses.

Note that events are attached to a _successful_ transaction: if the transaction aborts after the
`emit` call, no events are recorded.

## Event Structure

Events become part of the _transaction effects_, and the system attaches metadata to each of them:

- the _sender_ - the address that signed the transaction;
- the _transaction digest_ - linking the event to the transaction that emitted it;
- the _timestamp_ - the time of the checkpoint that finalized the transaction, shared by all
  events of that transaction;
- the _type signature_ of the event, including the package and module that emitted it.

Because the sender and the transaction digest are always present in the metadata, there is no need
to duplicate them in the event fields. A `sender: address` field in an event struct is redundant,
unless the "logical" sender differs from the transaction signer (for example, in a sponsored
transaction executed on behalf of a user).

It is important to understand that events are a one-way channel. Emitted events are not stored
onchain and cannot be read back by Move code - not in the same transaction, and not in any later
one. If a value needs to be accessed by the program, it belongs in an object; if it needs to be
seen by the outside world, it belongs in an event.

## Testing Events

Because events are the interface between the application and its offchain services, it is
important to test that the right events are emitted with the right values. The `sui::event` module
provides two test-only functions for this: `num_events`, returning the number of events emitted so
far in the test, and `events_by_type<T>`, returning a vector of all emitted events of type `T`.

```move file=packages/samples/sources/programmability/events.move anchor=test

```

Since event structs are internal to the module, tests placed in the same module (or in a test
module of the same package with appropriate accessors) can inspect their fields directly.

## Summary

- Events attach application-defined data to the transaction result; they are indexed offchain and
  are the main way to notify the outside world about onchain activity.
- Any custom type with `copy` and `drop` can be an event, but it must be internal to the emitting
  module - this makes the event type an unforgeable label.
- Event metadata already contains the sender, the transaction digest, and a timestamp; event
  fields should carry action-specific data, such as object IDs and amounts.
- Events cannot be read back by Move code - they are a one-way channel.
- Use `num_events` and `events_by_type<T>` to test emitted events.

## Further Reading

- [sui::event][event-framework] module documentation.
- [Using Events](https://docs.sui.io/guides/developer/sui-101/using-events) in the Sui
  Documentation - querying and subscribing to events offchain.

[event-framework]: https://docs.sui.io/references/framework/sui/event
