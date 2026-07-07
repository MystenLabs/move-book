---
description: "The Capability pattern in Move: use owned objects as access-control tokens to authorize privileged operations in Sui smart contracts."
---

# Pattern: Capability

In programming, a _capability_ is a token that gives the owner the right to perform a specific
action. It is a pattern that is used to control access to resources and operations. A simple example
of a capability is a key to a door. If you have the key, you can open the door. If you don't have
the key, you can't open the door. A more practical example is an Admin Capability which allows the
owner to perform administrative operations, which regular users cannot.

## Capability is an Object

In the [Sui Object Model](./../object/), capabilities are represented as objects. An owner of an
object can pass this object to a function to prove that they have the right to perform a specific
action. Due to strict typing, the function taking a capability as an argument can only be called
with the correct capability.

> There's a convention to name capabilities with the `Cap` suffix, for example, `AdminCap` or
> `KioskOwnerCap`.

```move file=packages/samples/sources/programmability/capability.move anchor=main

```

## Using `init` for Admin Capability

A very common practice is to create a single `AdminCap` object on package publish. This way, the
application can have a setup phase where the admin account prepares the state of the application.

```move file=packages/samples/sources/programmability/capability-2.move anchor=admin_cap

```

Notice that this `AdminCap` has only the `key` ability, unlike the one in the first example, which
also had `store`. The [abilities](./../move-basics/abilities-introduction) of a capability define
how it can move between accounts: with `key` and `store`, the capability can be freely transferred
with public transfer functions and stored inside other objects; with only `key`, it can be
transferred only by functions defined in its module, so the module can restrict - or completely
forbid - passing the capability on. As described in the
[Storage Functions](./../storage/storage-functions) section, this is the difference between
internal and public transfer.

## Capabilities in the Sui Framework

The capability pattern is not just a convention - the [Sui Framework](./sui-framework) itself is
built around it. Knowing the standard capabilities helps recognize the pattern in real code; here
are the ones you are most likely to encounter:

- `sui::coin::TreasuryCap<T>` - created together with a new currency, grants the right to mint and
  burn coins of type `T`. Owning the `TreasuryCap` is owning the supply of the currency; we explore
  it in the [Balance and Coin](./balance-and-coin) chapter;
- `sui::package::UpgradeCap` - created when a package is published, authorizes future upgrades of
  the package. The owner of the `UpgradeCap` can also restrict future upgrades, or disable them
  completely by making the capability immutable;
- `sui::kiosk::KioskOwnerCap` - grants the right to `place`, `take`, and `list` items in a
  [Kiosk](https://docs.sui.io/standards/kiosk) - the trading primitive of Sui. While the `Kiosk`
  object itself is shared and accessible to everyone, the "owner" operations on it require the
  capability;
- `sui::transfer_policy::TransferPolicyCap<T>` - grants the right to manage a `TransferPolicy<T>`:
  add and remove trading rules, and withdraw the collected fees.

Two of these capabilities take a type parameter - a technique worth noting. By adding a
[generic](./../move-basics/generics) to the capability, the authority it grants is scoped to a
single type: a `TreasuryCap<GOLD>` controls the supply of `GOLD` and gives no rights over the
`SILVER` currency.

The framework also features a more general form of authority - the `Publisher` object, which proves
authority over all types of a package. It is covered separately in the
[Publisher Authority](./publisher) chapter.

## Address Check vs Capability

Utilizing objects as capabilities is a relatively new concept in blockchain programming. In other
smart-contract languages, authorization is often performed by checking the address of the sender.
This pattern is still viable on Sui, however, the overall recommendation is to use capabilities for
better security, discoverability, and code organization.

Let's look at how the `new` function that creates a user would look if it used the address check:

```move file=packages/samples/sources/programmability/capability-3.move anchor=with_address

```

And now, let's see how the same function looks with the capability:

```move file=packages/samples/sources/programmability/capability-4.move anchor=with_capability

```

Using capabilities has several advantages over the address check:

- Migration of admin rights is easier with capabilities due to them being objects. In case of
  address, if the admin address changes, all the functions that check the address need to be
  updated - hence, require a package upgrade.
- Function signatures are more descriptive with capabilities. It is clear that the `new` function
  requires the `AdminCap` to be passed as an argument. And this function can't be called without it.
- Object Capabilities don't require extra checks in the function body, and hence, decrease the
  chance of a developer mistake.
- An owned Capability also serves in discovery. The owner of the AdminCap can see the object in
  their account (via a Wallet or Explorer), and know that they have the admin rights. This is less
  transparent with the address check.

However, the address approach has advantages of its own. One case is a _multisig_ address - an
address controlled by multiple parties, where a transaction is only valid if enough of them sign
it. If the admin rights of an application belong to a multisig address, checking the sender may be
simpler than building a transaction that presents a capability object owned by that address.

Another case is an application with a central object - a config or a registry - that is already
passed into every function. Such an object can store the admin address as a regular field, and
checking it requires no extra inputs. The address is plain data, so it can be changed at runtime,
without a package upgrade. The same idea enables _revocation_: an owned capability, once
transferred, cannot be taken back from its owner, but an entry in a central registry - an address
or an ID of a previously issued capability - can be removed by the admin at any moment, instantly
revoking access.
