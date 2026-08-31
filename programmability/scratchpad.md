> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

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

Each scratchpad entry has a key. The key's type and value are hashed together in the same way as a
[dynamic field](./dynamic-fields) name. Unlike a dynamic field, a scratchpad entry is not attached
to an object. All entries belong to a single store scoped to the current transaction. Programs
access this store through the [transaction context](./transaction-context) rather than a parent
`UID`.

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

```move
/// Identifies this module's entries in the scratchpad. Only `book::scratchpad`
/// can authorize access to entries keyed by `NoteKey`.
public struct NoteKey() has copy, drop;
```

Most of the time a module accesses its own entries, so the framework provides `internal_*` macro
shortcuts that construct the permit inline. They are available as methods on `TxContext`, giving
scratchpad access to any function that takes the transaction context:

```move
/// Leave a note for other calls in the same transaction.
public fun set_note(note: String, ctx: &mut TxContext) {
    ctx.scratch_internal_add!(NoteKey(), note);
}

/// Read the note, if one was left earlier in the transaction.
public fun read_note(ctx: &TxContext): Option<String> {
    ctx.scratch_internal_read_opt!(NoteKey())
}
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

```move
/// Append a suffix to the note in place, if one was left.
public fun append_to_note(suffix: String, ctx: &mut TxContext) {
    ctx.scratch_internal_get_mut_do!(NoteKey(), |note: &mut String| note.append(suffix));
}

/// Length of the note, or 0 if none was left.
public fun note_length(ctx: &mut TxContext): u64 {
    ctx.scratch_internal_get_fold!(NoteKey(), 0, |note: &String| note.length())
}
```

There are four of them, and all skip the function if there is no entry for the key:

- `get_do` / `get_mut_do` - call the function with an immutable or mutable reference to the value.
  They do nothing if the entry does not exist.
- `get_fold` / `get_mut_fold` - also return a result. They return whatever the function produces,
  or the provided default if the entry does not exist.

The macros call `begin_borrow` and `end_borrow` internally. These functions are public, but they are
not intended for direct use. `begin_borrow` temporarily removes the value and puts a `BorrowMarker`
in its slot. The marker is unique to the transaction, and `end_borrow` checks it before restoring the
value.

This design has two consequences. First, the macros take `&mut TxContext` even for read-only access.
Second, the provided function must not access the same key again. The slot contains only the marker
while the function runs, so a nested access to that key aborts instead of observing a partially
updated entry.

## Per-Transaction State

The scratchpad is useful because every call in a transaction sees the same state. A single
[transaction](./../concepts/what-is-a-transaction) can chain many commands that call many functions,
and each function can access the same scratchpad. This lets a program enforce rules across the
transaction as a whole, even when no single function can observe every call. For example, you can
limit how many times an action runs in one transaction, regardless of how it is called:

```move
/// Trying to perform the action more than `MAX_ACTIONS_PER_TX` times.
const ETooManyActions: u64 = 0;

/// The action may run at most 3 times per transaction.
const MAX_ACTIONS_PER_TX: u64 = 3;

/// Key for the per-transaction action counter.
public struct ActionCount() has copy, drop;

/// An action that can run at most `MAX_ACTIONS_PER_TX` times in a
/// single transaction, no matter who calls it or how.
public fun limited_action(ctx: &mut TxContext) {
    let count = ctx.scratch_internal_remove_opt!(ActionCount()).destroy_or!(0);
    assert!(count < MAX_ACTIONS_PER_TX, ETooManyActions);
    ctx.scratch_internal_add!(ActionCount(), count + 1);
    // ... perform the action
}
```

The counter lives for exactly one transaction. The first call finds nothing and starts from zero,
subsequent calls increment the counter, and the final value is dropped when the transaction ends.
This avoids cleanup, stale state, and storage costs. Without the scratchpad, the same pattern would
require a dedicated object and careful resetting.

A marker can enforce a stricter rule. In the following example, `one_time_action` adds a marker
before it performs the action. A second call in the same transaction finds the marker and aborts.
The `continue_after_action` function also checks the marker, so it only runs after the action has
completed exactly once:

```move
/// The one-time action has already run in this transaction.
const EActionAlreadyCalled: u64 = 1;

/// The one-time action has not run in this transaction.
const EActionNotCalled: u64 = 2;

/// Marks whether `one_time_action` has run in this transaction.
public struct ActionCalled() has copy, drop;

/// Perform an action at most once in a transaction.
public fun one_time_action(ctx: &mut TxContext) {
    assert!(!ctx.scratch_internal_exists!(ActionCalled()), EActionAlreadyCalled);
    ctx.scratch_internal_add!(ActionCalled(), true);
    // ... perform the action
}

/// Continue only after `one_time_action` has run exactly once.
public fun continue_after_action(ctx: &TxContext) {
    assert!(ctx.scratch_internal_exists!(ActionCalled()), EActionNotCalled);
    // ... continue with the next operation
}
```

The first check prevents a second successful call. The second check rejects a call to
`continue_after_action` when the transaction has skipped the action. Together, they guarantee that
`continue_after_action` follows exactly one call to `one_time_action` in the current transaction.

> Like other per-transaction resources, the scratchpad is bounded by a
> [protocol limit](./../guides/building-against-limits): a single transaction can hold at most
> 16,384 entries at the time of writing - 16 times the maximum number of commands in a transaction.

## Sharing Access

Because a `Permit` is an ordinary value, the defining module does not have to keep scratchpad access
to itself. It can issue a permit and give other code access to its entries:

```move
/// Issue a `Permit` for `NoteKey`, sharing access to the note with the
/// caller. Only this module can create it.
public fun grant_access(): Permit<NoteKey> {
    scratch::permit(internal::permit<NoteKey>())
}
```

The holder of a permit uses the explicit, permit-taking functions - here via their `TxContext`
method aliases:

```move
/// Replace the note, returning the previous one. Anyone holding a
/// `Permit<NoteKey>` can call this via the explicit, permit-based API.
public fun replace_note(
    permit: Permit<NoteKey>,
    note: String,
    ctx: &mut TxContext,
): Option<String> {
    ctx.scratch_replace(permit, NoteKey(), note)
}
```

Making the grant function `public` lets any caller obtain a permit and use every scratchpad
operation for that key type. This is useful when code outside the package needs direct access.

> If only modules in the same package need access, prefer a narrowly scoped `public(package)`
> function instead of handing out a `Permit`. The defining module keeps the permit and exposes only
> the operations that other modules need.

For example, the defining module can allow other modules in its package to replace the note without
giving them permission to perform every operation on `NoteKey`:

```move
/// Replace the note from another module in this package without exposing a
/// `Permit<NoteKey>` to the caller.
public(package) fun replace_note_in_package(
    note: String,
    ctx: &mut TxContext,
): Option<String> {
    ctx.scratch_internal_replace!(NoteKey(), note)
}
```

This follows the general [internal permit](./../move-basics/internal-permit) pattern. A permit value
carries the authority to act, so passing the value grants that authority. The `copy` ability makes a
shared permit reusable within the transaction, while the lack of `store` guarantees the `Permit`
cannot outlive it.

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
