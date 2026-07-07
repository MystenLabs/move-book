---
description: "One Time Witness (OTW) in Sui Move: a type guaranteed to be instantiated only once, used for Publisher and Coin creation."
---

# One Time Witness

While the regular [Witness](./witness-pattern) is a great way to statically prove the ownership of
a type, there are cases where we need to ensure that a witness is instantiated only once - and this
is the purpose of the One Time Witness (OTW).

## Background

To see the problem the OTW solves, let's try to build a simple generic coin implementation with the
tools we already have. A `TreasuryCap<T>` controls the supply of a coin of type `T`, and creating
one requires a [witness](./witness-pattern) of `T`:

```move
module book::simple_coin;

/// Controls the supply of the Coin.
public struct TreasuryCap<phantom T> has key, store {
    id: UID,
    total_supply: u64,
}

/// Create a new `TreasuryCap` with a witness.
/// Vulnerable: nothing prevents the caller from creating
/// multiple `TreasuryCap<T>`s with the same witness!
public fun new<T: drop>(_witness: T, ctx: &mut TxContext): TreasuryCap<T> {
    TreasuryCap { id: object::new(ctx), total_supply: 0 }
}
```

The regular witness proves that the calling module owns the type `T`, but it proves nothing about
_how many times_ the witness has been - or will be - constructed. A dishonest developer can simply
call `new` twice and keep a second treasury for themselves:

```move
module book::simple_coin_cheater;

/// The Coin witness... used twice. >_<
public struct MOVE has drop {}

fun init(ctx: &mut TxContext) {
    let treasury = book::simple_coin::new(MOVE {}, ctx);
    let secret_treasury = book::simple_coin::new(MOVE {}, ctx);

    transfer::public_transfer(treasury, ctx.sender());
    transfer::public_transfer(secret_treasury, ctx.sender());
}
```

For anyone deciding whether to trust a coin built this way, there is a whole list of conditions to
audit: that only one `TreasuryCap` exists for the given `T`, that the module has no backdoor to
issue more, and that a future upgrade cannot add one. None of these conditions can be checked from
within Move code - verifying them requires trust in the author, and careful (and repeated) review
of the source.

To remove the need for this trust, Sui introduces the One Time Witness - a witness that the system
itself guarantees to be instantiated exactly once, checkable at runtime.

## Definition

The OTW is a special type of witness that can be used only once. It cannot be manually created and
it is guaranteed to be unique per module. The Sui execution environment treats a type as an OTW if
it follows these rules:

1. Has only `drop` ability.
2. Has no fields.
3. Is not a generic type.
4. Named after the module with all uppercase letters.

Here is an example of an OTW:

```move file=packages/samples/sources/programmability/one-time-witness.move anchor=definition

```

The OTW cannot be constructed manually, and any code attempting to do so will result in a
compilation error. The OTW can be received as the first argument in the
[module initializer](./module-initializer). And because the `init` function is called only once per
module, the OTW is guaranteed to be instantiated only once.

## Enforcing the OTW

To check if a type is an OTW, the `sui::types` module of the [Sui Framework](./sui-framework)
offers a special function `is_one_time_witness`. This is the runtime counterpart of the rules
above: a library function that expects an OTW should call it to make sure the received witness is
the real, one-time one, and not a regular type with the `drop` ability.

```move file=packages/samples/sources/programmability/one-time-witness.move anchor=usage

```

This single `assert!` is what fixes the coin example from the [Background](#background) section:
if `simple_coin::new` required an OTW instead of a regular witness, the second call in the cheater
module would fail, because the OTW instance exists only once - in the first call.

## Summary

The OTW pattern is a great way to ensure that a type is used only once. Most developers only need
to know how to define and receive an OTW, while the checks and enforcement are mostly the concern
of libraries and frameworks. For example, the `sui::coin` module requires an OTW in the
`coin::create_currency` method, therefore enforcing that the `coin::TreasuryCap` is created only
once - solving exactly the problem we described in the [Background](#background) section.

OTW is a powerful tool that lays the foundation for the [Publisher](./publisher) object, which we
will cover in the next section.
