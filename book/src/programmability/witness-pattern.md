# Pattern: Witness

Witness is a pattern of proving an existence by constructing a proof. In the context of programming,
witness is a way to prove a certain property of a system by providing a value that can only be
constructed if the property holds.

## Witness in Move

In the [Struct](./../move-basics/struct.md) section we have shown that a struct can only be
created - or _packed_ - by the module defining it. Hence, in Move, a module proves ownership of the
type by constructing it. This is one of the most important patterns in Move, and it is widely used
for generic type instantiation and authorization.

Practically speaking, for the witness to be used, there has to be a function that expects a witness
as an argument. In the example below it is the `new` function that expects a witness of the `T` type
to create a `Instance<T>` instance.

> It is often the case that the witness struct is not stored, and for that the function may require
> the [Drop](./../move-basics/drop-ability.md) ability for the type.

```move
module book::witness;

/// A struct that requires a witness to be created.
public struct Instance<T> { t: T }

/// Create a new instance of `Instance<T>` with the provided T.
public fun new<T>(witness: T): Instance<T> {
    Instance { t: witness }
}
```

The only way to construct an `Instance<T>` is to call the `new` function with an instance of the
type `T`. This is a basic example of the witness pattern in Move. A module providing a witness often
has a matching implementation, like the module `book::witness_source` below:

```move
module book::witness_source;

use book::witness::{Self, Instance};

/// A struct used as a witness.
public struct W {}

/// Create a new instance of `Instance<W>`.
public fun new_instance(): Instance<W> {
    witness::new(W {})
}
```

The instance of the struct `W` is passed into the `new_instance` function to create an `Instance<W>`, thereby
proving that the module `book::witness_source` owns the type `W`.

## Instantiating a Generic Type

Witness allows generic types to be instantiated with a concrete type. This is useful for inheriting
associated behaviors from the type with an option to extend them, if the module provides the ability
to do so.

```move
// File: sui-framework/sources/balance.move
/// A Supply of T. Used for minting and burning.
public struct Supply<phantom T> has store {
    value: u64,
}

/// Create a new supply for type T with the provided witness.
public fun create_supply<T: drop>(_w: T): Supply<T> {
    Supply { value: 0 }
}

/// Get the `Supply` value.
public fun supply_value<T>(supply: &Supply<T>): u64 {
    supply.value
}
```

In the example above, which is borrowed from the `balance` module of the
[Sui Framework](./sui-framework.md), the `Supply` a generic struct that can be constructed only by
supplying a witness of the type `T`. The witness is taken by value and _discarded_ - hence the `T`
must have the [drop](./../move-basics/drop-ability.md) ability.

The instantiated `Supply<T>` can then be used to mint new `Balance<T>`'s, where `T` is the type of
the supply.

```move
// File: sui-framework/sources/balance.move
/// Storable balance.
public struct Balance<phantom T> has store {
    value: u64,
}

/// Increase supply by `value` and create a new `Balance<T>` with this value.
public fun increase_supply<T>(self: &mut Supply<T>, value: u64): Balance<T> {
    assert!(value < (18446744073709551615u64 - self.value), EOverflow);
    self.value = self.value + value;
    Balance { value }
}
```

## One Time Witness

While a struct can be created any number of times, there are cases where a struct should be
guaranteed to be created only once. For this purpose, Sui provides the "One-Time Witness" - a
special witness that can only be used once. We explain it in more detail in the
[next section](./one-time-witness.md).

## Summary

- Witness is a pattern of proving a certain property by constructing a proof.
- In Move, a module proves ownership of a type by constructing it.
- Witness is often used for generic type instantiation and authorization.

## Next Steps

In the next section, we will learn about the [One Time Witness](./one-time-witness.md) pattern.
