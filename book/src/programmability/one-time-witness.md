# One Time Witness

While regular [Witness](./witness-pattern.md) is a great way to statically prove the ownership of a
type, there are cases where we need to ensure that a Witness is instantiated only once. And this is
the purpose of the One Time Witness (OTW).

<!--
Notes to self:
  - background first or definition first - which one is better?
  - why would someone read this section?
  - if we removed the OTW from docs, then we should give definition first.
-->

## Definition

The OTW is a special type of Witness that can be used only once. It cannot be manually
created and it is guaranteed to be unique per module. Sui Adapter treats a type as an OTW if it follows these rules:

1. Has only `drop` ability.
2. Has no fields.
3. Is not a generic type.
4. Named after the module with all uppercase letters.

Here is an example of an OTW:

```move
{{#include ../../../packages/samples/sources/programmability/one-time-witness.move:definition}}
```

The OTW cannot be constructed manually, and any code attempting to do so will result in
a compilation error. The OTW can be received as the first argument in the
[module initializer](./module-initializer.md). And because the `init` function is called only once
per module, the OTW is guaranteed to be instantiated only once.

## Enforcing the OTW

To check if a type is an OTW, `sui::types` module of the
[Sui Framework](./sui-framework.md) offers a special function `is_one_time_witness` that can be used
to check if the type is an OTW.

```move
{{#include ../../../packages/samples/sources/programmability/one-time-witness.move:usage}}
```

<!-- ## Background

Before we get to actual definition of the OTW, let's consider a simple example. We want to build a generic implementation of a Coin type, which can be initialized with a witness. A instance of a witness `T` is used to create a new `TreasuryCap<T>` which is then used to mint a new `Coin<T>`.

```move
module book::simple_coin {

    /// Controls the supply of the Coin.
    public struct TreasuryCap<phantom T> has key, store {
        id: UID,
        total_supply: u64,
    }

    /// The Coin type where the `T` is a witness.
    public struct Coin<phantom T> has key, store {
        id: UID,
        value: u64,
    }

    /// Create a new TreasuryCap with a witness.
    /// Vulnerable: we can create multiple TreasuryCap<T> with the same witness.
    public fun new<T: drop>(_: T, ctx: &mut TxContext): TreasuryCap<T> {
        TreasuryCap { id: object::new(ctx), total_supply: 0 }
    }

    /// We use a regular witness to authorize the minting.
    public fun mint<T>(
        treasury: &mut TreasuryCap<T>,
        value: u64,
        ctx: &mut TxContext
    ) {
        treasury.total_supply = treasury.total_supply + value;
        Coin { id: object::new(ctx), value }
    }
}
```

A dishonest developer would be able to create multiple `TreasuryCap`s with the same witness, and mint more `Coin`s than expected. Here is an example of such a malicious module:

```move
module book::simple_coin_cheater {
    /// The Coin witness.
    public struct Move has drop {}

    /// Initialize the TreasuryCap with the Move witness.
    /// ...and do it twice! >_<
    fun init(ctx: &mut TxContext) {
        let treasury_cap = book::simple_coin::new(Move {}, ctx);
        let secret_treasury = book::simple_coin::new(Move {}, ctx);

        transfer::public_transfer(treasury_cap, ctx.sender())
        transfer::public_transfer(secret_treasury, ctx.sender())
    }
}

```

The example above has no protection against issuing multiple `TreasuryCap`s with the same witness, and in real-world application, this creates a problem of trust. If it was a human decision to support a Coin based on this implementation, they would have to make sure that:

- there is only one `TreasuryCap` for a given `T`.
- the module cannot be upgraded to issue more `TreasuryCap`s.
- the module code does not contain any backdoors to issue more `TreasuryCap`s.

However, it is not possible to check any of these conditions inside the Move code. And to prevent the need for trust, Sui introduces the OTW pattern.

## Solving the Coin Problem

To solve the case of multiple `TreasuryCap`s, we can use the OTW pattern. By defining the `COIN_OTW` type as an OTW, we can ensure that the `COIN_OTW` is used only once. The `COIN_OTW` is then used to create a new `TreasuryCap` and mint a new `Coin`.

```move

With

```move
module book::coin_otw {

    /// The OTW for the `book::coin_otw` module.
    struct COIN_OTW has drop {}

    /// Receive the instance of `COIN_OTW` as the first argument.
    fun init(otw: COIN_OTW, ctx: &mut TxContext) {
        let treasury_cap = book::simple_coin::new(COIN_OTW {}, ctx);
        transfer::public_transfer(treasury_cap, ctx.sender())
    }
}
```


 -->

<!-- ## Case Study: Coin

TODO: add a story behind TreasuryCap and Coin

-->

## Summary

The OTW pattern is a great way to ensure that a type is used only once. Most of the
developers should understand how to define and receive the OTW, while the OTW checks and enforcement
is mostly needed in libraries and frameworks. For example, the `sui::coin` module requires an OTW
in the `coin::create_currency` method, therefore enforcing that the `coin::TreasuryCap`
is created only once.

OTW is a powerful tool that lays the foundation for the [Publisher](./publisher.md)
object, which we will cover in the next section.

<!--

## Questions
- What other ways could be used to prevent multiple `TreasuryCap`s?
- Are there any other ways to use the OTW?

 -->
