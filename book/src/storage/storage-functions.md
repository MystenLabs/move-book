# Storage Functions

The `sui::transfer` module defines all storage operations in Sui. It provides functions to transfer
an object to an address, share and freeze an object. These functions are used to manage the
ownership of objects in the Sui storage model.

## Overview

> On this page we will only talk about so-called _restricted_ storage operations, which can be
> performed only by the module declaring the object. [Later](./transfer-restrictions.md) we will
> cover _public_ ones, after the [`store` ability](./store-ability.md) is introduced.

The `transfer` module provides functions to perform all three storage operations matching
[ownership types](./../object/ownership.md) which we explained before:

1. _Transfer_ - send an object to an _address_, put it into _address-owned_ state;
2. _Share_ - put an object into a _shared_ state, so it is available to everyone;
3. _Freeze_ - put an object into _immutable_ state, so it becomes a public constant and can never
   change.

The `transfer` module is a go-to for most of the storage operations, except a special case with
[Dynamic Fields](./../programmability/dynamic-fields.md) which awaits its own chapter.

## Ownership and References: A Quick Recap

In the [Ownership and Scope](./../move-basics/ownership-and-scope.md) and
[References](./../move-basics/references.md) chapters, we covered the basics of ownership and
references in Move. It is important that you understand these concepts when using storage functions.
Here is a quick recap of the most important points:

- The _move_ semantics in Move means that the value is _moved_ from one scope to another. In other
  words, if an instance of a type is passed to a function _by value_, it is _moved_ to the function
  scope and can't be accessed in the caller scope anymore.
- To maintain the ownership of the value, you can pass it _by reference_. Either by _immutable
  reference_ `&T` or _mutable reference_ `&mut T`. Then the value is _borrowed_ and can be accessed
  in the caller scope, however the owner stays the same.

Here is an example of how all three types of access can be used in Move:

```move
/// Moved by value
public fun take<T>(value: T) { /* value is moved here! */ abort 0 }

/// For immutable reference
public fun borrow<T>(value: &T) { /* value is borrowed here! can be read */ abort 0 }

/// For mutable reference
public fun borrow_mut<T>(value: &mut T) { /* value is mutably borrowed here! */ abort 0 }
```

In the `take` function, the value is _moved_ to the function scope and can't be accessed in the
caller scope anymore. In the `borrow` function, the value is _borrowed_ by immutable reference and
can be read in the function scope while not changing ownership. In the `borrow_mut` function, the
value is _mutably borrowed_ and can be read and modified in the function scope while also not
changing the owner.

<!--
TODO part on:
    - object does not have an associated storage type
    - the same type of object can be stored differently
    - the objects must be specified in the transaction by their ID
 -->

## Transfer

The `transfer::transfer` function is a public function used to transfer an object to another
address. Its signature is as follows, only accepts a type with the [`key` ability](./key-ability.md)
and an [address](./../move-basics/address.md) of the recipient. Note that the object is passed into
the function _by value_, therefore it is _moved_ to the function scope and then moved to the
recipient address:

```move
// File: sui-framework/sources/transfer.move
public fun transfer<T: key>(obj: T, recipient: address);
```

Once the object is transferred, it becomes _address owned_ and can only be accessed by the
recipient. Let's imagine a scenario where Alice creates an object with a unique ID `0x0B7` and
transfers it to Bob. Alice will no longer be able to access the object, but Bob, being a new owner,
can access it by its ID.

### Example

In this example, we declare an `AdminCap` object - an admin
[capability](../programmability/capability.md) - which is created once in the `init` function and
then transferred to the transaction sender.

> The module `init` function is a special function that is called when the module is published. We
> cover it in the [Module Initializer](./../programmability/module-initializer.md) chapter.

```move
{{#include ../../../packages/samples/sources/storage/storage-functions.move:transfer}}
```

When the module is published, the `init` function will get called, and the newly created `AdminCap`
object will be _transferred_ to the transaction sender. The `ctx.sender()` function returns the
sender address for the current transaction.

Once the `AdminCap` has been transferred to the sender address, the sender, and only the sender,
will be able to access the object. The object is now _address owned_.

### Usage

> Account owned objects are a subject to _true ownership_ - only the account owner can access them.
> This is a fundamental concept in the Sui storage model.

Now, that the publisher has the `AdminCap` object, they can use it to authorize certain functions.
In the example below, the `mint_and_transfer` function is a public function that requires the
`AdminCap` object to be passed as the first argument by reference. Without it, the function will not
be callable. The function creates a new `Gift` object and transfers it to the recipient:

```move
{{#include ../../../packages/samples/sources/storage/storage-functions.move:mint_and_transfer}}
```

The `Gift`s sent to recipients will also be _address owned_, each gift being unique and owned
exclusively by the recipient.

### Summary

