// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_variable, unused_mut_parameter)]
// ANCHOR: definition
module book::one_time {
    /// The OTW for the `book::one_time` module.
    /// Only `drop`, no fields, no generics, all uppercase.
    public struct ONE_TIME has drop {}

    /// Receive the instance of `ONE_TIME` as the first argument.
    fun init(otw: ONE_TIME, ctx: &mut TxContext) {
        // do something with the OTW
    }
}
// ANCHOR_END: definition

module book::one_time_usage {
// ANCHOR: usage
use sui::types;

const ENotOneTimeWitness: u64 = 1;

/// Takes an OTW as an argument, aborts if the type is not OTW.
public fun takes_witness<T: drop>(otw: T) {
    assert!(types::is_one_time_witness(&otw), ENotOneTimeWitness);
}
// ANCHOR_END: usage
}
