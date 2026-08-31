---
description: >-
  Learn how sui::scratch provides an ephemeral per-transaction key-value store
  and how key-defining modules control access to its entries.
title: Scratchpad
keywords:
  - Move
  - Sui
  - Move tutorial
  - scratchpad
  - scratch
questions:
  - What is the Scratchpad in Move?
  - How do I use sui::scratch in Move?
  - How do I keep per-transaction state on Sui?
  - What is In-Place Access in Move?
answer: >-
  The sui::scratch module provides an ephemeral key-value store shared by all
  calls in a transaction. Entries are discarded when the transaction ends, and
  the module that defines a key type controls access to its entries.
goal:
  description: >-
    Reader understands how to use sui::scratch for per-transaction state and
    how the module that defines a key type controls access to its entries
  requires:
    - has_frontmatter:
        - title
        - description
        - keywords
      label: Has required frontmatter fields
    - min_words: 50
      label: Needs content depth
    - has_questions: true
      label: Needs questions for AI search visibility
    - has_answer: true
      label: Needs answer summary for AI citation
---

# Scratchpad

Every storage mechanism covered so far outlives the transaction that used it.
[objects](./../storage), [dynamic fields](./dynamic-fields),
[dynamic collections](./dynamic-collections), and [address balances](./address-balances) all
persist onchain until they are explicitly changed or removed. Sometimes, though, a program needs to
keep a value only for a single transaction. It might need a flag that records whether an action has
already happened, a counter shared by several calls, or a note left by one function for another.
The _scratchpad_ - the `sui::scratch` module of the Sui Framework - provides an ephemeral key-value
store for these cases. It exists for one transaction and is discarded when the transaction ends.

## Keys and Values

An entry in the scratchpad is identified by its key - the key's type and value, hashed
together the same way as a [dynamic field](./dynamic-fields) name. Unlike a dynamic field, however,
an entry is not attached to any object: the scratchpad is a single, transaction-wide store, accessed
through the [transaction context](./transaction-context) rather than a parent `UID`.

The requirements on keys and values mirror the ephemeral nature of the store:

- A key must have `copy` and `drop`. This is similar to a dynamic field name, except a dynamic field
  name also requires `store`. A scratchpad key does not require `store` because it is never written
  to storage.
- A value must have `drop` because any entries left at the end of the transaction are discarded.
  The value does not need `store` because the scratchpad is not storage.
