> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Pattern: Witness

Witness is a pattern of proving a fact by constructing evidence of it. In the context of
programming, a witness is a way to prove a certain property of a system by providing a value that
can only be constructed if the property holds.

## Witness in Move

In the [Struct](./../move-basics/struct) section we have shown that a struct can only be created -
or _packed_ - by the module defining it. Hence, in Move, a module proves ownership of the type by
constructing it. This is one of the most important patterns in Move, and it is widely used for
generic type instantiation and authorization.

Practically speaking, for the witness to be used, there has to be a function that expects a witness
as an argument. In the example below it is the `new` function that expects a witness of the `T`
type to create an `Instance<T>`.

> The witness is usually discarded rather than stored, which is why such functions often require
> the witness type to have the [drop](./../move-basics/drop-ability) ability.

```move
module book::witness;

/// A struct that can only be created with a witness of `T`.
public struct Instance<phantom T> has drop {}

/// Create a new `Instance<T>` with the provided witness. The witness is
/// discarded after use.
public fun new<T: drop>(_witness: T): Instance<T> {
    Instance {}
}
```

The only way to construct an `Instance<T>` is to call the `new` function with an instance of the
type `T`. This is a basic example of the witness pattern in Move. A module providing a witness often
has a matching implementation, like the module `book::witness_source` below:

```move
module book::witness_source;

use book::witness::{Self, Instance};

/// A struct used as a witness - canonically, an empty struct with `drop`.
public struct W has drop {}

/// Create a new instance of `Instance<W>`.
public fun new_instance(): Instance<W> {
    witness::new(W {})
}
```

The instance of the struct `W` is passed into the `new_instance` function to create an
`Instance<W>`, thereby proving that the module `book::witness_source` owns the type `W`.

## Instantiating a Generic Type

Witness allows generic types to be instantiated with a concrete type. This is useful for inheriting
associated behaviors from the type with an option to extend them, if the module provides the ability
to do so.

```move
module sui::balance;

/// A Supply of T. Used for minting and burning.
/// Wrapped into a `TreasuryCap` in the `Coin` module.
public struct Supply<phantom T> has store {
    value: u64,
}

/// Create a new supply for type T.
public fun create_supply<T: drop>(_: T): Supply<T> {
    Supply { value: 0 }
}

/// Get the `Supply` value.
public fun supply_value<T>(supply: &Supply<T>): u64 {
    supply.value
}
```

In the example above, which is borrowed from the [`balance` module][balance-framework] of the
[Sui Framework](./sui-framework), the `Supply` is a generic struct that can be constructed only by
supplying a witness of the type `T`. The witness is taken by value and _discarded_ - hence the `T`
must have the [drop](./../move-basics/drop-ability) ability.

[balance-framework]: https://docs.sui.io/references/framework/sui/balance

The instantiated `Supply<T>` can then be used to mint new `Balance<T>`'s, where `T` is the type of
the supply.

```move
module sui::balance;

const EOverflow: u64 = 1;

/// Storable balance - an inner struct of a Coin type.
/// Can be used to store coins which don't need the key ability.
public struct Balance<phantom T> has store {
    value: u64,
}

/// Increase supply by `value` and create a new `Balance<T>` with this value.
public fun increase_supply<T>(self: &mut Supply<T>, value: u64): Balance<T> {
    assert!(value <= (std::u64::max_value!() - self.value), EOverflow);
    self.value = self.value + value;
    Balance { value }
}
```

This is how new currencies are typically created on Sui: the `TreasuryCap` - the
[capability](./capability) described earlier in this chapter - is a wrapper around the `Supply<T>`,
instantiated with a witness.

## Authorization with Witness

Instantiating a type is not the only use for a witness: any function can require one, making the
call available only to the module that defines `T`. The module below implements a generic
`RegulatedCoin`, in which the privileged operations - `mint`, `burn`, and `transfer` - require a
witness, while the shared functionality - `join` - is available to everyone:

```move
/// A custom RegulatedCoin type with implementable functions.
public struct RegulatedCoin<phantom T> has key {
    id: UID,
    value: u64
}

/// Protected function - requires a Witness.
/// Mints a new `RegulatedCoin` with the value.
public fun mint<T: drop>(_: T, value: u64, ctx: &mut TxContext): RegulatedCoin<T> {
    RegulatedCoin { id: object::new(ctx), value }
}

/// Protected function - requires a Witness.
/// Burns the `RegulatedCoin` and returns the value.
public fun burn<T: drop>(_: T, coin: RegulatedCoin<T>): u64 {
    let RegulatedCoin { id, value } = coin;
    id.delete();
    value
}

/// Protected function - requires a Witness.
public fun transfer<T: drop>(_: T, coin: RegulatedCoin<T>, to: address) {
    transfer::transfer(coin, to)
}

/// Public API - does not require a Witness.
public fun join<T>(coin: &mut RegulatedCoin<T>, other: RegulatedCoin<T>) {
    let RegulatedCoin { id, value } = other;
    coin.value = coin.value + value;
    id.delete();
}
```

A module that defines a witness type and calls `mint` gets its own regulated currency: it alone
decides how - and whether - to expose minting, burning, and transfers of its coins, while the base
module implements the logic shared by all such currencies.

This use of a witness is close to the [Capability](./capability) pattern, with an important
difference: a capability is an object, so it authorizes whoever owns it - an account; a witness can
only be constructed by the module defining it, so it authorizes code. Authorization with a witness
is decided at the time the code is written, requires no storage, and cannot be transferred.

## One Time Witness

While a struct can be created any number of times, there are cases where a struct should be
guaranteed to be created only once. For this purpose, Sui provides the "One-Time Witness" - a
special witness that can only be used once. We explain it in more detail in the
[next section](./one-time-witness).

> The standard library also provides a ready-made form of this proof: the
> [Internal Permit](./../move-basics/internal-permit). An `internal::Permit<T>` proves that the
> call was authorized by the module defining `T` - without the library having to design a custom
> witness type or require `drop` on `T` itself.

## Summary

- Witness is a pattern of proving a certain property by constructing a proof.
- In Move, a module proves ownership of a type by constructing it.
- Witness is often used for generic type instantiation and authorization.

## Next Steps

In the next section, we will learn about the [One Time Witness](./one-time-witness) pattern.
