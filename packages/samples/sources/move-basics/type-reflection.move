// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
// ANCHOR: main
module book::type_reflection;

use std::ascii::String;
use std::type_name::{Self, TypeName};

/// A function that returns the name of the type `T` and its module and address.
public fun do_i_know_you<T>(): (String, String, String) {
    let type_name: TypeName = type_name::with_defining_ids<T>();

    // there's a way to borrow
    let str: &String = type_name.as_string();

    let module_name: String = type_name.module_string();
    let address_str: String = type_name.address_string();

    // and a way to consume the value
    let str = type_name.into_string();

    (str, module_name, address_str)
}

#[test_only]
public struct MyType {}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_type_reflection() {
    let (type_name, module_name, _address_str) = do_i_know_you<MyType>();

    assert_eq!(module_name, b"type_reflection".to_ascii_string());
}
// ANCHOR_END: main
