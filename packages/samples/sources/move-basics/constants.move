// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::constants;

const MAX: u64 = 100;

// however you can pass constant outside using a function
public fun max(): u64 {
    MAX
}

// or using
public fun is_max(num: u64): bool {
    num == MAX
}
