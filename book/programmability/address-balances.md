---
description: "Address balances on Sui: hold fungible value directly at an address without a Coin object, send funds with send_funds, and withdraw them with a Withdrawal."
---

# Address Balances

A [`Coin`](./balance-and-coin) is an object: to spend it, a transaction has to reference it by its
ID, fetch it, and pass it in. That works well for discrete assets, but it makes an account's funds
a set of individual objects that have to be tracked, merged, and split. _Address balances_ offer a
different model: fungible value held directly at an address, as a running total, with no object to
manage.

Under the hood, the value lives in an on-chain _accumulator_ keyed by the pair `(address, type)`.
The balance of `T` at an address is a single number that goes up when funds are sent to it and down
when they are withdrawn - much closer to how a bank account works than to a wallet full of coins.

> Address balances are a newer addition to the Sui Framework. The core `send`/`withdraw` API is
> described below; some related capabilities (such as withdrawing from an object) are being rolled
> out behind protocol flags.

## Sending Funds to an Address

Any `Coin<T>` or [`Balance<T>`](./balance-and-coin#balance) can be deposited into an address balance
with `send_funds`. The value is consumed and credited to the recipient's balance of `T`:

```move file=packages/samples/sources/programmability/address-balances.move anchor=pay

```

`send_funds` is defined on both `Coin` and `Balance`. For a `Coin`, it turns the coin into a
`Balance` and adds it to the recipient's accumulator; there is no object left behind, and the
recipient does not need to "accept" anything - the balance simply increases.

> The current value of an address balance can be read from Move with
> `balance::settled_funds_value`, given a reference to the system `AccumulatorRoot` object. As the
> name suggests, it reports the funds _settled_ as of the beginning of the current consensus
> commit - deposits made within the commit are not yet visible to it.

## Withdrawing Funds

Going the other way - taking value _out_ of an address balance - is deliberately more restricted.
You cannot read from an arbitrary address's balance and mint a coin from it; instead, a withdrawal
is represented by a `Withdrawal<Balance<T>>` value, defined in the `sui::funds_accumulator` module
of the Sui Framework:

```move
/// A permission to withdraw up to `limit` units of `T` from `owner`.
public struct Withdrawal<phantom T: store> has drop {
    owner: address,
    limit: u256,
}
```

A `Withdrawal` is an _authorization_, not the funds themselves. It records whose balance is being
drawn from (`owner`) and the maximum amount that may be taken (`limit`). It has `drop`, so an unused
one can simply be discarded. The transaction provides it - a `Withdrawal` for the transaction sender
is supplied as an input by the transaction builder, in the same spirit as the gas coin or a
[received object](./../storage/transfer-to-object). There is no constructor for it in user code.

A transaction that spends from the sender's address balance therefore looks like this: the
`Withdrawal` comes in as an input, checked against the sender's balance at signing, and a command
turns it into a `Coin`:

```text
// Spending 1_000 MIST from the sender's address balance
// Input 0: Withdrawal<Balance<SUI>> { owner: sender, limit: 1_000 }
// Input 1: recipient address
0: sui::coin::redeem_funds<SUI>(Input(0)); // -> Coin<SUI>
1: TransferObjects([Result(0)], Input(1));
```

Once a function has a `Withdrawal`, it redeems it into a real `Coin` with `redeem_funds`:

```move file=packages/samples/sources/programmability/address-balances.move anchor=collect

```

Redemption is where the amount is actually moved out of the accumulator. It can only be performed
from the module that defines the withdrawn type - this is enforced with the
[internal permit](./../move-basics/internal-permit) mechanism, which is exactly why `sui::coin` and
`sui::balance` (the modules that define `Coin` and `Balance`) are the ones exposing `redeem_funds`.

## Inspecting and Splitting a Withdrawal

Before redeeming, the `Withdrawal` can be inspected and divided. This is useful when a single
withdrawal needs to fund several operations:

```move file=packages/samples/sources/programmability/address-balances.move anchor=split_join

```

Splitting and joining a `Withdrawal` only moves the _limit_ around; no funds change hands until
`redeem_funds` is called. Joining requires both withdrawals to have the same `owner`, and aborts
otherwise.

## Withdrawing from an Object

The owner of a `Withdrawal` does not have to be an account - it can be an object. An object with an
address balance can produce a withdrawal from its own funds with `withdraw_funds_from_object`,
passing a mutable reference to its `UID`:

```move file=packages/samples/sources/programmability/address-balances.move anchor=object_withdraw

```

This lets a shared object hold and pay out fungible value without wrapping individual `Coin`
objects. The withdrawal it produces is redeemed the same way as a sender's - through
`redeem_funds`.

> Withdrawing from an object is gated behind a protocol feature flag and may not be enabled on every
> network yet.

## Summary

- An _address balance_ is fungible value of type `T` held directly at an address in an on-chain
  accumulator, rather than as a `Coin` object;
- `coin.send_funds(recipient)` (or `balance.send_funds`) deposits value into an address balance,
  consuming the coin;
- withdrawing requires a `Withdrawal<Balance<T>>` - an authorization with an `owner` and a `limit` -
  which the transaction provides for the sender, or an object provides for itself;
- `coin::redeem_funds` turns a `Withdrawal` into a `Coin`, and can only be called from the module
  defining the type, via the [internal permit](./../move-basics/internal-permit) mechanism.

## Further Reading

- [sui::balance](https://docs.sui.io/references/framework/sui_sui/balance) module documentation.
- [Balance & Coin](./balance-and-coin) for the object-based side of fungible tokens.
