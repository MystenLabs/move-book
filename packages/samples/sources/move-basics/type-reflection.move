// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable)]
// ANCHOR: main
module book::type_reflection;

use std::ascii::String;
use std::type_name::{Self, TypeName};

/// A function that returns the name of the type `T` and its module and address.
public fun do_i_know_you<T>(): (String, String, String) {
    let type_name: TypeName = type_name::get<T>();

    // there's a way to borrow
    let str: &String = type_name.borrow_string();

    let module_name: String = type_name.get_module();
    let address_str: String = type_name.get_address();

    // and a way to consume the value
    let str = type_name.into_string();

    (str, module_name, address_str)
}

#[test_only]
public struct MyType {}

#[test]
fun test_type_reflection() {
    let (type_name, module_name, _address_str) = do_i_know_you<MyType>();

    //
    assert!(module_name == b"type_reflection".to_ascii_string());
}
// ANCHOR_END: main
