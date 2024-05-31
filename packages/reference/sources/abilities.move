// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_field)]
module ref::abilities {

// ANCHOR: annotating_datatypes
public struct Ignorable has drop { f: u64 }
public struct Pair has copy, drop, store { x: u64, y: u64 }
public struct MyVec(vector<u64>) has copy, drop, store;

public enum IgnorableEnum has drop { Variant }
public enum PairEnum has copy, drop, store { Variant }
public enum MyVecEnum { Variant } has copy, drop, store;
// ANCHOR_END: annotating_datatypes

// ANCHOR: conditional_abilities
// public struct Cup<T> has copy, drop, store, key { item: T }
// ANCHOR_END: conditional_abilities

}
