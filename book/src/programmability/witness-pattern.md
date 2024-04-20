# Pattern: Witness

Almost every combination of [abilities](../move-basics/abilities-introduction.md) forms a pattern in
Move. And one of the most important ones is the _Witness pattern_ - a type that with the
[`drop`](./../move-basics/drop-ability.md) ability. It is used to instantiate generic types with a
concrete type parameter by providing a _proof of ownership_ of this type.

## Definition

A Witness is a type that has the `drop` ability. It is not very useful on its own, within a single
module, but rather serves as an initialization value for generic types. For example, if there is a
generic type `Custom<T>`, where `T` is a type parameter, a witness may be used to instantiate it,
while also ensuring that no other module can create a `Custom<T>` with the same `T`.

```move
{{#include ../../../packages/samples/sources/programmability/witness-pattern.move:definition}}
```

## Use Cases

- **Generic Types**: Witness is a powerful tool to instantiate generic types with a concrete type
  parameter. It ensures that the type is created only by the module that owns the type.
- **Proof of Ownership**: Witness acts as a proof of ownership of a concrete type. It is used to
  authorize certain actions on the type.
- **Authorization**: Witness can be used to authorize certain actions on the type.
- **Interface-like Behaviors**: Witness can be used to create abstract class-like behaviors in Move.

## Background

