// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: user
module book::user;

use std::string::String;

/// A user account with multiple properties.
public struct User has drop {
    name: String,
    age: u8,
    email: String,
    balance: u64,
    is_active: bool,
}

/// Creates a new user - requires all fields.
public fun new(
    name: String,
    age: u8,
    email: String,
    balance: u64,
    is_active: bool,
): User {
    User { name, age, email, balance, is_active }
}

public fun balance(self: &User): u64 { self.balance }
public fun is_active(self: &User): bool { self.is_active }
public fun age(self: &User): u8 { self.age }
// ANCHOR_END: user
