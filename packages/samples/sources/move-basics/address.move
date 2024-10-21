// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::address;

#[test] fun address_literal() {

// ANCHOR: address_literal
// address literal
let value: address = @0x1;

// named address registered in Move.toml
let value = @std;
let other = @sui;
// ANCHOR_END: address_literal

}

#[test] fun address_u256() {
// ANCHOR: to_u256
use sui::address;

let addr_as_u256: u256 = address::to_u256(@0x1);
let addr = address::from_u256(addr_as_u256);
// ANCHOR_END: to_u256
}

#[test] fun address_string() {

// ANCHOR: to_string
use sui::address;
use std::string::String;

let addr_as_string: String = address::to_string(@0x1);
// ANCHOR_END: to_string
}

#[test] fun address_bytes() {

// ANCHOR: to_bytes
use sui::address;

let addr_as_u8: vector<u8> = address::to_bytes(@0x1);
let addr = address::from_bytes(addr_as_u8);
// ANCHOR_END: to_bytes
}
