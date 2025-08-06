// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::buffer;

/// Error returned when the buffer is overflowed.
const EBufferOverflow: u64 = 0;

/// The Buffer struct represents a growable buffer.
public struct Buffer {
    data: vector<u8>,
    expected_len: Option<u64>
}

/// Creates a new empty buffer.
public fun new(): Buffer {
    Buffer { data: vector[], expected_len: option::none() }
}

/// Creates a new empty buffer with the specified capacity (in bytes).
/// If the buffer is overflowed, tx aborts with `EBufferOverflow`.
public fun alloc(len: u64): Buffer {
    Buffer { data: vector[], expected_len: option::some(len) }
}

/// Pushes the given data to the end of the buffer.
public fun push(self: &mut Buffer, data: vector<u8>) {
    self.expected_len.do_ref!(|max_len| assert!(self.len() + data.length() <= *max_len, EBufferOverflow));
    self.data.append(data)
}

/// Unwraps the buffer and returns the underlying vector.
public fun unwrap(self: Buffer): vector<u8> {
    let Buffer { data, expected_len: _ } = self;
    data
}

/// Returns the length of the buffer.
public fun len(self: &Buffer): u64 {
    self.data.length()
}

/// Returns `true` if the buffer is empty.
public fun is_empty(self: &Buffer): bool {
    self.data.is_empty()
}
