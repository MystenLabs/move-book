// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module book::hot_potato_pattern {

// ANCHOR: definition
public struct Request {}
// ANCHOR_END: definition

// ANCHOR: new_request
/// Constructs a new `Request`
public fun new_request(): Request { Request {} }

/// Unpacks the `Request`. Due to the nature of the hot potato, this function
/// must be called to avoid aborting the transaction.
public fun confirm_request(request: Request) {
    let Request {} = request;
}
// ANCHOR_END: new_request

}

module book::container_borrow {

// ANCHOR: container_borrow
/// Trying to return value to incorrect container.
const ENotCorrectContainer: u64 = 0;
/// Trying to return incorrect value.
const ENotCorrectValue: u64 = 1;

/// A generic container for any Object with `key + store`. The Option type
/// is used to allow taking and putting the value back.
public struct Container<T: key + store> has key {
    id: UID,
    value: Option<T>,
}

/// A Hot Potato struct that is used to ensure the borrowed value is returned.
public struct Promise {
    /// The ID of the borrowed object. Ensures that there wasn't a value swap.
    id: ID,
    /// The ID of the container. Ensures that the borrowed value is returned to
    /// the correct container.
    container_id: ID,
}

/// A function that allows borrowing the value from the container.
public fun borrow_val<T: key + store>(container: &mut Container<T>): (T, Promise) {
    let value = container.value.extract();
    let id = object::id(&value);
    (value, Promise { id, container_id: object::id(container) })
}

/// Put the taken item back into the container.
public fun return_val<T: key + store>(
    container: &mut Container<T>, value: T, promise: Promise
) {
    let Promise { id, container_id } = promise;
    assert!(object::id(container) == container_id, ENotCorrectContainer);
    assert!(object::id(&value) == id, ENotCorrectValue);
    container.value.fill(value);
}
// ANCHOR_END: container_borrow
}

module book::phone_shop {

use sui::coin::Coin;

public struct USD has drop {}
public struct BONUS has drop {}

// ANCHOR: phone_shop
/// Trying to purchase `Phone` with incorrect price of `BonusPoints` or `USD`.
const ENotCorrectPrice: u64 = 0;

/// A `Phone`. Can be purchased in a store.
public struct Phone has key, store { id: UID }

/// A ticket that must be paid to purchase the `Phone`.
public struct Ticket { amount: u64 }

/// Return the `Phone` and the `Ticket` that must be paid to purchase it.
public fun purchase_phone(ctx: &mut TxContext): (Phone, Ticket) {
    (
        Phone { id: object::new(ctx) },
        Ticket { amount: 100 }
    )
}

/// The customer may pay for the `Phone` with `BonusPoints`.
public fun pay_in_bonus_points(ticket: Ticket, payment: Coin<BONUS>) {
    let Ticket { amount } = ticket;
    assert!(payment.value() == amount, ENotCorrectPrice);
    abort // omitting the rest of the function
}

/// The customer may pay for the `Phone` with `USD`.
public fun pay_in_usd(ticket: Ticket, payment: Coin<USD>) {
    let Ticket { amount } = ticket;
    assert!(payment.value() == amount, ENotCorrectPrice);
    abort // omitting the rest of the function
}
// ANCHOR_END: phone_shop
}