- Reading an entry returns a _copy_ of the value, so `read` also requires `copy`. You can take a
  value that cannot be copied out with `remove`, or access it in place with the borrow-style macros
  covered [below](#in-place-access).

## Access Control

All access to the scratchpad - reads and writes alike - is controlled by the module that defines the
key type. The gate is the `Permit<K>` struct, issued in exchange for an `internal::Permit<K>` - the
[internal permit](./../move-basics/internal-permit) covered earlier in the book:

```move
module sui::scratch;

/// A `Permit<K>` gates access to all entries keyed by values of type `K`.
/// It is issued from an `internal::Permit<K>`, allowing the module that defines `K` to control
/// all access to scratch entries.
public struct Permit<phantom K: copy + drop>() has copy, drop;

/// Issues a `Permit<K>` from the privileged `internal::Permit<K>`, granting access to the
/// scratch entries keyed by values of type `K`.
public fun permit<K: copy + drop>(_: internal::Permit<K>): Permit<K> { /* ... */ }
```

Every scratchpad operation takes a `Permit<K>` for the key type it operates on. Because
`internal::permit<K>()` can only be called from the module that defines `K`, each module is the sole
authority over the part of the scratchpad keyed by its own types. Two modules cannot collide, and
one module cannot read or modify another module's entries.

> Unlike `internal::Permit`, which only has `drop`, the scratchpad `Permit` also has `copy`: a
> single permit can authorize any number of operations within the transaction. It still lacks
> `store`, so it cannot be kept for a later transaction - fitting for a store that will not exist by
> then.

## Using the Scratchpad

To work with the scratchpad, first define a key type. Any `copy + drop` type works. A common choice
is an empty [positional struct](./../move-basics/struct#positional-structs) for each entry:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=key

```

Most of the time a module accesses its own entries, so the framework provides `internal_*` macro
shortcuts that construct the permit inline. They are available as methods on `TxContext`, giving
scratchpad access to any function that takes the transaction context:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=usage

```

The basic operations, each in a permit-taking form (`scratch::add`, also available as
`ctx.scratch_add(permit, ...)`) and a macro form for the defining module
(`ctx.scratch_internal_add!(...)`):

- `add` - adds a `key`-`value` entry. It aborts if an entry for `key` already exists, regardless of
  its value type.
- `read` - returns a copy of the value. It aborts if the entry does not exist or the value type does
  not match.
- `remove` - removes the entry and returns the value, with the same abort conditions as `read`.
- `exists` / `exists_with_type` - check for the entry, without or with a value type check.
- `read_opt` / `remove_opt` - versions of `read` and `remove` that return an
  [Option](./../move-basics/option) instead of aborting on a missing entry.
- `replace` - removes the existing value, if any, and adds a new one in its place, returning the old
  value. The old and new value types may differ.

Functions that modify the store - `add`, `remove`, `remove_opt`, and `replace` - take
`&mut TxContext`. The `read` and existence operations take `&TxContext`.

## In-Place Access

`read` returns a copy. To change a value with the basic operations, you must remove it and then add
it back. The _borrow-style_ macros handle these steps for you. They take the value out of its slot,
pass a reference to a provided function, and restore the value afterward. This requires neither
`copy` nor manual bookkeeping:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=get

```

There are four of them, and all skip the function if there is no entry for the key:

- `get_do` / `get_mut_do` - call the function with an immutable or mutable reference to the value.
  They do nothing if the entry does not exist.
- `get_fold` / `get_mut_fold` - also return a result. They return whatever the function produces,
  or the provided default if the entry does not exist.

Under the hood, the macros are built on the `begin_borrow` / `end_borrow` pair of functions, which
are public but not intended for direct use: the value is temporarily removed while the function
runs, and the slot is occupied by a `BorrowMarker` - a transaction-unique stand-in that is checked
when the value is put back.
Two consequences follow: the macros take `&mut TxContext` even when the access is read-only, and the
key must not be accessed again from within the function - the slot holds only the marker for the
duration of the call, so a nested access of the same key aborts rather than observing a half-updated
entry.

## Per-Transaction State

The scratchpad is useful because every call in a transaction sees the same state. A single
[transaction](./../concepts/what-is-a-transaction) can chain many commands that call many functions,
and each function can access the same scratchpad. This lets a program enforce rules across the
transaction as a whole, even when no single function can observe every call. For example, you can
limit how many times an action runs in one transaction, regardless of how it is called:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=counter

```

The counter lives for exactly one transaction. The first call finds nothing and starts from zero,
subsequent calls increment the counter, and the final value is dropped when the transaction ends.
This avoids cleanup, stale state, and storage costs. Without the scratchpad, the same pattern would
require a dedicated object and careful resetting.

> Like other per-transaction resources, the scratchpad is bounded by a
> [protocol limit](./../guides/building-against-limits): a single transaction can hold at most
> 16,384 entries at the time of writing - 16 times the maximum number of commands in a transaction.

## Sharing Access

Because a `Permit` is an ordinary value, the defining module does not have to keep scratchpad access
to itself. It can issue a permit and give other code access to its entries:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=permit

```

The holder of a permit uses the explicit, permit-taking functions - here via their `TxContext`
method aliases:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=explicit

```

This mirrors how the [internal permit](./../move-basics/internal-permit) works in general: the
authority to act is represented by a value, and passing the value _is_ the authorization. The `copy`
ability makes a shared permit reusable within the transaction, while the lack of `store` guarantees
the grant cannot outlive it.

## Comparison with Hot Potato

The scratchpad may seem similar to the [Hot Potato](./hot-potato-pattern) pattern from the previous
section. Both let several calls within one transaction share state, and both leave nothing behind
when the transaction ends. However, they provide different guarantees:

- A hot potato travels through function signatures. The scratchpad does not change them. A function
  only needs the `TxContext` it already takes.
- A hot potato constrains the transaction visibly. Whoever holds the value can see it and must
  decide where it goes next. Scratchpad-based behavior is not visible from the outside because
  nothing in the signatures reveals that the calls are connected.
- A hot potato creates an explicit obligation to call a final, consuming function. The ability
  system enforces that obligation. A scratchpad entry creates no such obligation and disappears at
  the end of the transaction.
- A hot potato can wrap any value, including assets that must not be dropped. Scratchpad values
  require `drop`, so the scratchpad cannot carry a resource that must be consumed.

Use a hot potato for a flow that _must_ be completed, such as a flash loan or swap. Use the
scratchpad to carry predefined information about the transaction between calls that would otherwise
have no way to share it.

## Summary

- The _scratchpad_ - `sui::scratch` - is an ephemeral key-value store scoped to a single
  transaction. Entries are dropped when the transaction ends.
- An entry is identified by the type and value of its key, hashed like a dynamic field name. Keys
  require `copy + drop`, values require `drop`, and reading also requires `copy`.
- Access is gated by `Permit<K>`, issued from an
  [internal permit](./../move-basics/internal-permit), making the module that defines the key type
  the sole authority over its entries.
- The `internal_*` macros - available as `ctx.scratch_internal_add!` and friends - construct the
  permit inline for the defining module.
- The borrow-style `get_do` / `get_mut_do` / `get_fold` / `get_mut_fold` macros give a function
  temporary access to a value by reference, without copying or a manual remove-and-add.
- Shared state across all calls of a transaction enables transaction-wide rules, such as limiting
  how many times an action can run per transaction.

## Further Reading

- [sui::scratch](https://docs.sui.io/references/framework/sui/scratch) module documentation.
- [Internal Permit](./../move-basics/internal-permit) - the mechanism behind `Permit<K>`.
- [Dynamic Fields](./dynamic-fields) - the persistent counterpart to scratchpad entries.
