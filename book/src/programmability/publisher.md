# Publisher Authority

In application design and development, it is often needed to prove publisher authority. This is
especially important in the context of digital assets, where the publisher may enable or disable
certain features for their assets. The Publisher Object is an object, defined in the
[Sui Framework](./sui-framework.md), that allows the publisher to prove their _authority over a
type_.

## Definition

The Publisher object is defined in the `sui::package` module of the Sui Framework. It is a very
simple, non-generic object that can be initialized once per module (and multiple times per package)
and is used to prove the authority of the publisher over a type. To claim a Publisher object, the
publisher must present a [One Time Witness](./one-time-witness.md) to the `package::claim` function.

```move
// File: sui-framework/sources/package.move
public struct Publisher has key, store {
    id: UID,
    package: String,
    module_name: String,
}
```

> If you're not familiar with the One Time Witness, you can read more about it
> [here](./one-time-witness.md).

Here's a simple example of claiming a `Publisher` object in a module:

```move
{{#include ../../../packages/samples/sources/programmability/publisher.move:publisher}}
```

## Usage

The Publisher object has two functions associated with it which are used to prove the publisher's
authority over a type:

```move
{{#include ../../../packages/samples/sources/programmability/publisher.move:use_publisher}}
```

## Publisher as Admin Role

For small applications or simple use cases, the Publisher object can be used as an admin
[capability](./capability.md). While in the broader context, the Publisher object has control over
system configurations, it can also be used to manage the application's state.

```move
{{#include ../../../packages/samples/sources/programmability/publisher.move:publisher_as_admin}}
```

However, Publisher misses some native properties of [Capabilities](./capability.md), such as type
safety and expressiveness. The signature for the `admin_action` is not very explicit, can be
called by anyone else. And due to `Publisher` object being standard, there now is a risk of
unauthorized access if the `from_module` check is not performed. So it's important to be cautious
when using the `Publisher` object as an admin role.

## Role on Sui

Publisher is required for certain features on Sui. [Object Display](./display.md) can be created
only by the Publisher, and TransferPolicy - an important component of the Kiosk system - also
requires the Publisher object to prove ownership of the type.

## Next Steps

In the next chapter we will cover the first feature that requires the Publisher object - Object
Display - a way to describe objects for clients, and standardize metadata. A must-have for
user-friendly applications.
