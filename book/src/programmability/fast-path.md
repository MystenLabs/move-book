# Fast Path

Due to the object model and the data organization model of Sui, some operations can be performed in
a more efficient and parallelized way. This is called the **fast path**. Transaction that touches
shared state requires consensus because it can be accessed by multiple parties at the same time.
However, if the transaction only touches the private state (owned objects), there is no need for
consensus. This is the fast path.

We have a favorite example for this: a coffee machine and a coffee cup. The coffee machine placed in
the office is a shared resource - everyone can use it, but there can be only one user at a time. The
coffee cup, on the other hand, is a private resource - it belongs to a specific person, and only
that person can use it. To make coffee, one needs to use the coffee machine and wait if there's
someone else using it. However, once the coffee is made and poured into the cup, the person can take
the cup and drink the coffee without waiting for anyone else.

The same principle applies to Sui. If a transaction only touches the private state (the cup with
coffee), it can be executed without consensus. If it touches the shared state (the coffee machine),
it requires consensus. This is the fast path.

## Frozen objects

Consensus is only required for mutating the shared state. If the object is immutable, it is treated
as a "constant" and can be accessed in parallel. Frozen objects can be used to share unchangeable
data between multiple parties without requiring consensus.

## In practice

```move
{{#include ../../../packages/samples/sources/programmability/fast-path.move:main}}
```

## Special case: Clock

The `Clock` object with the reserved address `0x6` is a special case of a shared object which cannot
be passed by a mutable reference in a regular transaction. An attempt to do so will not succeed, and
the transaction will be rejected. Because of this limitation, the `Clock` object can only be
accessed immutably, which allows executing transactions in parallel without consensus.

<!-- Add more on why and how -->
