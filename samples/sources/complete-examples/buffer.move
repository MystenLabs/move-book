// Copyright (c) Damir Shamanaev 2023
// Licensed under the MIT License - https://opensource.org/licenses/MIT

module book::buffer {
    use std::vector;
    use std::option::{Self, Option};

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
        if (option::is_some(&self.expected_len)) {
            let max_len = *option::borrow(&self.expected_len);
            let future_len = self.len() + vector::length(&data);
            assert!(future_len <= max_len, EBufferOverflow);
        };

        vector::append(&mut self.data, data)
    }

    /// Unwraps the buffer and returns the underlying vector.
    public fun unwrap(self: Buffer): vector<u8> {
        let Buffer { data, expected_len: _ } = self;
        data
    }

    /// Returns the length of the buffer.
    public fun len(self: &Buffer): u64 {
        vector::length(&self.data)
    }

    /// Returns `true` if the buffer is empty.
    public fun is_empty(self: &Buffer): bool {
        vector::is_empty(&self.data)
    }
}
