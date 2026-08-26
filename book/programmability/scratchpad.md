---
description: >-
  Scratchpad in Sui Move: sui::scratch, an ephemeral per-transaction key-value
  store with access controlled by the module that defines the key type.
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
  Scratchpad in Sui Move: sui::scratch, an ephemeral per-transaction key-value
  store with access controlled by the module that defines the key type.
goal:
  description: >-
    Reader understands scratchpad in Sui Move: sui::scratch, an ephemeral
    per-transaction key-value store with access controlled by the module that
    defines the key type
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

Every storage mechanism we have covered so far outlives the transaction that used it:
[objects](./../storage), [dynamic fields](./dynamic-fields),
[dynamic collections](./dynamic-collections), and [address balances](./address-balances) all
persist onchain
until they are explicitly changed or removed. Sometimes, however, a program needs to keep a value
only for the duration of a single transaction: a flag that an action has already happened, a counter
shared by several calls, a note left by one function for another. The _scratchpad_ - the
`sui::scratch` module of the Sui Framework - serves exactly this need: an ephemeral key-value store
that exists for one transaction and is discarded when it ends.

> The scratchpad is a recent addition to the Sui Framework - it ships with Sui v1.77 and becomes
> available on each network with protocol version 130.

## Keys and Values

An entry in the scratchpad is identified by its key - the pair of the key's type and value, hashed
together the same way as a [dynamic field](./dynamic-fields) name. Unlike a dynamic field, however,
an entry is not attached to any object: the scratchpad is a single, transaction-wide store, accessed
through the [transaction context](./transaction-context) rather than a parent `UID`.

The requirements on keys and values mirror the ephemeral nature of the store:

- a key must have `copy` and `drop` - close to a dynamic field name, except that a dynamic field
  name additionally requires `store`, and a scratchpad key does not: it is never written to
  storage;
- a value must have `drop` - entries left in the scratchpad at the end of the transaction are
  discarded, so the value must be discardable; notably, it does not need `store`, since the
  scratchpad is not storage;
