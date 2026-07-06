---
description: "Sui storage functions: transfer, share, freeze, and receive objects using the sui::transfer module in Move smart contracts."
---

# Storage Functions

The module that defines the main storage operations is `sui::transfer`. It is implicitly imported
in all packages that depend on the [Sui Framework](./../programmability/sui-framework), so, like
other implicitly imported modules (e.g. `std::option` or `std::vector`), it does not require a
`use` statement.

> For quick reference, [Appendix C: Transfer Functions](./../appendix/transfer-functions) contains
> a list of all storage functions and object states.

## Overview

The `transfer` module provides a function for each of the
[ownership states](./../object/ownership) an object can be placed into:

1. [Transfer](#transfer) - send an object to an address, putting it into the _address owned_
   state;
2. [Freeze](#freeze) - put an object into the _immutable_ state, making it a _public constant_
   that can never change;
3. [Share](#share) - put an object into the _shared_ state, available to everyone.

The `transfer` module is the go-to for most storage operations. Two special cases are covered
separately: [Dynamic Fields](./../programmability/dynamic-fields) - attaching data to objects - in
the next chapter, and [receiving objects sent to other objects](./transfer-to-object) at the end
of this one.

## Ownership and References: a Quick Recap

Storage functions build directly on the semantics from the
[Ownership and Scope](./../move-basics/ownership-and-scope) and
[References](./../move-basics/references) sections. All of them take the object _by value_: the
object is moved into the function, the caller loses it - and, as we are about to see, it ends up
in storage, in its new state. This is the resource model at work: an object is never copied into
storage, it is _placed_ there, and the previous owner provably gives it up. A function that only
needs to read or update an object, on the other hand, takes it by reference (`&T` or `&mut T`) and
leaves the ownership state untouched.

## Internal Rule in Transfer Functions

Each storage operation comes in two forms: _internal_ and _public_. The internal functions -
`transfer`, `share_object`, `freeze_object` - enforce the
[internal constraint](./internal-constraint) from the previous section: they can only be called in
the module that defines the type of the object. The public versions - prefixed with `public_` -
lift that restriction, but require the type to have [`store`](./store-ability) in addition to
`key`:

```move
/// Internal: can only be called in the module that defines `T`.
public fun transfer<T: key>(obj: T, recipient: address);

/// Public: callable from any module, but requires `T` to have `store`.
public fun public_transfer<T: key + store>(obj: T, recipient: address);
```

Together, the two forms implement the rule we previewed in the
[store ability](./store-ability#relation-to-key) section: storage of a `key`-only object is fully
governed by its defining module, while `store` opens the object up to storage operations performed
by any module - and by the owner directly, in a transaction.

To see every combination at once, suppose module `book::transfer_a` defines two objects - `ObjectK`
with `key` and `ObjectKS` with `key + store` - and module `book::transfer_b` tries to transfer
them:

```move
/// Imports the `ObjectK` and `ObjectKS` types from `transfer_a` and attempts
/// to implement different `transfer` functions for them.
module book::transfer_b;

// The types are not internal to this module!
use book::transfer_a::{ObjectK, ObjectKS};

// Fails! `ObjectK` is not internal to this module.
public fun transfer_k(k: ObjectK, to: address) {
    transfer::transfer(k, to);
}

// Fails! `ObjectKS` is not internal to this module either -
// `store` does not affect the internal functions.
public fun transfer_ks(ks: ObjectKS, to: address) {
    transfer::transfer(ks, to);
}

// Fails! `public_transfer` requires `store`, and `ObjectK` does not have it.
public fun public_transfer_k(k: ObjectK, to: address) {
    transfer::public_transfer(k, to);
}

// Works! `ObjectKS` has `store`, and the function is public.
public fun public_transfer_ks(ks: ObjectKS, to: address) {
    transfer::public_transfer(ks, to);
}
```

The same matrix applies to `share_object`/`public_share_object` and
`freeze_object`/`public_freeze_object`. Knowing this rule is critical for understanding
application design in Move: the choice between making an object publicly transferable
(`key + store`) and keeping it internal (`key`-only) drastically affects the guarantees the
application can give about its assets.

## Transfer

The `transfer::transfer` function sends an object to an address, making that address its sole
owner:

```move
module sui::transfer;

// Transfer `obj` to `recipient`.
public fun transfer<T: key>(obj: T, recipient: address);

// Public version of the `transfer` function.
public fun public_transfer<T: key + store>(obj: T, recipient: address);
```

In the following example, a module creates an object representing the application's admin rights
and sends it to the publisher of the module:

```move file=packages/samples/sources/storage/storage-functions.move anchor=admin_cap

```

When the module is published, the `init` function is called, and the `AdminCap` object created in
it is _transferred_ to the transaction sender - `ctx.sender()` returns the sender address of the
current transaction. (The `init` function is covered in detail in the
[Module Initializer](./../programmability/module-initializer) section.)

From that point, say the sender was `0xa11ce`, the object is in the _address owned_ state: only
`0xa11ce` can use it in a transaction - by reference or by value, including transferring it
further with the `transfer_admin_cap` function above.

> Address-owned objects are subject to _true ownership_ - only the owner address can access them.
> This is a fundamental concept in the Sui storage model, introduced in the
> [Ownership](./../object/ownership#account-owner-or-single-owner) section.

### Public Transfer

Let's extend the example with a function that uses the `AdminCap` to authorize minting of a new
object and transferring it to any address:

```move file=packages/samples/sources/storage/storage-functions.move anchor=mint_and_transfer

```

The `mint_and_transfer` function "could" be called by anyone - it is public - but it requires an
`AdminCap` reference as its first argument, and the `AdminCap` object is owned by `0xa11ce`
exclusively. So in practice only `0xa11ce` can mint. This simple and explicit way of gating access
to a function is the _[Capability pattern](./../programmability/capability)_, one of the
cornerstones of Sui application design.

Note the difference between the two objects in this example. `AdminCap` is `key`-only: the module
keeps full control over it, and if the module exposed no `transfer_admin_cap` function, the admin
rights would be _soulbound_ - impossible to give away. `Gift` has `key + store`: it is sent with
`public_transfer`, and whoever owns a `Gift` can freely transfer it onward in their own
transactions, without any help from this module.

### Quick Recap

- `transfer` sends an object to an address, making it _address owned_;
- Only the owner can use an address-owned object - by reference or by value;
- Requiring a `key`-only object as an argument gates a function to the object's owner - the
  _Capability_ pattern;
- `public_transfer` is the public form: callable anywhere, requires `key + store`.

## Freeze

The `transfer::freeze_object` function puts an object into the _immutable_ state. Once an object
is _frozen_, it can never change, and anyone can access it by immutable reference:

```move
module sui::transfer;

// Make the object immutable and allow anyone to read it.
public fun freeze_object<T: key>(obj: T);

// Public version of the `freeze_object` function.
public fun public_freeze_object<T: key + store>(obj: T);
```

Let's extend the running example with a `Config` object that the admin creates and freezes:

```move file=packages/samples/sources/storage/storage-functions.move anchor=config

```

Once `create_and_freeze` is called, the `Config` becomes publicly available by its ID, and the
`message` function can be called by anyone - on a frozen object, immutable references are free for
the taking.

Function definitions are not tied to the object's state, so it is perfectly legal to _define_
functions that take a frozen type by mutable reference or by value - they just cannot be _called_
with a frozen object:

```move file=packages/samples/sources/storage/storage-functions.move anchor=frozen_uncallable

```

The same applies to `delete_config`, defined below in the [Share](#share) section: it takes
`Config` by value, and a frozen `Config` can never be passed to it. Freezing is _permanent_:
a frozen object cannot be modified, transferred, deleted - or unfrozen.

### Owned → Frozen

Since the `freeze_object` signature accepts any object by value, it can receive an object created
in the same scope, but also an object the sender _owns_. Single Owner → Immutable conversion is
possible! For example, an owner of a `Gift` can decide to preserve it forever:

```move file=packages/samples/sources/storage/storage-functions.move anchor=freeze_gift

```

For obvious security reasons, this is also something to keep in mind in the other direction: an
`AdminCap` must never be frozen - a frozen capability would be readable by everyone, and every
function gated by `&AdminCap` would become callable by anyone. Which, once again, shows the value
of the `key`-only pattern: `AdminCap` has no `store`, so external code has no way to freeze it,
and the module simply does not expose a freezing function.

### Quick Recap

- `freeze_object` puts an object into the _immutable_ state - permanently;
- A frozen object is readable by anyone via immutable reference, and can never be modified,
  transferred, or deleted;
- Owned objects can be frozen - including by their owner in a transaction, if the object has
  `store`;
- `public_freeze_object` is the public form: callable anywhere, requires `key + store`.

## Share

The `transfer::share_object` function puts an object into the _shared_ state, where anyone can
access it by mutable (and hence also immutable) reference:

```move
module sui::transfer;

/// Put the object into the shared state - accessible to everyone.
public fun share_object<T: key>(obj: T);

/// Public version of the `share_object` function.
public fun public_share_object<T: key + store>(obj: T);
```

```move file=packages/samples/sources/storage/storage-functions.move anchor=share

```

Unlike `freeze_object`, which accepts both new and owned objects, `share_object` has a runtime
restriction: **only an object created in the same transaction can be shared**. An attempt to share
an object that already exists in the owned state aborts with `ESharedNonNewObject`. There is no
Owned → Shared conversion: the decision to make an object shared has to be made at its creation.
And like freezing, sharing is one-way - once shared, an object stays shared for the rest of its
life, with a single exception, which we look at next.

### Special Case: Shared Object Deletion

While a shared object can't normally be taken by value, there is one special case where it can -
if the function that takes it _deletes_ it. This is a special case in the Sui storage model, made
to allow cleaning up shared state. Let's add a function that deletes the shared `Config`:

```move file=packages/samples/sources/storage/storage-functions.move anchor=delete_shared

```

The `delete_config` function takes the `Config` by value and destroys it completely - unpacking
the struct and deleting the `UID` - and the Sui Verifier allows this call. However, if the
function returned the `Config`, or attempted to `transfer` or `freeze` it, the transaction would
be rejected:

```move
// Won't work!
public fun transfer_shared(c: Config, to: address) {
    transfer::transfer(c, to);
}
```

The rule: a shared object taken by value must be deleted in the same transaction.

### Quick Recap

- `share_object` puts an object into the _shared_ state, accessible to everyone by mutable
  reference;
- Only an object created in the same transaction can be shared - there is no Owned → Shared
  conversion;
- Sharing is permanent, with one exception: a shared object may be taken by value in order to be
  _deleted_;
- `public_share_object` is the public form: callable anywhere, requires `key + store`.

## Party Transfer

The `transfer` module also provides `party_transfer` and `public_party_transfer`, which place an
object into the [party state](./../object/ownership#party-objects) - single-owner access with
consensus ordering. Party objects are an advanced, newer feature, and we leave them out of the
running example; the function signatures are listed in
[Appendix C](./../appendix/transfer-functions#party), and the details are covered in the
[`sui::party`](https://docs.sui.io/references/framework/sui/party) module documentation.

## Summary

| Function         | Resulting state | Reversible?                                             | Public version          |
| ---------------- | --------------- | ------------------------------------------------------- | ----------------------- |
| `transfer`       | Address owned   | Yes - transfer away                                     | `public_transfer`       |
| `freeze_object`  | Immutable       | No                                                      | `public_freeze_object`  |
| `share_object`   | Shared          | Only by deletion                                        | `public_share_object`   |
| `party_transfer` | Party           | [Depends on permissions](./../appendix/transfer-functions#party) | `public_party_transfer` |

- Every storage function takes the object _by value_ - placing an object into storage consumes it;
- Internal versions require the type to be defined in the calling module; `public_*` versions
  require `store` instead.

## Next Steps

Now that you know the main features of the `transfer` module, you can start building applications
that involve storage operations. In the next section we cover the [UID and ID](./uid-and-id)
types - the identity of every object - and after that, [Receiving as Object](./transfer-to-object),
the mechanism behind objects owning other objects.

## Further Reading

- [`sui::transfer`](https://docs.sui.io/references/framework/sui/transfer) module documentation.
- [Appendix C: Transfer Functions](./../appendix/transfer-functions).
