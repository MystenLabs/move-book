// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::newtype_pattern;

/// Very simple stack implementation using the newtype pattern. Does not allow
/// accessing the elements unless they are popped.
public struct Stack<T>(vector<T>) has copy, store, drop;

/// Push an element to the stack.
public fun push_back<T>(v: &mut Stack<T>, el: T) {
    v.0.push_back(el);
}

/// Pop an element from the stack. Unlike `vector`, this function won't
/// fail if the stack is empty and will return `None` instead.
public fun pop_back<T>(v: &mut Stack<T>): Option<T> {
    if (v.0.length() == 0) option::none()
    else option::some(v.0.pop_back())
}

/// Get the size of the stack.
public fun size<T>(v: &Stack<T>): u64 {
    v.0.length()
}
// ANCHOR_END: main

// ANCHOR: common
/// Allows reading the contents of the `Stack`.
public fun inner<T>(v: &Stack<T>): &vector<T> { &v.0 }

/// Allows mutable access to the contents of the `Stack`.
public fun inner_mut<T>(v: &mut Stack<T>): &mut vector<T> { &mut v.0 }
// ANCHOR_END: common
