# UID and ID

The [`key` ability](./key-ability.md) is de-facto a defining ability of an object, but it comes with
a requirement to have the `UID` field. In this section we will talk about the `UID` type, and its
inner `ID` type.

> Both `UID` and `ID` types are implicitly imported, together with the `sui::object` module. And
> don't need to be imported explicitly. See
> [Sui Framework](./../programmability/sui-framework.md#implicit-imports) for more details and other
> implicit imports.

## Definition

<!-- The `UID` type is defined in the `sui::object` module and is a wrapper around an `ID` which, in
turn, wraps the `address` type. The UIDs on Sui are guaranteed to be unique, and can't be reused
after the object was deleted. -->

The `UID` type is a unique identifier of an object on Sui. It wraps an `ID` type, which, in turn,
wraps an [`address`](./../move-basics/address.md) type. The `UID` is guaranteed to be unique, and
must be passed freshly created for each new object.

```move
// File: sui-framework/sources/object.move
/// UID is a unique identifier of an object
public struct UID has store {
    id: ID
}

/// ID is a wrapper around an address
public struct ID has store, drop {
    bytes: address
}
```

## UID lifecycle

The `UID` type is created with the `object::new` function, and is destroyed with the
`object::delete`. The `object::delete` consumes the UID _by value_, hence it is not possible to
delete the UID unless it is unpacked from the object.

```move
{{#include ../../../packages/samples/sources/storage/uid-and-id.move:lifecycle}}
```

In the example above, in the `new` function, the `Character` object is created with a new UID. In
the `delete` function, the `Character` is unpacked, its `id` field is moved to the function scope,
and the UID is deleted by calling `id.delete()` (shorthand for `object::delete(id)`).

An attempt to reuse the UID in a new object will result in a compilation error:

```move,fails
public fun recreate(c: Character): Character {
    let Character { id } = c; // unpack the object
    Character { id } // attempt to reuse the UID in a new object
}
// Error! `The UID must come directly from sui::object::new`
```

However, the unpacked UID can still be stored in objects, as long as it is not used in the `id`
field of a struct with the `key` ability. In the example below, we show an imaginary `Character`
object migrated to a new version, and the old UID is stored in the `old_uid` field.

```move
{{#include ../../../packages/samples/sources/storage/uid-and-id.move:migration}}
```

## Fresh UID generation

It is important to mention how the `UID` is generated. Every transaction has a `digest` which is a
hash of the transaction data. The digest is guaranteed to be unique for each transaction, since it
is impossible to have two transactions with identical inputs (at least the version of the gas object
will change).

The `tx_hash` is stored inside the `TxContext` and is provided to the runtime by the VM. And the
`UID` is derived from the `tx_hash` and an `index` which is incremented for each new UID. That is
why the `TxContext` is required for UID generation, and why it has to be passed _mutably_ to the
`object::new` function.

Internally, the `object::new` function calls the `tx_context::fresh_object_address` function to
generate the `address` which is then wrapped in the `ID` and `UID` types. This method is publicly
available in the `tx_context` module and can be used in your program to generate unique addresses.

```move
// File: sui-framework/sources/tx_context.move
/// Create an `address` that has not been used. As it is an object address, it will never
/// occur as the address for a user.
/// In other words, the generated address is a globally unique object ID.
public fun fresh_object_address(ctx: &mut TxContext): address {
    let ids_created = ctx.ids_created;
    let id = derive_id(*&ctx.tx_hash, ids_created);
    ctx.ids_created = ids_created + 1;
    id
}
```

The TxContext was explained in detail in the
[Transaction Context](./../storage/transaction-context.md) chapter.

<!--
## Deterministic UID generation

To illustrate that, let's write a simple test where we create two objects from the same context,
something that is impossible to do in a real-world scenario, but is useful for demonstration
purposes.

<div class="warning">

The example below intentionally makes the mistake of creating two objects from the same context.
This is not allowed in a real-world scenario, and should be carefully avoided in your test code.

</div>

```move
{{#include ../../../packages/samples/sources/storage/uid-and-id.move:uid-generation}}
```


In the example above, we show that the `UID` is derived from the `tx_hash`, and that the `UID` is
deterministically generated if the `tx_hash` and the `index` are the same. We also show, that the
next `UID` is different even with the same `tx_hash` due to the `index` being incremented.

-->

## ID & Relationship with UID

When talking about `UID`s we should also mention the `ID` type. It is a wrapper around the `address`
type, and is used to represent an address-pointer. Usually, `ID` is used to point at an object,
however, there's no restriction, and no guarantee that the `ID` points to an existing object.

> ID can be received as a transaction argument in a
> [Transaction Block](./../concepts/what-is-a-transaction.md). Alternatively, ID can be created from
> an `address` value using `to_id()` function.

The `ID` can be copied from the `UID` or constructed from an `address` value. Receiver style syntax
comes in handy:

```move
{{#include ../../../packages/samples/sources/storage/uid-and-id.move:id_methods}}
```

<!--
The `Pointer` type in the example below contains the `to` field with the type `ID`. The function
`new_pointer` takes the `ID` as an argument, and can be called in a transaction block - the
execution layer will automatically convert an `address` input to an `ID`.

```move
{{#include ../../../packages/samples/sources/storage/uid-and-id.move:using_id}}
```
-->

## Summary

- The `UID` type is a unique identifier of an object on Sui. It is created with the `object::new`
  function, and is destroyed with the `object::delete`.
- The `UID` is derived from the `TxContext`'s `tx_hash` and an `index` which is incremented for each
  new UID. Hence, the address generation is deterministic and unique.
- The `ID` type is a wrapper around the `address` type, which can be copied from the `UID`,
  constructed from an `address` value or taken as a transaction argument.
