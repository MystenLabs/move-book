// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::scratchpad;

use std::string::String;
use sui::scratch::{Self, Permit};

// ANCHOR: key
/// Identifies this module's entries in the scratchpad. Only `book::scratchpad`
/// can authorize access to entries keyed by `NoteKey`.
public struct NoteKey() has copy, drop;
// ANCHOR_END: key

// ANCHOR: usage
/// Leave a note for other calls in the same transaction.
public fun set_note(note: String, ctx: &mut TxContext) {
    ctx.scratch_internal_add!(NoteKey(), note);
}

/// Read the note, if one was left earlier in the transaction.
public fun read_note(ctx: &TxContext): Option<String> {
    ctx.scratch_internal_read_opt!(NoteKey())
}
// ANCHOR_END: usage

// ANCHOR: get
/// Append a suffix to the note in place, if one was left.
public fun append_to_note(suffix: String, ctx: &mut TxContext) {
    ctx.scratch_internal_get_mut_do!(NoteKey(), |note: &mut String| note.append(suffix));
}

/// Length of the note, or 0 if none was left.
public fun note_length(ctx: &mut TxContext): u64 {
    ctx.scratch_internal_get_fold!(NoteKey(), 0, |note: &String| note.length())
}
// ANCHOR_END: get

// ANCHOR: counter
/// Trying to perform the action more than `MAX_ACTIONS_PER_TX` times.
const ETooManyActions: u64 = 0;

/// The action may run at most 3 times per transaction.
const MAX_ACTIONS_PER_TX: u64 = 3;

/// Key for the per-transaction action counter.
public struct ActionCount() has copy, drop;

/// An action that can run at most `MAX_ACTIONS_PER_TX` times in a
/// single transaction, no matter who calls it or how.
public fun limited_action(ctx: &mut TxContext) {
    let count = ctx.scratch_internal_remove_opt!(ActionCount()).destroy_or!(0);
    assert!(count < MAX_ACTIONS_PER_TX, ETooManyActions);
    ctx.scratch_internal_add!(ActionCount(), count + 1);
    // ... perform the action
}
// ANCHOR_END: counter

// ANCHOR: permit
/// Issue a `Permit` for `NoteKey`, sharing access to the note with the
/// caller. Only this module can create it.
public fun grant_access(): Permit<NoteKey> {
    scratch::permit(internal::permit<NoteKey>())
}
// ANCHOR_END: permit

// ANCHOR: explicit
/// Replace the note, returning the previous one. Anyone holding a
/// `Permit<NoteKey>` can call this via the explicit, permit-based API.
public fun replace_note(
    permit: Permit<NoteKey>,
    note: String,
    ctx: &mut TxContext,
): Option<String> {
    ctx.scratch_replace(permit, NoteKey(), note)
}
// ANCHOR_END: explicit

// ANCHOR: package_access
/// Replace the note from another module in this package without exposing a
/// `Permit<NoteKey>` to the caller.
public(package) fun replace_note_in_package(
    note: String,
    ctx: &mut TxContext,
): Option<String> {
    ctx.scratch_internal_replace!(NoteKey(), note)
}
// ANCHOR_END: package_access

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_note() {
    let ctx = &mut tx_context::dummy();

    // no note at the start of the transaction
    assert!(read_note(ctx).is_none());

    set_note("hello", ctx);
    assert_eq!(read_note(ctx), option::some(b"hello".to_string()));

    // modify and inspect the note in place
    append_to_note(", move", ctx);
    assert_eq!(read_note(ctx), option::some(b"hello, move".to_string()));
    assert_eq!(note_length(ctx), 11);

    // replace the note through the permit-based API
    let permit = grant_access();
    let old: Option<String> = replace_note(permit, "world", ctx);
    assert_eq!(old, option::some(b"hello, move".to_string()));
    assert_eq!(read_note(ctx), option::some(b"world".to_string()));
}

#[test, expected_failure(abort_code = ETooManyActions)]
fun test_limited_action() {
    let ctx = &mut tx_context::dummy();

    limited_action(ctx);
    limited_action(ctx);
    limited_action(ctx);
    limited_action(ctx); // aborts
}
