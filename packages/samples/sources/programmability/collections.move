// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_field)]
// ANCHOR: vector
module book::collections_vector;

use std::string::String;

/// The Book that can be sold by a `BookStore`
public struct Book has key, store {
    id: UID,
    name: String
}

/// The BookStore that sells `Book`s
public struct BookStore has key, store {
    id: UID,
    books: vector<Book>
}
// ANCHOR_END: vector
