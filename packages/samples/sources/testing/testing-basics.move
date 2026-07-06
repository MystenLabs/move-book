// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::testing_basics;

// ANCHOR: foreign_abort_code
/// The test aborts inside `sui::dynamic_field`, and the expected abort
/// code is imported from that module by its full path.
#[test, expected_failure(abort_code = sui::dynamic_field::EFieldDoesNotExist)]
fun test_borrow_missing_field() {
    let ctx = &mut tx_context::dummy();
    let id = object::new(ctx);

    // There is no field with this name, so `borrow` aborts.
    let _: &u64 = sui::dynamic_field::borrow(&id, b"missing");

    id.delete();
}
// ANCHOR_END: foreign_abort_code
