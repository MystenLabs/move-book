---
description:
  'Package upgrades on Sui: how new versions are published, what the UpgradeCap is, how to make a
  package immutable, and how to version and migrate shared state.'
---

# Package Upgrades

As we mentioned in the [Packages](./../concepts/packages) concept, published packages are
_immutable_ - the bytecode stored onchain can never be modified or deleted. Yet real applications
need to evolve: bugs get fixed, features get added, and dependencies move forward. Sui reconciles
these two requirements with _package upgrades_ - a way to publish a new version of a package while
keeping every previous version intact.

This section explains the mechanics: what an upgrade can and cannot change, the `UpgradeCap` object
that authorizes upgrades, and - most importantly - what upgrades mean for the state your package
has already created. For design advice on writing upgrade-friendly code, see the
[Upgradeability Practices](./../guides/upgradeability-practices) guide.

## An Upgrade Is a New Package

An upgrade does not touch the published bytecode. Instead, it publishes the new version of the code
at a _new address_ and records it as the successor of the previous version. Both versions - in
fact, all versions ever published - remain onchain side by side:

```
0xAAA... <- version 1, published
0xBBB... <- version 2, upgrade of 0xAAA
0xCCC... <- version 3, upgrade of 0xBBB, the latest version
```

This has a consequence that is easy to miss: **old versions of a package remain callable**. An
upgrade does not redirect anyone - a transaction can still call functions of version 1 directly,
and packages that depend on version 1 keep calling version 1 until they upgrade their own
dependency. Publishing a fix does not, by itself, stop the buggy version from being used. We will
return to this point when we talk about [state](#upgrades-and-state).

Types, however, are not duplicated across versions. A struct keeps the identity of the package
version that first _defined_ it: a `Counter` type from version 1 is exactly the same type in
version 2, and objects created before the upgrade are fully compatible with the new code. A type
first added in version 2 belongs to version 2, and so on.

## What Can Change

An upgraded package must stay _compatible_ with the previous version, so that existing callers and
dependent packages don't break. Under the default - most permissive - upgrade policy, an upgrade
can:

- change the implementation of any function;
- add new modules, functions, and types;
- change, add, or remove `public(package)`, private, and non-public
  [`entry`](./../move-advanced/entry-functions) functions;
- change dependencies.

And it can not:

- remove a module;
- change or remove the signature of a `public` function;
- change or remove an existing type definition - fields, abilities, and type parameters of every
  struct and enum are frozen forever, whether public or not.

In short: public signatures and data layouts are permanent, implementations are not. This is why
the [Upgradeability Practices](./../guides/upgradeability-practices) guide recommends keeping
`public` surface minimal and structs thin - every `public` function and every struct field is a
commitment for the lifetime of the package.

## The `UpgradeCap`

When a package is published, the `Publish` command returns an `UpgradeCap` - an object defined in
the `sui::package` module of the [Sui Framework](./sui-framework). It is a classic
[capability](./capability): whoever owns it can upgrade the package, and no one else can.

```move
module sui::package;

/// Capability controlling the ability to upgrade a package.
public struct UpgradeCap has key, store {
    id: UID,
    /// (Mutable) ID of the package that can be upgraded.
    package: ID,
    /// (Mutable) The number of upgrades that have been applied
    /// successively to the original package.  Initially 0.
    version: u64,
    /// What kind of upgrades are allowed.
    policy: u8,
}
```

The `package` field always points at the latest version - only the latest version of a package can
be upgraded, so the chain of versions never forks. The upgrade itself is a three-step dance inside
a single transaction: `authorize_upgrade` takes the `UpgradeCap` and returns an `UpgradeTicket`;
the `Upgrade` transaction command consumes the ticket, verifies and publishes the new bytecode, and
returns an `UpgradeReceipt`; finally, `commit_upgrade` applies the receipt back to the
`UpgradeCap`. Both the ticket and the receipt are [hot potatoes](./hot-potato-pattern) - they
cannot be stored or dropped, so an authorized upgrade cannot be left half-finished. In practice the
whole flow is built for you by the `sui client upgrade` CLI command.

The `policy` field stores the most permissive kind of upgrade the capability allows. It starts at
_compatible_ - the default policy described [above](#what-can-change) - and can be restricted to
_additive_ (only new functionality can be added, existing code is frozen) or _dependency-only_
(only dependencies can be changed). Restriction is a one-way street: `only_additive_upgrades` and
`only_dep_upgrades` can tighten the policy, but nothing can loosen it back. And because
`authorize_upgrade` is a regular public function taking the `UpgradeCap`, the capability can be
wrapped in a custom object to enforce arbitrary upgrade rules - a timelock, a multisig, or a vote.

## Making a Package Immutable

The final restriction is giving up upgrades altogether. Deleting the `UpgradeCap` makes the package
truly immutable - no one will ever be able to publish a new version:

```move
/// Discard the `UpgradeCap` to make a package immutable.
public entry fun make_immutable(cap: UpgradeCap) {
    let UpgradeCap { id, package: _, version: _, policy: _ } = cap;
    id.delete();
}
```

This is irreversible, and that is exactly the point: it is the strongest guarantee a package can
offer. Users and dependent packages know the code they reviewed is the code that will run forever.
The trade-off is equally permanent - no bug can ever be fixed. Immutability is a common choice for
small foundational libraries, and a dangerous one for evolving applications.

## Upgrades and State

Objects are stored outside of packages, and an upgrade does not touch them: a shared object created
by version 1 is just as accessible to version 1 as it is to version 2. Combined with the fact that
old versions remain callable, this leads to the central problem of upgrades: **without explicit
versioning, the old code keeps full access to the state**. If version 2 fixes a bug in a function
that mutates a shared object, an attacker can simply keep calling the version 1 function - on the
very same object.

The solution is to version the state itself. The object carries a `version` field, the package
carries a `VERSION` constant, and every function that touches the object first checks that the two
match:

```move file=packages/samples/sources/programmability/package-upgrades.move anchor=versioned

```

Constants are baked into the bytecode, so each published version compares the object against its
own number: version 1 bytecode checks for `1`, version 2 bytecode checks for `2`. As long as the
object's field says `1`, the old code keeps working and the new code aborts - and the moment the
field is bumped to `2`, the situation flips: every call into the old version aborts with
`EVersionMismatch`, and only the latest code can proceed. Bumping the version is how the old
package is _decommissioned_.

## Migrating State

The version bump - the _migration_ - can be performed in two ways, and the choice depends on how
much state there is and who can reach it.

The straightforward way is an _eager_ migration: right after the upgrade, the holder of an admin
[capability](./capability) calls a `migrate` function which bumps the version of the shared object
in a single transaction:

```move file=packages/samples/sources/programmability/package-upgrades.move anchor=migrate

```

Eager migration is a clean cut-over and is the right choice when the state is a handful of shared
objects the publisher controls. It falls short when it can't reach everything: an application may
have thousands of objects, or the objects may be _owned_ by users - and only the owner can send a
transaction touching an owned object.

For these cases there is _lazy_ migration: instead of migrating everything up front, each object is
migrated the first time the new code touches it. This is also the answer to a limitation we saw
[earlier](#what-can-change) - struct layouts can never change, so how does state evolve at all? By
keeping the base object thin and storing the actual content in a [dynamic field](./dynamic-fields),
which can be swapped for a new shape at any time:

```move file=packages/samples/sources/programmability/package-upgrades-2.move anchor=lazy

```

Version 1 of this package attached a `ConfigV1` to the object; version 2 defines a richer
`ConfigV2` and quietly replaces the old value on first access. No coordinated migration is needed -
objects upgrade themselves as they are used, whether there are ten of them or ten million, owned or
shared.

## Summary

- An upgrade publishes a new version of a package at a new address; all previous versions stay
  onchain and _remain callable_.
- Compatibility rules protect callers: implementations can change and new code can be added, but
  `public` function signatures and type definitions are permanent.
- The `UpgradeCap` is the capability authorizing upgrades; its policy can be restricted one way -
  from compatible to additive to dependency-only - and deleting it via `make_immutable` makes the
  package immutable forever.
- State is not part of the package: without explicit versioning, old versions keep full access to
  shared objects. A `version` field checked against a package `VERSION` constant decommissions old
  code.
- Migrations can be _eager_ - an admin bumps the version right after the upgrade - or _lazy_ -
  each object migrates on first access, which also allows evolving the shape of the state through
  dynamic fields.

## Further Reading

- [Upgradeability Practices](./../guides/upgradeability-practices) guide on designing
  upgrade-friendly packages.
- [Package Upgrades](https://docs.sui.io/concepts/sui-move-concepts/packages/upgrade) in the Sui
  documentation.
- [Custom Upgrade Policies](https://docs.sui.io/concepts/sui-move-concepts/packages/custom-policies)
  in the Sui documentation.
