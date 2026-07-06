---
description: "The Publisher object in Sui: prove package authority to configure Display, transfer policies, and other type-level settings."
---

# Publisher Authority

Applications often need to prove _who published a type_. This is especially important in the
context of digital assets, where the publisher may enable or disable certain features for their
assets. The Publisher object, defined in the [Sui Framework](./sui-framework), is what allows the
publisher to prove their _authority over a type_.

## Definition

The Publisher object is defined in the `sui::package` module of the Sui Framework. It is a very
simple, non-generic object that can be initialized once per module (and multiple times per package)
and is used to prove the authority of the publisher over a type. To claim a Publisher object, the
publisher must present a [One Time Witness](./one-time-witness) to the `package::claim` function.

```move
module sui::package;

public struct Publisher has key, store {
    id: UID,
    package: String,
    module_name: String,
}
```

Here's a simple example of claiming a `Publisher` object in a module:

```move file=packages/samples/sources/programmability/publisher.move anchor=publisher

```

> For the common claim-and-transfer flow, the `sui::package` module also provides a shorthand -
> `package::claim_and_keep` - which claims the `Publisher` object and transfers it to the sender in
> one call.

## Usage

The Publisher object has two functions associated with it - `from_module` and `from_package` -
which check whether a type was defined in the module or package this `Publisher` stands for:

```move file=packages/samples/sources/programmability/publisher.move anchor=use_publisher

```

## Publisher as Admin Role

For small applications or simple use cases, the Publisher object can be used as an admin
[capability](./capability). While in the broader context, the Publisher object has control over
system configurations, it can also be used to manage the application's state.

```move file=packages/samples/sources/programmability/publisher.move anchor=publisher_as_admin

```

However, the Publisher object lacks some of the native properties of
[Capabilities](./capability), such as type safety and expressiveness. The signature of
`admin_action` says nothing about the required authority - the function can be called by anyone
holding _any_ `Publisher` object, so the authorization must be checked inside the function body.
And since every published package produces a `Publisher`, forgetting the `from_module` check opens
the action to every publisher on the network. For these reasons, it is important to be cautious
when using the `Publisher` object as an admin role.

## Role on Sui

Publisher is required for certain features on Sui. [Object Display](./display) can be created with
the Publisher when it is set up outside of the module defining the type, and TransferPolicy - an
important component of the Kiosk system - also requires the Publisher object to prove ownership of
the type.

## Next Steps

In the next section we will cover the first feature that can use the Publisher object - Object
Display - a way to describe objects for clients, and standardize metadata. A must-have for
user-friendly applications.
