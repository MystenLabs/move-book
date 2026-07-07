// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: versioned
module book::versioned_state;

/// The version of the package this module belongs to. Incremented on
/// every upgrade that has to invalidate previous versions.
const VERSION: u8 = 2;

/// Trying to use an object with an older or newer package version.
const EVersionMismatch: u64 = 0;

/// Shared state of the application; the `version` field gates access,
/// tying the object to a single version of the package.
public struct Counter has key {
    id: UID,
    version: u8,
    value: u64,
}

/// Every function that uses the shared object starts with a version
/// check: only the package version stored in the object may proceed.
public fun increment(counter: &mut Counter) {
    assert!(counter.version == VERSION, EVersionMismatch);
    counter.value = counter.value + 1;
}
// ANCHOR_END: versioned

// ANCHOR: migrate
/// Grants the holder the permission to migrate the shared state.
public struct AdminCap has key, store { id: UID }

/// The object is already migrated to the current version.
const ENotUpgrade: u64 = 1;

/// Bump the version of the shared object, so that only the current
/// package version can use it. Called by the admin after an upgrade.
public fun migrate(counter: &mut Counter, _: &AdminCap) {
    assert!(counter.version < VERSION, ENotUpgrade);
    counter.version = VERSION;
}
// ANCHOR_END: migrate

#[test]
fun test_migrate() {
    use std::unit_test::assert_eq;

    let ctx = &mut tx_context::dummy();
    let admin = AdminCap { id: object::new(ctx) };

    // The object was created and shared by the previous version (1).
    let mut counter = Counter { id: object::new(ctx), version: 1, value: 0 };

    // After the upgrade, the admin migrates the object; from now on
    // only the current version of the package can use it.
    counter.migrate(&admin);
    counter.increment();

    assert_eq!(counter.version, VERSION);
    assert_eq!(counter.value, 1);

    std::unit_test::destroy(counter);
    std::unit_test::destroy(admin);
}

#[test, expected_failure(abort_code = EVersionMismatch)]
fun test_version_mismatch_fail() {
    let ctx = &mut tx_context::dummy();
    let mut counter = Counter { id: object::new(ctx), version: 1, value: 0 };

    // The object was not migrated - the call aborts.
    counter.increment();

    abort
}
