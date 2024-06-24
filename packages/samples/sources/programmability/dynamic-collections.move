// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use, unused_field, unused_variable)]
module book::dynamic_collections {
    use std::string::String;

// ANCHOR: bag_struct
/// Imported from the `sui::bag` module.
use sui::bag::{Self, Bag};

/// An example of a `Bag` as a struct field.
public struct Carrier has key {
    id: UID,
    bag: Bag
}
// ANCHOR_END: bag_struct

#[test] fun test_bag() {
let ctx = &mut tx_context::dummy();

// ANCHOR: bag_usage
let mut bag = bag::new(ctx);

// bag has the `length` function to get the number of elements
assert!(bag.length() == 0, 0);

bag.add(b"my_key", b"my_value".to_string());

// length has changed to 1
assert!(bag.length() == 1, 1);

// in order: `borrow`, `borrow_mut` and `remove`
// the value type must be specified
let field_ref: &String = &bag[b"my_key"];
let field_mut: &mut String = &mut bag[b"my_key"];
let field: String = bag.remove(b"my_key");

// length is back to 0 - we can unpack
bag.destroy_empty();
// ANCHOR_END: bag_usage
}

// ANCHOR: table_struct
/// Imported from the `sui::table` module.
use sui::table::{Self, Table};

/// Some record type with `store`
public struct Record has store { /* ... */ }

/// An example of a `Table` as a struct field.
public struct UserRegistry has key {
    id: UID,
    table: Table<address, Record>
}
// ANCHOR_END: table_struct

// ANCHOR: table_usage
#[test] fun test_table() {
let ctx = &mut tx_context::dummy();

// Table requires explicit type parameters for the key and value
// ...but does it only once in initialization.
let mut table = table::new<address, String>(ctx);

// table has the `length` function to get the number of elements
assert!(table.length() == 0, 0);

table.add(@0xa11ce, b"my_value".to_string());
table.add(@0xb0b, b"another_value".to_string());

// length has changed to 2
assert!(table.length() == 2, 2);

// in order: `borrow`, `borrow_mut` and `remove`
let addr_ref = &table[@0xa11ce];
let addr_mut = &mut table[@0xa11ce];

// removing both values
let _addr = table.remove(@0xa11ce);
let _addr = table.remove(@0xb0b);

// length is back to 0 - we can unpack
table.destroy_empty();
// ANCHOR_END: table_usage
}
}
