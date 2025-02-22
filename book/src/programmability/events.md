# Events

Events are a way to notify off-chain listeners about on-chain events. They are used to emit
additional information about the transaction that is not stored - and, hence, can't be accessed -
on-chain. Events are emitted by the `sui::event` module located in the
[Sui Framework](./sui-framework.md).

> Any custom type with the [copy](./../move-basics/copy-ability.md) and
> [drop](./../move-basics/drop-ability.md) abilities can be emitted as an event.
> Sui Verifier requires the type to be internal to the module.

```move
// File: sui-framework/sources/event.move
module sui::event;

/// Emit a custom Move event, sending the data off-chain.
///
/// Used for creating custom indexes and tracking on-chain
/// activity in a way that suits a specific application the most.
///
/// The type `T` is the main way to index the event, and can contain
/// phantom parameters, eg `emit(MyEvent<phantom T>)`.
public native fun emit<T: copy + drop>(event: T);
```

## Emitting Events

Events are emitted using the `emit` function in the `sui::event` module. The function takes a single
argument - the event to be emitted. The event data is passed by value,

```move
{{#include ../../../packages/samples/sources/programmability/events.move:emit}}
```

The Sui Verifier requires the type passed to the `emit` function to be _internal to the module_. So
emitting a type from another module will result in a compilation error. Primitive types, although
they match the _copy_ and _drop_ requirement, are not allowed to be emitted as events.

## Event Structure

Events are a part of the transaction result and are stored in the _transaction effects_. As such,
they natively have the `sender` field which is the address who sent the transaction. So adding a
"sender" field to the event is not necessary. Similarly, event metadata contains the timestamp. But
it is important to note that the timestamp is relative to the node and may vary a little from node
to node.

<!-- ## Reliability -->
