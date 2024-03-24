// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field)]
// ANCHOR: module
module book::accessories {
    use std::string::String;

    public struct Character has key {
        id: UID,
        name: String
    }

    /// An accessory that can be attached to a character.
    public struct Accessory has store {
        type_: String,
        name: String,
    }
}
// ANCHOR_END: module