- reading an entry returns a _copy_ of the value, so `read` additionally requires `copy`. A value
  that cannot be copied can still be taken out with `remove`, or accessed in place with the
  borrow-style macros covered [below](#in-place-access).

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

Every scratchpad operation takes a `Permit<K>` for the key type it operates on. And since
`internal::permit<K>()` can only be called from the module that defines `K`, each module is the sole
authority over the slice of the scratchpad keyed by its own types - two modules can never collide,
and one module cannot read or tamper with another's entries.

> Unlike `internal::Permit`, which only has `drop`, the scratchpad `Permit` also has `copy`: a
> single permit can authorize any number of operations within the transaction. It still lacks
> `store`, so it cannot be kept for a later transaction - fitting for a store that will not exist by
> then.

## Using the Scratchpad

Working with the scratchpad starts with defining a key type. Any `copy + drop` type works; a common
choice is an empty [positional struct](./../move-basics/struct#positional-structs) per entry:

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

- `add` - adds a `key`-`value` entry; aborts if an entry for `key` already exists, regardless of its
  value type;
- `read` - returns a copy of the value; aborts if the entry does not exist or the value type does
  not match;
- `remove` - removes the entry and returns the value, with the same aborts as `read`;
- `exists` / `exists_with_type` - check for the entry, without or with a value type check;
- `read_opt` / `remove_opt` - versions of `read` and `remove` that return an
  [Option](./../move-basics/option) instead of aborting on a missing entry;
- `replace` - removes the existing value, if any, and adds a new one in its place, returning the old
  value; the old and new value types may differ.

Functions that modify the store - `add`, `remove`, `remove_opt`, and `replace` - take
`&mut TxContext`; `read` and the existence checks take `&TxContext`.

## In-Place Access

`read` returns a copy, and changing a value through the basic operations means removing it and
adding it back. The _borrow-style_ macros wrap this dance: they take the value out of the slot, pass
a reference to it into a provided function, and restore it afterwards - no `copy` required, and no
manual bookkeeping:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=get

```

There are four of them, and all skip the function if there is no entry for the key:

- `get_do` / `get_mut_do` - call the function on an immutable / mutable reference to the value,
  doing nothing if the entry does not exist;
- `get_fold` / `get_mut_fold` - additionally return a result: whatever the function produces, or the
  provided default if the entry does not exist.

Under the hood, the macros are built on the `begin_borrow` / `end_borrow` pair of functions, which
are public but not intended for direct use: the value is temporarily removed while the function
runs, and the slot is occupied by a `BorrowMarker` - a transaction-unique stand-in that is checked
when the value is put back.
Two consequences follow: the macros take `&mut TxContext` even when the access is read-only, and the
key must not be accessed again from within the function - the slot holds only the marker for the
duration of the call, so a nested access of the same key aborts rather than observing a half-updated
entry.

## Per-Transaction State

What makes the scratchpad more than a convenience is its scope: a single
[transaction](./../concepts/what-is-a-transaction) may chain many commands calling into many
functions, and all of them see the same scratchpad. This allows enforcing properties of the
transaction as a whole - something no single function could observe on its own. A classic example is
an action that must not run more than a fixed number of times per transaction, no matter how it is
called:

```move file=packages/samples/sources/programmability/scratchpad.move anchor=counter

```

The counter lives for exactly one transaction: the first call finds nothing and starts from zero,
subsequent calls increment it, and whatever is left is dropped when the transaction ends. No
cleanup, no stale state, and no storage cost - the pattern that would otherwise require a dedicated
object and careful resetting comes for free.

> Like other per-transaction resources, the scratchpad is bounded by a
> [protocol limit](./../guides/building-against-limits): a single transaction can hold at most
> 16,384 entries at the time of writing - 16 times the maximum number of commands in a transaction.

## Sharing Access

Because a `Permit` is an ordinary value, the defining module does not have to keep the scratchpad to
itself: it can issue a permit and hand it out, granting other code access to its entries:

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

The scratchpad may seem to compete with the [Hot Potato](./hot-potato-pattern) pattern from the
previous section: both let several calls within one transaction share state, and both leave nothing
behind when it ends. The differences are substantial, though:

- a hot potato travels through function signatures; the scratchpad changes none - a function only
  needs the `TxContext` it already takes;
- a hot potato constrains the transaction visibly: whoever holds the value can see - and must
  decide - where it goes next. Scratchpad-based behavior is invisible from the outside: nothing in
  the signatures reveals that the calls are connected;
- a hot potato is an explicit obligation to call a final, consuming function, enforced by the
  ability system; a scratchpad entry obliges no one and simply evaporates at the end of the
  transaction;
- a hot potato can wrap any value, including assets that must not be dropped; scratchpad values
  require `drop`, so the scratchpad cannot carry a resource that has to be consumed.

So while there is overlap, hot potatoes suit their purpose - flows that _must_ be completed, such
as flash loans or swaps - much better, and the scratchpad takes its own niche: carrying predefined
information about the execution of the transaction itself between calls that would otherwise have
no way of being wired together.

## Summary

- The _scratchpad_ - `sui::scratch` - is an ephemeral key-value store scoped to a single
  transaction: entries are dropped when the transaction ends;
- an entry is identified by the type and value of its key, hashed like a dynamic field name; keys
  require `copy + drop`, values require `drop`, and reading additionally requires `copy`;
- access is gated by `Permit<K>`, issued from an
  [internal permit](./../move-basics/internal-permit), making the module that defines the key type
  the sole authority over its entries;
- the `internal_*` macros - available as `ctx.scratch_internal_add!` and friends - construct the
  permit inline for the defining module;
- the borrow-style `get_do` / `get_mut_do` / `get_fold` / `get_mut_fold` macros give a function
  temporary access to a value by reference, without copying or a manual remove-and-add;
- shared state across all calls of a transaction enables transaction-wide rules, such as limiting
  how many times an action can run per transaction.

## Further Reading

- [sui::scratch](https://docs.sui.io/references/framework/sui/scratch) module documentation.
- [Internal Permit](./../move-basics/internal-permit) - the mechanism behind `Permit<K>`.
- [Dynamic Fields](./dynamic-fields) - the persistent counterpart to scratchpad entries.
