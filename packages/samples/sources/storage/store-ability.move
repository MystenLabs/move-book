// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field)]
module book::store_ability {
    use std::string::String;

// ANCHOR: store
/// This type has the `store` ability.
public struct Storable has store {
    // `string::String` is also `store`-able.
    data: String
}

/// Config contains a `Storable` field which must have the `store` ability.
public struct Config has key, store {
    id: UID,
    stores: Storable,
}

/// MegaConfig contains a `Config` field which has the `store` ability.
public struct MegaConfig has key {
    id: UID,
    config: Config, // there it is!
}
// ANCHOR_END: store
}
