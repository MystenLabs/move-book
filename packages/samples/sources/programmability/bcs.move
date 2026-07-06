// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field)]
module book::bcs;

use std::string::String;

// ANCHOR: user_def
/// A struct we will encode and decode in the examples below.
public struct User has drop {
    age: u8,
    is_active: bool,
    name: String,
}
// ANCHOR_END: user_def

// ANCHOR: enum_def
/// A status of a delivery order.
public enum Status has drop {
    Pending,
    Shipped { tracking: u64 },
}
// ANCHOR_END: enum_def

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_encode() {
    // ANCHOR: encode
    use sui::bcs;

    // 0x01 - a single byte with value 1 (or 0 for false)
    let bool_bytes = bcs::to_bytes(&true);
    assert_eq!(bool_bytes, x"01");

    // 0x2a - just a single byte
    let u8_bytes = bcs::to_bytes(&42u8);
    assert_eq!(u8_bytes, x"2A");

    // 0x2a00000000000000 - 8 bytes, little-endian
    let u64_bytes = bcs::to_bytes(&42u64);
    assert_eq!(u64_bytes, x"2A00000000000000");

    // address is a fixed sequence of 32 bytes
    // 0x0000000000000000000000000000000000000000000000000000000000000002
    let addr = bcs::to_bytes(&@sui);
    assert_eq!(addr, x"0000000000000000000000000000000000000000000000000000000000000002");
    // ANCHOR_END: encode

    // ANCHOR: encode_struct
    let user = User {
        age: 42,
        is_active: true,
        name: "Bob",
    };

    // A struct is encoded as its fields, one after another, in the
    // order they are declared: no names, no types, no separators.
    //
    // age       | is_active | name
    // 2A        | 01        | 03 42 6F 62 (length + "Bob")
    let user_bytes = bcs::to_bytes(&user);
    assert_eq!(user_bytes, x"2A0103426F62");

    // Concatenating individually encoded fields gives the same bytes!
    let name: String = "Bob";
    let mut field_bytes = vector[];
    field_bytes.append(bcs::to_bytes(&42u8));
    field_bytes.append(bcs::to_bytes(&true));
    field_bytes.append(bcs::to_bytes(&name));

    assert_eq!(user_bytes, field_bytes);
    // ANCHOR_END: encode_struct
}

#[test]
fun test_decode() {
    // ANCHOR: decode
    use sui::bcs;

    // The decoder wraps the bytes; it must be declared as mutable,
    // because every `peel_*` call consumes a part of the input.
    let mut bcs = bcs::new(x"012A2823000000000000");

    let bool_value = bcs.peel_bool();
    assert_eq!(bool_value, true);

    let u8_value = bcs.peel_u8();
    assert_eq!(u8_value, 42);

    // Whatever was not decoded can be taken back out of the wrapper.
    let remainder = bcs.into_remainder_bytes();
    assert_eq!(remainder.length(), 8);
    // ANCHOR_END: decode

    // ANCHOR: chain_decode
    let mut bcs = bcs::new(x"012A2823000000000000");

    // mind the order!!!
    // handy way to peel multiple values
    let (bool_value, u8_value, u64_value) = (
        bcs.peel_bool(),
        bcs.peel_u8(),
        bcs.peel_u64(),
    );

    assert_eq!(u64_value, 9000);
    // ANCHOR_END: chain_decode
}

#[test]
fun test_not_self_describing() {
    use sui::bcs;

    // ANCHOR: not_self_describing
    // The exact same 6 bytes that encoded the `User` above...
    let mut bcs = bcs::new(x"2A0103426F62");

    // ...can be read as completely different types. The bytes carry
    // no type information - the reader decides what they mean.
    let num = bcs.peel_u16(); // 0x012A = 298
    let vec = bcs.peel_vec_u8(); // [0x42, 0x6F, 0x62]

    assert_eq!(num, 298);
    assert_eq!(vec, vector[66, 111, 98]);
    // ANCHOR_END: not_self_describing
}

#[test]
fun test_decode_vector() {
    use sui::bcs;

    // ANCHOR: decode_vector
    // vector[1u64, 2u64]: length prefix `02`, then the two elements
    let mut bcs = bcs::new(x"0201000000000000000200000000000000");

    // first, peel the length of the vector...
    let mut len = bcs.peel_vec_length();
    let mut vec = vector[];

    // ...then peel each element in a loop
    while (len > 0) {
        vec.push_back(bcs.peel_u64()); // or any other type
        len = len - 1;
    };

    assert_eq!(vec, vector[1, 2]);
    // ANCHOR_END: decode_vector

    // ANCHOR: decode_vector_macro
    let mut bcs = bcs::new(x"0201000000000000000200000000000000");

    // The `peel_vec!` macro does the same in a single call.
    let vec = bcs.peel_vec!(|bcs| bcs.peel_u64());
    assert_eq!(vec, vector[1, 2]);

    // For vectors of primitive types, there are ready-made functions.
    let mut bcs = bcs::new(x"0201000000000000000200000000000000");
    let vec = bcs.peel_vec_u64();
    assert_eq!(vec, vector[1, 2]);
    // ANCHOR_END: decode_vector_macro
}

#[test]
fun test_decode_option() {
    use sui::bcs;

    // ANCHOR: decode_option
    // `option::none<u8>()` is a single `00` byte...
    let mut bcs = bcs::new(x"00");
    let none = bcs.peel_option!(|bcs| bcs.peel_u8());
    assert!(none.is_none());

    // ...and `option::some(42u8)` is `01` followed by the value.
    let mut bcs = bcs::new(x"012A");
    let some = bcs.peel_option!(|bcs| bcs.peel_u8());
    assert_eq!(some, option::some(42));

    // For primitive types, there are ready-made `peel_option_*` functions.
    let mut bcs = bcs::new(x"012A");
    let some = bcs.peel_option_u8();
    assert_eq!(some, option::some(42));
    // ANCHOR_END: decode_option
}

#[test]
fun test_round_trip() {
    use sui::bcs;

    // ANCHOR: round_trip
    let user = User {
        age: 42,
        is_active: true,
        name: "Bob",
    };

    // Encode the value...
    let mut bcs = bcs::new(bcs::to_bytes(&user));

    // ...and decode it back, peeling the fields in exactly the order
    // they are declared in the struct definition.
    let decoded = User {
        age: bcs.peel_u8(),
        is_active: bcs.peel_bool(),
        name: bcs.peel_vec_u8().to_string(),
    };

    assert_eq!(user, decoded);
    // ANCHOR_END: round_trip
}

#[test]
fun test_decode_enum() {
    use sui::bcs;

    // ANCHOR: decode_enum
    let status = Status::Shipped { tracking: 12345 };

    // An enum value is encoded as the variant index, followed by the
    // fields of that variant.
    let mut bcs = bcs::new(bcs::to_bytes(&status));

    let decoded = match (bcs.peel_enum_tag()) {
        0 => Status::Pending,
        1 => Status::Shipped { tracking: bcs.peel_u64() },
        _ => abort,
    };

    assert_eq!(status, decoded);
    // ANCHOR_END: decode_enum
}
