# Transfer to Object?

The `transfer` function which we have seen in the [Storage Functions](./storage-functions.md) takes
a destination [address](./../move-basics/address.md) as an argument. All examples that we mentioned
before considered the destination address to be an account. However, there is a scenario where the
destination address is not an account but an object. In this case, the `transfer` function will
transfer the resource to the object's address (stored inside the [UID](./uid-and-id.md)).

<div class="warning">

The information in this section contains an advanced concept which should be used with caution. We
believe that is important to cover this topic in this chapter to complete the understanding of the
object model and storage operations. However, it is recommended to use this feature fully aware of
the implementation details and potential risks.

</div>

<!--
> _Transfer to Object_ requires the destination object to allow _receiving_ the transferred object.
> It has to be taken into account when making a decision to perform a transfer to an object.
-->

## Recap: Transfer Functions

Practically speaking, nothing in the `transfer` implementation prevents the user / developer from
transferring the object to an object, or to a package, or to an account, even the non-existent one.
However, while an account can receive and own an object without any issues, an object transferred to
a package or non-existent address is considered lost.

```move
// File: sui-framework/sources/transfer.move
// Restricted transfer for types internal to the module.
public fun transfer<T: key>(t: T, to: address);

// Public transfer for types external to the module.
public fun public_transfer<T: key + store>(t: T, to: address);
```

The public and non-public signatures for the _transfer_ operation are shown above. They don't have
any restrictions on the destination address.

## Sending to an Object

With objects, the destination address is the value stored in the UID field of the object. It can be
retrieved either using `object::id` and then converting it to an address; or directly using the
`object::uid_to_address` function, if the object is defined in the same module as the caller.

<!--
> Rule #1: While a developer might be tempted to implement a transfer to a generic `T` type, it is
> a dangerous unrestrictive practice. The custom transfer function should be
-->

```move
{{#include ../../../packages/samples/sources/storage/transfer-to-object.move:send_to_object}}
```



##

## Use Cases
