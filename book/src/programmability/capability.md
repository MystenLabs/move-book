# Pattern: Capability

In programming, a _capability_ is a token that gives the owner the right to perform a specific
action. It is a pattern that is used to control access to resources and operations. A simple example
of a capability is a key to a door. If you have the key, you can open the door. If you don't have
the key, you can't open the door. A more practical example is an Admin Capability which allows the
owner to perform administrative operations, which regular users cannot.

## Capability is an Object

In the [Sui Object Model](./../object/), capabilities are represented as objects.
An owner of an object can pass this object to a function to prove that they have the right to
perform a specific action. Due to strict typing, the function taking a capability as an argument can
only be called with the correct capability.

> There's a convention to name capabilities with the `Cap` suffix, for example, `AdminCap` or
> `KioskOwnerCap`.

```move
{{#include ../../../packages/samples/sources/programmability/capability.move:main}}
```

## Using `init` for Admin Capability

A very common practice is to create a single `AdminCap` object on package publish. This way, the
application can have a setup phase where the admin account prepares the state of the application.

```move
{{#include ../../../packages/samples/sources/programmability/capability-2.move:admin_cap}}
```

## Address check vs Capability

Utilizing objects as capabilities is a relatively new concept in blockchain programming. And in
other smart-contract languages, authorization is often performed by checking the address of the
sender. This pattern is still viable on Sui, however, overall recommendation is to use capabilities
for better security, discoverability, and code organization.

Let's look at how the `new` function that creates a user would look like if it was using the address
check:

```move
{{#include ../../../packages/samples/sources/programmability/capability-3.move:with_address}}
```

And now, let's see how the same function would look like with the capability:

```move
{{#include ../../../packages/samples/sources/programmability/capability-4.move:with_capability}}
```

Using capabilities has several advantages over the address check:

- Migration of admin rights is easier with capabilities due to them being objects. In case of
  address, if the admin address changes, all the functions that check the address need to be
  updated - hence, require a [package upgrade](./package-upgrades.md).
- Function signatures are more descriptive with capabilities. It is clear that the `new` function
  requires the `AdminCap` to be passed as an argument. And this function can't be called without it.
- Object Capabilities don't require extra checks in the function body, and hence, decrease the
  chance of a developer mistake.
- An owned Capability also serves in discovery. The owner of the AdminCap can see the object in
  their account (via a Wallet or Explorer), and know that they have the admin rights. This is less
  transparent with the address check.

However, the address approach has its own advantages. For example, if an address is multisig, and
transaction building gets more complex, it might be easier to check the address. Also, if there's a
central object of the application that is used in every function, it can store the admin address,
and this would simplify migration. The central object approach is also valuable for revokable
capabilities, where the admin can revoke the capability from the user.
