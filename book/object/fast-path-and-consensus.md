---
description: "Fast path vs consensus in Sui: how owned objects skip consensus for faster transactions while shared objects require ordering."
---

# Fast Path and Consensus

The Object Model allows for variable transaction execution paths, depending on the object's
ownership type. The transaction execution path determines how the transaction is processed and
validated by the network. In this section, we'll explore the different transaction execution paths
in Sui and how they interact with the consensus mechanism.

## Concurrency Challenge

At its core, blockchain technology faces a fundamental concurrency challenge: multiple parties may
try to modify or access the same data simultaneously in a decentralized environment. This requires a
system for sequencing and validating transactions to support the network's consistency. Sui
addresses this challenge through a consensus mechanism, ensuring all nodes agree on the
transactions' sequence and state.

Consider a marketplace scenario where Alice and Bob simultaneously attempt to purchase the same
asset. The network must resolve this conflict to prevent double-spending, ensuring that at most one
transaction succeeds while the other is rightfully rejected.

## Fast Path

However, not all transactions require the same level of validation. If Alice transfers an object
she owns to Bob, no other party could have touched that object in the first place - Alice is its
single owner. There is no conflict to resolve, so the network does not need to order this
transaction against all other transactions in the network. Transactions that access only
account-owned objects take the _fast path_: they skip full sequencing and are processed quickly.
This is a direct payoff of the [single owner](./ownership#account-owner-or-single-owner) model -
exclusive access removes the concurrency problem entirely.

Immutable objects also qualify for the fast path. Since a
[frozen object](./ownership#immutable-frozen-state) can never change, any number of transactions
can read it concurrently without any ordering.

## Consensus Path

Transactions that access _shared_ objects are the case consensus exists for: multiple parties may
attempt to modify the same object at the same time, so the network must agree on the order of
these modifications. Such transactions go through the _consensus path_ - they are sequenced by the
consensus protocol before execution, which keeps the state consistent across all nodes.

[Party objects](./ownership#party-objects) also take the consensus path, even though they have a
single owner - that is precisely their trade-off: owner-only access with consensus ordering.

An important detail: consensus on Sui orders transactions _per object_, not globally. Two
transactions touching two unrelated shared objects do not compete with each other - only
transactions accessing the _same_ shared object need to be ordered relative to each other. This is
what allows Sui to execute non-conflicting transactions in parallel.

A single transaction can mix inputs: if it accesses both owned and shared objects, it goes through
consensus - the execution path is determined by the "slowest" input. This is worth keeping in mind
when designing an application: whether your central state is a shared object or stays within owned
objects directly affects how your users' transactions are executed.

## Objects Owned by Objects

Lastly, objects owned by other objects follow the execution path of their parent - a child is only
reachable through its parent, so accessing it means accessing the parent first. If the parent
object is _shared_, working with the child requires consensus; if the parent is account-owned, the
whole chain qualifies for the fast path.

## Summary

- **Fast Path:** Transactions involving only account-owned or immutable objects are processed
  quickly without full consensus sequencing.
- **Consensus Path:** Transactions involving shared or party objects are sequenced by consensus -
  per object, allowing non-conflicting transactions to run in parallel.
- **Mixed Inputs:** A transaction touching both owned and shared objects goes through consensus.
- **Objects Owned by Objects:** Child objects follow the execution path of their parent.

## Next Steps

This concludes the conceptual tour of the Object Model: you know what an object is, who can own
it, and how ownership shapes execution. The next chapter - [Using Objects](./../storage) - turns
these concepts into code: how to define an object, and how to transfer, share, and freeze it from
a Move module.
