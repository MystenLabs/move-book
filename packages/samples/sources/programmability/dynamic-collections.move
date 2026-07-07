// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use, unused_field, unused_variable)]
module book::dynamic_collections;

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

#[test_only]
use std::unit_test::assert_eq;

#[test] fun test_bag() {
let ctx = &mut tx_context::dummy();

// ANCHOR: bag_usage
let mut bag = bag::new(ctx);

// bag has the `length` function to get the number of elements
assert_eq!(bag.length(), 0);

// the type of the value is defined at insertion; here it is a `String`
let value: String = "my_value";
bag.add(b"my_key", value);

// length has changed to 1
assert_eq!(bag.length(), 1);

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

#[test] fun test_table() {
let ctx = &mut tx_context::dummy();

// ANCHOR: table_usage
// Table requires explicit type parameters for the key and value
// ...but does it only once in initialization.
let mut table = table::new<address, String>(ctx);

// table has the `length` function to get the number of elements
assert_eq!(table.length(), 0);

table.add(@0xa11ce, "my_value");
table.add(@0xb0b, "another_value");

// length has changed to 2
assert_eq!(table.length(), 2);

// in order: `borrow`, `borrow_mut` and `remove`
let value_ref = &table[@0xa11ce];
let value_mut = &mut table[@0xa11ce];

// removing both values
let _value = table.remove(@0xa11ce);
let _another_value = table.remove(@0xb0b);

// length is back to 0 - we can unpack
table.destroy_empty();
// ANCHOR_END: table_usage
}

// ANCHOR: object_table_struct
/// Imported from the `sui::object_table` module.
use sui::object_table::{Self, ObjectTable};

/// A profile is an object - it has the `key` and `store` abilities.
public struct Profile has key, store {
    id: UID,
    name: String,
}

/// An example of an `ObjectTable` as a struct field.
public struct ProfileRegistry has key {
    id: UID,
    profiles: ObjectTable<address, Profile>
}
// ANCHOR_END: object_table_struct

#[test] fun test_object_table() {
let ctx = &mut tx_context::dummy();

// ANCHOR: object_table_usage
let mut profiles = object_table::new<address, Profile>(ctx);

// the interface is the same as the regular `Table`
profiles.add(@0xa11ce, Profile {
    id: object::new(ctx),
    name: "Alice",
});

// the stored object keeps its `ID` and can be looked up without its type
let profile_id = profiles.value_id(@0xa11ce); // Option<ID>

// objects cannot be dropped - remove the entry before destroying the table
let profile = profiles.remove(@0xa11ce);
profiles.destroy_empty();
// ANCHOR_END: object_table_usage
std::unit_test::destroy(profile);
}

// ANCHOR: linked_table_struct
/// Imported from the `sui::linked_table` module.
use sui::linked_table::{Self, LinkedTable};

/// Some record type with `store`
public struct Permissions has store { /* ... */ }

/// An example of a `LinkedTable` as a struct field.
public struct AdminRegistry has key {
    id: UID,
    linked_table: LinkedTable<address, Permissions>
}
// ANCHOR_END: linked_table_struct

#[test] fun test_linked_table() {
let ctx = &mut tx_context::dummy();

// ANCHOR: linked_table_usage
// LinkedTable requires explicit type parameters for the key and value
// ...but does it only once in initialization.
let mut linked_table = linked_table::new<address, String>(ctx);

// linked_table has the `length` function to get the number of elements
assert_eq!(linked_table.length(), 0);

linked_table.push_front(@0xa0a, "first_value");
linked_table.push_back(@0xb1b, "second_value");
linked_table.push_back(@0xc2c, "third_value");

// length has changed to 3
assert_eq!(linked_table.length(), 3);

// in order: `borrow`, `borrow_mut` and `remove`
let first_value_ref = &linked_table[@0xa0a];
let second_value_mut = &mut linked_table[@0xb1b];

// remove by key, from the beginning or from the end
let _second_value = linked_table.remove(@0xb1b);
let (_first_addr, _first_value) = linked_table.pop_front();
let (_third_addr, _third_value) = linked_table.pop_back();

// length is back to 0 - we can unpack
linked_table.destroy_empty();
// ANCHOR_END: linked_table_usage
}
