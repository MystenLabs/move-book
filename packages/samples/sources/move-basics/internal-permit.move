// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: registry
/// A registry where a type can be registered under a human-readable
/// name, but only by the module that defines the type.
module book::type_registry;

use std::string::String;

/// Stores the names of registered types.
public struct Registry has drop {
    names: vector<String>,
}

/// Creates a new, empty `Registry`.
public fun new(): Registry {
    Registry { names: vector[] }
}

/// Registers the type `T` under the given `name`. The `Permit<T>`
/// argument proves that the call was authorized by the module
/// that defines `T`.
public fun register<T>(registry: &mut Registry, _permit: internal::Permit<T>, name: String) {
    registry.names.push_back(name);
}

/// Returns the number of registered types.
public fun size(registry: &Registry): u64 {
    registry.names.length()
}
// ANCHOR_END: registry
