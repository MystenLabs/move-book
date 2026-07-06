// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: use_permit
/// A module that registers its own type in the `type_registry`.
module book::registry_user;

use book::type_registry::Registry;

/// The type we are going to register.
public struct MyApp()

/// Registers `MyApp` in the given registry. The permit can only be
/// created here - in the module that defines `MyApp`.
public fun register_my_app(registry: &mut Registry) {
    let permit = internal::permit<MyApp>();
    registry.register(permit, "My App");
}
// ANCHOR_END: use_permit

#[test_only]
use std::unit_test::assert_eq;
#[test_only]
use book::type_registry;

#[test]
fun test_register_my_app() {
    // ANCHOR: test
    let mut registry = type_registry::new();
    register_my_app(&mut registry);
    assert_eq!(registry.size(), 1);
    // ANCHOR_END: test
}