To better understand the Witness pattern, it is important to go back to the basics of
[generic types](./../move-basics/generics.md) in Move. Generic types are defined with a type
parameter, which can be any type with any constraints on its abilities. Previously we looked into
the [`Container<T>`](./../move-basics/generics.md#generic-syntax) example, where `T` was a type
_stored_ inside the container. Hence, there wasn't a question of how to initialize it, as the value
was passed to the constructor. However, in some cases, the type can be
[_phantom_](./../move-basics/generics.md#phantom-type-parameters) - it is not stored in the struct,
but used to differentiate between different instances of the same base type. And this is where the
Witness pattern finds its place.

> In this section we use a generic `Coin<T>` as an example of a generic type, however, it should not
> be mistaken for the actual [Coin](./balance-and-coin.md) type in the
> [Sui Framework](./sui-framework.md). We will go deeper into the `Coin` type in the
> [Balance & Coin](./balance-and-coin.md) section.

```move
/// Container always stores the `T`!
public struct Container<T> { inner: T }

/// The initialization is straightforward: the value is packed into the struct.
public fun new_container<T>(inner: T): Container<T> { Container { inner } }
```

Compare the example above with the following one:

```move
/// Coin does not store the `T`, and we need some way to
/// initialize it with a concrete type!
public struct Coin<phantom T> { value: u64 }

/// Something is missing here! Anyone can create a `Coin<T>` with any `T`.
public fun new_coin<T>(value: u64): Coin<T> { Coin { value } }
```

While the `new_container` function requires the `T` value to be passed, the `new_coin` function is
missing this part. And this implementation of the `new_coin` allows anyone to create a `Coin<T>`
with any `T`. And, naturally, this is not the behaviour we want.

Now, how can we fix this? We want to ensure that only a specific module can create a `Coin<T>` with
its `T`. Otherwise, the type signature of `Coin<T>` makes little sense. And similar to the
`Container<T>`, we need a way to present some `T` to the `new_coin` function. And given that this
`T` is not stored in the struct and not stored to be used later (important security property), we
would want to use a type that has the `drop` ability - a Witness.

An updated signature of the `new_coin` would then look like this:

```move
/// Requires a `T` with the `drop` ability as a proof of ownership of `T`.
/// However, the value is not used and discarded right away.
public fun new_coin<T: drop>(_witness: T, value: u64): Coin<T> {
    Coin { value }
}
```

And unlike the `Container<T>`, where the `T` can be any value, including an
[object](./../storage/key-ability.md) (hence, it can be supplied _dynamically_), the `T` in the
`new_coin` function has to be created and consumed _statically_ - by implementing a function in the
module that owns the `T`. So, if the type `MyCoin` is defined in the `my_coin` module, only this
module can create a new `Coin` with `T` being `MyCoin`.

```move
module book::my_coin {
    use book::simple_coin::{Self, Coin};

    /// The Witness type for the Coin.
    public struct MyCoin has drop {}

    /// The implementation of the `new_coin` function. Witness is not storable,
    /// thus the only way to create a `Coin<MyCoin>` is to call this function in
    /// this module.
    public fun new_mycoin(value: u64): Coin<MyCoin> {
        simple_coin::new_coin(MyCoin {}, value)
    }
}
```

## "Abstract Class"

The module implementing a generic type may allow implementing certain functions on top of it. So
that some of the functions are publicly available on the generic type, while others can be
implemented by a specific module. This way, the generic type acts similarly to an _abstract class_
in object-oriented languages.

The following example demonstrates a custom `RegulatedCoin` type with implementable functions. The
actual implementation of the `mint`, `burn`, and `transfer` functions is left to the application
module, while the `join` function is publicly available.

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

In the example above, the `mint`, `burn`, and `transfer` functions require a Witness of the `T` type
to be called. This way, the application module can implement these functions and ensure that only
the module that owns the `T` can call them. The `join` function, on the other hand, is publicly
available and does not require a Witness.

This pattern allows sharing base type and details of the implementation between different
applications, while still allowing the applications to implement their own logic on top of the base
type.

## Storable Witnesses + Metadata

It is possible to extend the Witness type by adding the [`store`](./../storage/store-ability.md)
ability, which would allow the type to be stored in objects. We call this variation of the Witness a
_Transferable Witness_. However, while this method can be useful in some applications by providing
the caller a way to perform a _delayed_ authorization or submit a combination of different
witnesses; it is not recommended to use it in open or sensitive systems, as it may be a security
risk. The callee function may end up storing the Witness in an object and using it later, which may
lead to unexpected behaviour.

With that in mind, the _Transferable Witness_ still has some benefits, such as the ability to reuse
a "metadata" or "configuration" struct and pass it as a Witness. This way, the application can avoid
unnecessary linking of the metadata with an extra type, and the metadata can _act like a Witness_.
To illustrate this, let's consider a generic ticketing application: the `Ticket` is a generic type
which stores metadata, and the application can implement some protected functions for it, such as
`transfer`.

> In the implementation below we omit certain features (like getter functions and the ability to
> consume a Ticket) for the sake of clarity and simplicity. The full example is available in the
> [Move Book](https://github.com/MystenLabs/move-book/tree/main/packages/samples/examples)
> repository.

```move
/// A Ticket with the metadata of type `T`. Very similar to `Container<T>`.
/// Note that the `Ticket` only has `key`, hence it's not publicly transferable!
public struct Ticket<T: store + drop> has key {
    id: UID,
    used: bool,
    metadata: T
}

/// Create a new Ticket with the metadata and the context.
/// No need for a Witness here!
public fun new<T: store + drop>(metadata: T, ctx: &mut TxContext): Ticket<T> {
    Ticket {
        id: object::new(ctx),
        used: false,
        metadata
    }
}

/// Transfer the Ticket to another user. Requires a Witness of the metadata type.
/// May or may not be implemented by the application.
public fun transfer<T: store + drop>(_metadata: T, ticket: Ticket<T>, to: address) {
    transfer::transfer(ticket, to)
}
```

In the example above, the instantiation of the `Ticket` in the `new` function is straightforward, as
the metadata is passed as an argument. However, the `transfer` function, which can be implemented by
the application, requires some kind of authorization. And the only authorization method we have here
is the metadata itself. So, the application can pass an empty metadata struct as a Witness to the
`transfer` function, hence proving that it has the right to transfer the ticket of this type.

```move
module book::concert {
    use book::ticket::{Self, Ticket};

    /// The metadata for the concert ticket.
    public struct Metadata has store, drop {
        name: String,
        date: String,
        event_id: u64
    }

    /// Purchase a ticket for the concert. (omits the actual purchase logic)
    public fun purchase(/* take a Coin */ ctx: &mut TxContext) {
        let ticket = ticket::new(Metadata {
            name: b"Mysties".to_string(),
            date: b"2023-05-03".to_string(),
            event_id: 1
        });

        // Transfer the ticket to the user.
        ticket::transfer(empty(), ticket, ctx.sender())
    }

    /// Create an empty Metadata struct to act as a Witness.
    fun empty(): Metadata {
        Metadata { name: b"".to_string(), date: b"".to_string(), event_id: 0 }
    }
}
```

## Limitations

- Witnesses are a powerful tool, but they have their limitations. The most important one is that
  they do not guarantee uniqueness. The module owning the `T` can create multiple witnesses of the
  same type, and if the library / module functionality assumes that the witness is unique and
  instantiated only once, it may lead to unexpected behaviour. To address this issue, the
  [One Time Witness](./one-time-witness.md) pattern is introduced, which ensures that the witness is
  created only once.

- In many cases Witness requires a function to be implemented in the instantiating module. This can
  be seen as a limitation, as it requires additional boilerplate code to be written. However, it is
  not the case for [One Time Witness](./one-time-witness.md), and in the cases where a regular
  Witness can be used, the Witness can be created in the [module `init`](./module-initializer.md)
  function.

## Summary

- Witness is a type with the `drop` ability, used to instantiate generic types with a concrete type
  parameter.
- It acts as a proof of ownership of a type and may be used for type-based authorization.
- Witness can be also used to create abstract class-like behaviors in Move.
- Transferable Witness is a variation of the Witness that has the `store` ability, allowing it to be
  stored in objects. It may be useful in certain applications, but not encouraged.
- Metadata types can be used as _Witnesses_. This can be useful in consumer-facing applications,
  such as ticketing systems, or NFTs.
- Witnesses do not guarantee uniqueness, and the [One Time Witness](./one-time-witness.md) pattern
  is introduced to address this issue.

## Next Steps

In the next section we will explain the [One Time Witness](./one-time-witness.md) (OTW) pattern,
which guarantees that a certain witness was created only once. The OTW pattern opens the door to
more complex topics, such as [Publisher](./publisher.md) and
[Balance & Coin](./balance-and-coin.md).
