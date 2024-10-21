// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
module book::bcs {
    use std::string::String;

public struct CustomData has drop {
    num: u8,
    string: String,
    value: bool
}

public struct User has drop {
    age: u8,
    is_active: bool,
    name: String
}

#[test] fun test_encode() {
// ANCHOR: encode
use sui::bcs;

// 0x01 - a single byte with value 1 (or 0 for false)
let bool_bytes = bcs::to_bytes(&true);
// 0x2a - just a single byte
let u8_bytes = bcs::to_bytes(&42u8);
// 0x2a00000000000000 - 8 bytes
let u64_bytes = bcs::to_bytes(&42u64);
// address is a fixed sequence of 32 bytes
// 0x0000000000000000000000000000000000000000000000000000000000000002
let addr = bcs::to_bytes(&@sui);
// ANCHOR_END: encode

// ANCHOR: encode_struct
let data = CustomData {
    num: 42,
    string: b"hello, world!".to_string(),
    value: true
};

let struct_bytes = bcs::to_bytes(&data);

let mut custom_bytes = vector[];
custom_bytes.append(bcs::to_bytes(&42u8));
custom_bytes.append(bcs::to_bytes(&b"hello, world!".to_string()));
custom_bytes.append(bcs::to_bytes(&true));

// struct is just a sequence of fields, so the bytes should be the same!
assert!(&struct_bytes == &custom_bytes);
// ANCHOR_END: encode_struct
}

#[test] fun test_bcs() {
// ANCHOR: decode
use sui::bcs;

// BCS instance should always be declared as mutable
let mut bcs = bcs::new(x"010000000000000000");

// Same bytes can be read differently, for example: Option<u64>
let value: Option<u64> = bcs.peel_option_u64();

assert!(value.is_some());
assert!(value.borrow() == &0);

let remainder = bcs.into_remainder_bytes();

assert!(remainder.length() == 0);
// ANCHOR_END: decode

// ANCHOR: chain_decode
let mut bcs = bcs::new(x"0101010F0000000000F00000000000");

// mind the order!!!
// handy way to peel multiple values
let (bool_value, u8_value, u64_value) = (
    bcs.peel_bool(),
    bcs.peel_u8(),
    bcs.peel_u64()
);
// ANCHOR_END: chain_decode

// ANCHOR: decode_vector
let mut bcs = bcs::new(x"0101010F0000000000F00000000000");

// bcs.peel_vec_length() peels the length of the vector :)
let mut len = bcs.peel_vec_length();
let mut vec = vector[];

// then iterate depending on the data type
while (len > 0) {
    vec.push_back(bcs.peel_u64()); // or any other type
    len = len - 1;
};

assert!(vec.length() == 1);
// ANCHOR_END: decode_vector

// ANCHOR: decode_option
let mut bcs = bcs::new(x"00");
let is_some = bcs.peel_bool();

assert!(is_some == false);

let mut bcs = bcs::new(x"0101");
let is_some = bcs.peel_bool();
let value = bcs.peel_u8();

assert!(is_some == true);
assert!(value == 1);
// ANCHOR_END: decode_option

// ANCHOR: decode_struct
// some bytes...
let mut bcs = bcs::new(x"0101010F0000000000F00000000000");

let (age, is_active, name) = (
    bcs.peel_u8(),
    bcs.peel_bool(),
    bcs.peel_vec_u8().to_string()
);

let user = User { age, is_active, name };
// ANCHOR_END: decode_struct
}
}
