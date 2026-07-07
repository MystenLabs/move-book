// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: lazy
module book::versioned_config;

use sui::dynamic_field as df;

/// The current version of the package.
const VERSION: u8 = 2;

/// The base object stays thin - its layout can never change in an
/// upgrade. The actual configuration is attached as a dynamic field.
public struct Config has key {
    id: UID,
    version: u8,
}

/// Configuration attached as a dynamic field in version 1.
public struct ConfigV1 has store { fee: u64 }

/// Version 2 of the configuration adds a new field.
public struct ConfigV2 has store { fee: u64, discount: u64 }

/// Read the fee, migrating the configuration on first access.
public fun fee(config: &mut Config): u64 {
    config.migrate_if_needed();
    df::borrow<u8, ConfigV2>(&config.id, 0).fee
}

/// Replace `ConfigV1` with `ConfigV2` the first time the object is
/// used after the upgrade.
fun migrate_if_needed(config: &mut Config) {
    if (config.version == 1) {
        let ConfigV1 { fee } = df::remove(&mut config.id, 0u8);
        df::add(&mut config.id, 0u8, ConfigV2 { fee, discount: 0 });
        config.version = VERSION;
    }
}
// ANCHOR_END: lazy

#[test]
fun test_lazy_migration() {
    use std::unit_test::assert_eq;

    let ctx = &mut tx_context::dummy();

    // The object was created by the previous version (1) of the package
    // and carries the old configuration.
    let mut config = Config { id: object::new(ctx), version: 1 };
    df::add(&mut config.id, 0u8, ConfigV1 { fee: 1000 });

    // The first access migrates the configuration to `ConfigV2`.
    assert_eq!(config.fee(), 1000);
    assert_eq!(config.version, VERSION);
    assert_eq!(df::borrow<u8, ConfigV2>(&config.id, 0).discount, 0);

    std::unit_test::destroy(config);
}
