---
draft: true
description: |
  Package Upgrades in Move: what can be upgrades, introduction of new types, updating
  dependencies and function versioning.
---

# Package Upgrades

> Note: This page focuses on package upgrades and their effects in Move. For better understanding of
> package upgrades on Sui and tooling-related topics, refer to
> [Sui Documentation](https://docs.sui.io/concepts/sui-move-concepts/packages/upgrade).

Move packages, being addressed collections of modules published on Sui, can be upgraded. In this
section you will find everything you may need to understand package upgrades in Move.

<!-- ## Introducing New Types & Type Reflection -->

## What Can Be Upgraded?

Short answer: any non-public members. Sui restricts changes to any public module members

## Update Capability

Upgrades are authorized using the `UpgradeCap` - object defined in the
[`sui::package`][package-framework] module, and acquire during package publishing as a return value
of the [`Publish`](./../concepts/what-is-a-transaction.md) command.

```move
module sui::package;

/// Capability controlling the ability to upgrade a package.
public struct UpgradeCap has key, store {
    id: UID,
    /// (Mutable) ID of the package that can be upgraded.
    package: ID,
    /// (Mutable) The number of upgrades that have been applied
    /// successively to the original package. Initially 0.
    version: u64,
    /// What kind of upgrades are allowed.
    policy: u8,
}
```

As you can see from the abilities set, the `UpgradeCap` is [an object](./../storage/key-ability.md)
with [public transfers and store-ability](./../storage/store-ability.md). Hence, it can be owned,
sent and used in applications, such as
[custom upgrade policies](https://docs.sui.io/concepts/sui-move-concepts/packages/custom-policies).

> Note: while the `version` field in the `UpgradeCap` starts with `0`; initial version in tooling,
> such the Sui CLI and MVR, is `1`. So the first upgrade of the package will change
> `UpgradeCap.version` to `1`, and tooling will show it as version `2`.

## Making Package Immutable

The [`UpgradeCap`][upgrade-cap-framework] can destroyed, effectively disabling package upgrades. To
do so, you can call the `make_immutable` function in the [`sui::package`][package-framework] module.
The function irreversibly destroys the capability.

```move
module sui::package;

/// Discard the `UpgradeCap` to make a package immutable.
public fun make_immutable(cap: UpgradeCap) {
    let UpgradeCap { id, .. } = cap;
    id.delete();
}
```

## Type Reflection

New types have the package address in which they were introduced. If type `New` was added during an
upgrade, its type name will include the address of the upgraded version of the package.

```move title="Version 1"
module my_package::testing_upgrades;

public struct OriginalType()
```

```move title="Version 2"
module my_package::testing_upgrades;

public struct OriginalType()

// highlight-note-start
// New type introduced in the version 2
public struct NewType()
// highlight-note-end
```

It is important to understand this property when working with
[type reflection](./../move-basics/type-reflection). If there is any logic that depends on comparing
`TypeName`'s, it needs to accommodate for the upgrade scenario. To illustrate the difference, let's
write a simple test to prove the point.

```move title="Version 2"
module my_package::testing_upgrades;

use std::type_name;

// ...

public fun compare_types() {
    let v1 = type_name::get<OriginalType>();
    let v2 = type_name::get<NewType>();

    // highlight-error-start
    // aborts! address of the v1 does not match address of the v2!
    assert!(v1.get_address() == v2.get_address());
    // highlight-error-end
}
```

To check whether two types belong to the same package, regardless of the version they were
introduced, [`std::type_name`](type-name-std) provides `get_with_original_ids` function. The value
returned in this function will always be the first address of the package. To make the "test" pass,
a fix would be:

```move title="Version 3"
module my_package::testing_upgrades;

public fun compare_types() {
    // highlight-note-start
    let v1 = type_name::get_with_original_ids<OriginalType>();
    let v2 = type_name::get_with_original_ids<NewType>();
    // highlight-note-end

    // no longer aborts! both feature the same package address!
    assert!(v1.get_address() == v2.get_address());
}
```

[type-name-std]: https://docs.sui.io/references/framework/std/type_name
[package-framework]: https://docs.sui.io/references/framework/sui/package
[upgrade-cap-framework]: https://docs.sui.io/references/framework/sui/package#sui_package_UpgradeCap
