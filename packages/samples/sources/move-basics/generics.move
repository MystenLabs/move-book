// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
#[allow(unused_variable, unused_field)]
module book::generics;

// ANCHOR: container
/// Container for any type `T`.
public struct Container<T> has drop {
    value: T,
}

/// Function that creates a new `Container` with a generic value `T`.
public fun new<T>(value: T): Container<T> {
    Container { value }
}
// ANCHOR_END: container

// ANCHOR: test_container
#[test]
fun test_container() {
    // these three lines are equivalent
    let container: Container<u8> = new(10); // type inference
    let container = new<u8>(10); // create a new `Container` with a `u8` value
    let container = new(10u8);

    assert!(container.value == 10, 0x0);

    // Value can be ignored only if it has the `drop` ability.
    let Container { value: _ } = container;
}
// ANCHOR_END: test_container

// ANCHOR: pair
/// A pair of values of any type `T` and `U`.
public struct Pair<T, U> {
    first: T,
    second: U,
}

/// Function that creates a new `Pair` with two generic values `T` and `U`.
public fun new_pair<T, U>(first: T, second: U): Pair<T, U> {
    Pair { first, second }
}
// ANCHOR_END: pair

// ANCHOR: test_pair
#[test]
fun test_generic() {
    // these three lines are equivalent
    let pair_1: Pair<u8, bool> = new_pair(10, true); // type inference
    let pair_2 = new_pair<u8, bool>(10, true); // create a new `Pair` with a `u8` and `bool` values
    let pair_3 = new_pair(10u8, true);

    assert!(pair_1.first == 10, 0x0);
    assert!(pair_1.second, 0x0);

    // Unpacking is identical.
    let Pair { first: _, second: _ } = pair_1;
    let Pair { first: _, second: _ } = pair_2;
    let Pair { first: _, second: _ } = pair_3;

}
// ANCHOR_END: test_pair

// ANCHOR: test_pair_swap
#[test]
fun test_swap_type_params() {
    let pair1: Pair<u8, bool> = new_pair(10u8, true);
    let pair2: Pair<bool, u8> = new_pair(true, 10u8);

    // this line will not compile
    // assert!(pair1 == pair2, 0x0);

    let Pair { first: pf1, second: ps1 } = pair1; // first1: u8, second1: bool
    let Pair { first: pf2, second: ps2 } = pair2; // first2: bool, second2: u8

    assert!(pf1 == ps2); // 10 == 10
    assert!(ps1 == pf2); // true == true
}
// ANCHOR_END: test_pair_swap

use std::string::String;

// ANCHOR: user
/// A user record with name, age, and some generic metadata
public struct User<T> {
    name: String,
    age: u8,
    /// Varies depending on application.
    metadata: T,
}
// ANCHOR_END: user

// ANCHOR: update_user
/// Updates the name of the user.
public fun update_name<T>(user: &mut User<T>, name: String) {
    user.name = name;
}

/// Updates the age of the user.
public fun update_age<T>(user: &mut User<T>, age: u8) {
    user.age = age;
}
// ANCHOR_END: update_user

// ANCHOR: phantom
/// A generic type with a phantom type parameter.
public struct Coin<phantom T> {
    value: u64
}
// ANCHOR_END: phantom

// ANCHOR: test_phantom
public struct USD {}
public struct EUR {}

#[test]
fun test_phantom_type() {
    let coin1: Coin<USD> = Coin { value: 10 };
    let coin2: Coin<EUR> = Coin { value: 20 };

    // Unpacking is identical because the phantom type parameter is not used.
    let Coin { value: _ } = coin1;
    let Coin { value: _ } = coin2;
}
// ANCHOR_END: test_phantom

// ANCHOR: constraints
/// A generic type with a type parameter that has the `drop` ability.
public struct Droppable<T: drop> {
    value: T,
}

/// A generic struct with a type parameter that has the `copy` and `drop` abilities.
public struct CopyableDroppable<T: copy + drop> {
    value: T, // T must have the `copy` and `drop` abilities
}
// ANCHOR_END: constraints

// ANCHOR: test_constraints
/// Type without any abilities.
public struct NoAbilities {}

#[test]
fun test_constraints() {
    // Fails - `NoAbilities` does not have the `drop` ability
    // let droppable = Droppable<NoAbilities> { value: 10 };

    // Fails - `NoAbilities` does not have the `copy` and `drop` abilities
    // let copyable_droppable = CopyableDroppable<NoAbilities> { value: 10 };
}
// ANCHOR_END: test_constraints