- `transfer` function is used to send an object to an address;
- The object becomes _address owned_ and can only be accessed by the recipient;
- Functions can be _"gated"_ by a capability - only callable if an object is presented as an
  argument.

## Freeze Object

The `transfer` function implements exclusive ownership, but there are applications which require
data to be accessible by everyone - for example, a configuration object. To allow this, Sui provides
a way to _freeze_ an object, making it _immutable_ and publicly accessible. For that, the
`transfer::freeze` function is used.

The function signature is as follows, only accepts a type with the
[`key` ability](./key-ability.md). Just like all other storage functions, it takes the object _by
value_. Unlike the `transfer` function, it does not require an address to transfer the object to, as
the object is not transferred but _frozen_ in place:

```move
// File: sui-framework/sources/transfer.move
public fun freeze_object<T: key>(obj: T);
```

### Usage

To demonstrate the `freeze_object` function, let's create a `Config` object that the admin can
create and freeze. The `Config` object has a `message` field, and the `create_and_freeze` function
creates a new `Config` object and freezes it. Once the object is frozen, it can be accessed by
anyone on the network by immutable reference:

```move
{{#include ../../../packages/samples/sources/storage/storage-functions.move:freeze}}
```

The `message` function can be called on an immutable `Config` object, however, two functions below
are not callable on a frozen object, as they require a mutable reference and the object by value
(respectively):

```move
// === Functions below can't be called on a frozen object! ===

{{#include ../../../packages/samples/sources/storage/storage-functions.move:modify_config}}

{{#include ../../../packages/samples/sources/storage/storage-functions.move:delete_config}}
```

### Summary

- `freeze_object` function is used to put an object into an _immutable_ state;
- Once an object is _frozen_, it can never be changed, deleted or transferred, and it can be
  accessed by anyone by immutable reference;

## Owned -> Frozen

Since the `transfer::freeze` signature accepts any type with the `key` ability, it can take an
object that was created in the same scope, but it can also take an object that was owned by an
account. This means that the `freeze_object` function can be used to _freeze_ an object that was
_transferred_ to the sender. For security concerns, we would not want to freeze the `AdminCap`
object - it would be a security risk to allow access to it to anyone. However, we can freeze the
`Gift` object that was minted and transferred to the recipient:

> Single Owner -> Immutable conversion is possible!

```move
{{#include ../../../packages/samples/sources/storage/storage-functions.move:freeze_owned}}
```

## Share Object

The last storage operation we will cover in this chapter is _sharing_ an object. The `transfer`
function puts an object into an _address owned_ state, and the `freeze` makes it public and
_immutable_. The _shared_ state is a state where the object is publicly available to everyone and
can be accessed by a mutable reference.

> Shared objects are require consensus, however, read operations can be executed in parallel.

The function signature is as follows, only accepts a type with the
[`key` ability](./key-ability.md). The object is passed into the function _by value_, and does not
require any other arguments:

```move
// File: sui-framework/sources/transfer.move
public fun share_object<T: key>(obj: T);
```

Once an object is _shared_, it is publicly available as a mutable reference.

### Usage

To demonstrate the `share_object` function, let's create another function which, instead of freezing
the `Config` object, shares it. The `create_and_share` function creates a new `Config` object and
calles the `transfer::share_object` on it. The object created this way can be modified by the admin:

```move
{{#include ../../../packages/samples/sources/storage/storage-functions.move:share}}
```

The functions that could not be called on a frozen object can now be called on a shared object:

```move
// === Functions below can be called on a shared object! ===

{{#include ../../../packages/samples/sources/storage/storage-functions.move:modify_config}}
```

### Special Case: Shared Object Deletion

While the shared object can't normally be taken by value, there is one special case where it can -
if the function that takes it deletes the object (or re-shares it). This is a special case in the
Sui storage model, and it is used to allow the deletion of shared objects. The `delete_config`
function defined below will work:

```move
{{#include ../../../packages/samples/sources/storage/storage-functions.move:delete_config}}
```

However, an attempt to transfer or freeze a shared object will result in an error:

```move
// Won't work! Can't change ownership from shared to address owned.
public fun transfer_shared(c: Config, to: address) {
    transfer::transfer(c, to);
}
```

### Summary

- `share_object` function is used to put an object into a _shared_ state;
- Once an object is _shared_, it can be accessed by anyone by a mutable reference;
- Shared objects can be deleted, but they can't be transferred or frozen.

## Next Steps

Now that you know main features of the `transfer` module, you can start building more complex
applications on Sui that involve storage operations. In the next chapter, we will cover the
[Store Ability](./store-ability.md) which allows storing data inside objects and relaxes transfer
restrictions which we barely touched on here. And after that we will cover the
[UID and ID](./uid-and-id.md) types which are the most important types in the Sui storage model.
