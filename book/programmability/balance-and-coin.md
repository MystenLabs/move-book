---
description: "Balance, Coin, and CoinRegistry in Sui Move: create fungible tokens with the Currency standard, manage supply with TreasuryCap, and store metadata onchain."
---

# Balance and Coin

Fungible tokens are the most common kind of digital asset: units of value that are interchangeable
with each other, like money. On Sui, the main abstraction for fungible tokens is
[`Coin`](https://docs.sui.io/references/framework/sui_sui/coin) - the object that wallets hold,
transactions take as inputs, and applications accept as payment. Owning "10 SUI" means owning a
`Coin<SUI>` object with the value of 10 SUI.

Two supporting types complete the standard - one layer below `Coin`, and one above:

- [`Balance`](https://docs.sui.io/references/framework/sui_sui/balance) - the raw amount inside a
  `Coin`: a plain value without an object ID, which applications use to store and accumulate funds;
- [`Currency`](https://docs.sui.io/references/framework/sui_sui/coin_registry) - a shared object
  describing the coin type itself: its metadata, supply, and regulatory status.

This section walks through all three, and shows how to create a currency with the
`sui::coin_registry` module - the standard way of doing it.

## Balance

The `Balance<T>` type is defined in the `sui::balance` module. It is a plain value with the `store`
ability - not an object: it has no `UID` and no storage overhead of its own. This makes it the type
of choice for _keeping_ funds: whenever an application needs to store or accumulate value inside
its own types - a vault, a liquidity pool, an escrow - it embeds a `Balance`, not a `Coin`.

```move
/// Storable balance - an inner struct of a Coin type.
/// Can be used to store coins which don't need the key ability.
public struct Balance<phantom T> has store {
    value: u64,
}
```

The [phantom type parameter](./../move-basics/generics#phantom-type-parameters) `T` is what makes
one balance different from another: `Balance<GOLD>` and `Balance<DBL>` are distinct,
non-interchangeable types, even though both store just a `u64`.

`Balance` has no `copy`, no `drop`, and no public constructor for a non-zero value. A balance can
only be created by increasing the total supply of `T`, and can only disappear by decreasing it.
Everything in between - splitting, joining, storing - just moves the value around. This is the
[ownership](./../move-basics/ownership-and-scope) guarantee applied to money: no duplication, no
accidental loss.

```move file=packages/samples/sources/programmability/balance-and-coin.move anchor=balance

```

## Coin

`Balance` cannot exist on its own in storage - it has to be wrapped in an object. The
`sui::coin::Coin` type is the standard wrapper:

```move
/// A coin of type `T` worth `value`.
public struct Coin<phantom T> has key, store {
    id: UID,
    balance: Balance<T>,
}
```

With `key` and `store`, a `Coin` is a full-fledged object: it can be owned by an account,
transferred, and passed into transactions as an input. The gas object used to pay for transactions
is a `Coin<SUI>`. This gives the standard its rule of thumb: `Coin` at the boundary, `Balance`
inside. Funds enter an application as a `Coin`, are stored and accumulated as a `Balance`, and
leave as a `Coin` again.

The API mirrors `Balance` - splitting, joining, and converting between the two:

```move file=packages/samples/sources/programmability/balance-and-coin.move anchor=coin

```

> The samples above conjure their `Coin` and `Balance` out of thin air with the test-only
> `coin::mint_for_testing` and `balance::create_for_testing` functions - the standard tools for
> testing coin-handling code, covered in
> [Using System Objects in Tests](./../testing/using-system-objects).

In transactions, coins receive special treatment: the native `SplitCoins` and `MergeCoins`
[commands](./../concepts/what-is-a-transaction#commands) operate on coins directly, so a wallet can
prepare an exact payment - even split it off the gas coin - without calling any module functions.
This is why modules rarely need to expose split or merge functionality of their own.

The `sui::coin` module also provides `coin::take` and `coin::put` helpers, which combine the
conversion and the split/join steps: `take` splits a `Coin` out of a `Balance`, and `put` merges a
`Coin` into a `Balance`. They come in handy when an application stores funds as a `Balance` and
sends them out as `Coin`s.

> Coin objects are not the only way to hold fungible value: a newer mechanism keeps it directly at
> an address, as a running total with no object to manage. It builds on the types described here,
> and is covered in the [Address Balances](./address-balances) section.

## Currency and the Coin Registry

A single `Coin<T>` says nothing about the token `T` itself: its name, its symbol, how many decimals
it uses, or how its supply is managed. This information is stored once per type in a `Currency<T>`
object, and all currencies are tracked by the `CoinRegistry` - a system object with the reserved
address `0xc`:

```move
/// System object found at address `0xc` that stores coin data for all
/// registered coin types.
public struct CoinRegistry has key { id: UID }
```

The `Currency<T>` object holds everything there is to know about the coin type `T`:

```move
/// Currency stores metadata such as name, symbol, decimals, icon_url and
/// description, as well as supply state (optional) and regulatory status.
public struct Currency<phantom T> has key {
    id: UID,
    /// Number of decimal places the coin uses for display purposes.
    decimals: u8,
    /// Human-readable name for the coin.
    name: String,
    /// Short symbol/ticker for the coin.
    symbol: String,
    /// Detailed description of the coin.
    description: String,
    /// URL for the coin's icon/logo.
    icon_url: String,
    /// Current supply state of the coin (fixed, burn-only, or unknown).
    supply: Option<SupplyState<T>>,
    /// Regulatory status of the coin (regulated with deny cap or unknown).
    regulated: RegulatedState,
    /// ID of the treasury cap for this coin type, if registered.
    treasury_cap_id: Option<ID>,
    /// ID of the metadata capability for this coin type, if claimed.
    metadata_cap_id: MetadataCapState,
    /// Additional fields for extensibility.
    extra_fields: VecMap<String, ExtraField>,
}
```

Most of these fields get their own section on this page: the supply state, the regulatory status,
and the two capabilities are all covered below. One field, however, deserves attention right away:
`decimals`. Move has no fractional
numbers - the value of a `Coin` is a plain integer, counting the currency's smallest units, and
`decimals` tells clients where to put the decimal point _for display_. With `decimals = 8`, a
`Coin` with the value `100_000_000` is displayed as `1` coin; the native SUI currency has 9
decimals, and its base unit even has a name of its own - MIST. Amounts in Move code - minting,
splitting, comparing - are always expressed in base units.

The `coin_registry` module is _the_ way to create a currency: it replaced the original
`coin::create_currency` function, which stored metadata in a standalone `CoinMetadata` object (we
cover the differences [at the end of this section](#legacy-coin-metadata)). It offers two ways to
create a currency, both producing the same result: a shared `Currency<T>` object with a
[derived address](https://docs.sui.io/references/framework/sui_sui/derived_object), so that the
metadata for any coin type can be found without knowing its object ID.

### Creating a Currency in `init`

The most common flow uses a [One-Time Witness](./one-time-witness) to guarantee that a currency for
the type can be created only once, in the [module initializer](./module-initializer):

```move file=packages/samples/sources/programmability/balance-and-coin-2.move anchor=gold

```

The `new_currency_with_otw` call returns two values:

- `CurrencyInitializer` - a temporary value used to configure the currency before it is published.
  It cannot be stored or dropped, so the transaction cannot succeed until it is consumed by the
  `finalize` call (a technique we explore in the
  [Hot Potato Pattern](./hot-potato-pattern) section);
- `TreasuryCap<T>` - the [capability](./capability) that controls minting and burning, explored in
  the [Supply and TreasuryCap](#supply-and-treasurycap) section below.

The `finalize` call returns one more capability - the `MetadataCap<T>`, which controls updates to
the currency metadata. However, in the OTW flow, `finalize` does not complete the registration.
Because `init` runs during publishing, before the `CoinRegistry` can be passed in as an argument,
the `Currency<GOLD>` object takes a detour: `finalize` transfers it to the registry's address,
where it waits for the second, closing step - `finalize_registration`:

```move
/// The second step in the "otw" initialization of coin metadata, that takes in
/// the `Currency<T>` that was transferred from init, and transforms it in to a
/// "derived address" shared object.
///
/// Can be performed by anyone.
public fun finalize_registration<T>(
    registry: &mut CoinRegistry,
    currency: Receiving<Currency<T>>,
    _ctx: &mut TxContext,
);
```

This function [receives](./../storage/transfer-to-object) the `Currency<T>` sent to the registry
and re-creates it as a shared object with a derived address. Until it is called, the registration
is incomplete: the `Currency<GOLD>` is not shared, cannot be found at its derived address, and
cannot be passed into any function that reads or updates it. The call is permissionless - anyone
can make it, and indexers often do - but it should not be left to chance:

> Treat `finalize_registration` as a mandatory part of the OTW flow, not as optional cleanup. The
> publisher should call it in a follow-up transaction right after publishing - only then is the
> currency fully registered and usable.

### Creating a Currency Dynamically

The second flow does not require an OTW and can be performed at any time after the package is
published - for example, in an application that creates currencies on demand. The
`new_currency` function takes the `CoinRegistry` directly, and the `Currency<T>` is shared
immediately on `finalize`, with no extra registration step:

```move file=packages/samples/sources/programmability/balance-and-coin-3.move anchor=doubloon

```

### One Type, Two Shapes

Both flows denominate the currency with a marker type `T`, but they demand different shapes from
it, matching how each flow proves that the currency is created only once:

- `new_currency_with_otw` takes a `T` with `drop` - specifically, a
  [One-Time Witness](./one-time-witness): a `drop`-only struct with no fields, named after its
  module. The proof is the witness _value_ itself: it exists exactly once, is consumed by the
  call, and can never be produced again - so neither can the currency.
- `new_currency` takes a _key-only_ `T` - `has key` and nothing else, with the single `id: UID`
  field. No instance of `T` is passed, only the type argument, so there is no witness value to
  prove anything. Instead, two checks stand in: `new_currency` is subject to the
  [internal constraint](./../storage/internal-constraint) - like `sui::event::emit`, it can only be
  called with a type defined in the calling module - and the registry aborts if a `Currency<T>` has
  already been registered.

A key-only type cannot have `drop`, so the same type can never be used with both flows.

## Supply and TreasuryCap

The [Balance](#balance) section stated that value can only be created by increasing the total
supply of `T`, and can only disappear by decreasing it. The type that does both is `Supply<T>`,
defined in `sui::balance` as the accounting counterpart of `Balance`:

```move
module sui::balance;

/// A Supply of T. Used for minting and burning.
public struct Supply<phantom T> has store {
    value: u64,
}

/// Increase supply by `value`, creating a new `Balance<T>`.
public fun increase_supply<T>(self: &mut Supply<T>, value: u64): Balance<T>;

/// Destroy a `Balance<T>`, decreasing the supply by its value.
public fun decrease_supply<T>(self: &mut Supply<T>, balance: Balance<T>): u64;
```

These two functions are the only gate through which value enters and leaves circulation, so every
unit of `Balance<T>` in existence is accounted for by the `Supply<T>` - the number in the supply
always equals the sum of all balances of `T`.

And just as `Coin` is the object form of a `Balance`, the `TreasuryCap<T>` - the capability
returned by both creation flows - is the object form of a `Supply`:

```move
module sui::coin;

/// Capability allowing the bearer to mint and burn
/// coins of type `T`. Transferable
public struct TreasuryCap<phantom T> has key, store {
    id: UID,
    total_supply: Supply<T>,
}
```

Owning the `TreasuryCap` _is_ owning the supply authority. Its `mint` and `burn` functions are thin
wrappers over the supply: `mint` increases it and wraps the new `Balance` into a `Coin`, `burn`
unwraps a `Coin` and decreases the supply by its value. As long as the `TreasuryCap` exists, the
current total can be read from it with `total_supply`.

```move file=packages/samples/sources/programmability/balance-and-coin-3.move anchor=mint_burn

```

Whoever owns the `TreasuryCap` controls the supply, so where the capability ends up is a design
decision: kept by the publisher for a managed supply, stored inside an application object for
programmatic minting, or given up entirely - as described next.

> A `Supply` can also exist on its own: `balance::create_supply` turns a witness into a raw
> `Supply<T>` - it is, in fact, the example we used to introduce the
> [Witness pattern](./witness-pattern) - and `treasury_into_supply` extracts the supply from a
> `TreasuryCap`. These are low-level tools: a currency created through the registry should keep
> its `TreasuryCap` intact, since the supply states described next operate on the capability.

## Supply States

By default, the supply of a currency is flexible - the `Currency<T>` object records it as `Unknown`
and the `TreasuryCap` can mint and burn freely. The registry supports two irreversible transitions,
both consuming the `TreasuryCap`:

- `make_supply_fixed` - the supply can never change again. The `Doubloon` example above uses this:
  it mints the entire supply upfront and fixes it in the same call;
- `make_supply_burn_only` - no more minting, but anyone can burn coins with the
  `coin_registry::burn` and `burn_balance` functions, which take the shared `Currency` object and
  permanently decrease the supply.

Both can be applied either during initialization (on the `CurrencyInitializer`) or later, on the
shared `Currency<T>` object. Consuming the capability is not just ceremony: the transition unpacks
the `TreasuryCap` and moves its `Supply<T>` _into_ the `Currency` object - which is why, from that
point on, the `Currency` itself tracks the total supply, readable onchain with `total_supply`.

## Managing Metadata

The name, symbol, description, and icon URL of a currency can be updated after creation with the
`set_name`, `set_symbol`, `set_description`, and `set_icon_url` functions - each requiring a
reference to the `MetadataCap<T>`. Like the `TreasuryCap`, the `MetadataCap` can be deleted with
`delete_metadata_cap`, making the metadata immutable forever - or never claimed in the first
place: `finalize_and_delete_metadata_cap` finalizes the currency with immutable metadata from the
start. Either way, the deletion is recorded in the `Currency`, so the cap can never be claimed
again.

## Reading a Currency

A `Currency<T>` is not only for its creator. As a shared object with a derived address, it can be
found for any coin type and passed - by immutable reference - into any function, and the registry
provides getters for every field: `decimals`, `name`, `symbol`, `description`, `icon_url`, the
supply checks `is_supply_fixed` and `is_supply_burn_only`, and the `treasury_cap_id`,
`metadata_cap_id`, and `deny_cap_id` functions to locate the currency's capabilities - or to verify
that they were deleted (the deny cap belongs to _regulated_ currencies, covered
[below](#regulated-currencies)).

This turns coin metadata into something applications can rely on _on-chain_: a lending protocol
can require the supply of a collateral coin to be fixed, and the function below uses `decimals` to
accept deposits only in whole units of a currency:

```move file=packages/samples/sources/programmability/balance-and-coin-4.move anchor=currency_reader

```

## Regulated Currencies

A currency can opt into regulation during initialization by calling `make_regulated` on the
`CurrencyInitializer`. This creates one more capability - `DenyCapV2<T>` - whose owner maintains a
_deny list_: addresses that cannot use `Coin<T>` as transaction inputs. The list itself lives in
the `DenyList` system object at the reserved address `0x403`, managed by the
[sui::deny_list](https://docs.sui.io/references/framework/sui/deny_list) module. Optionally, a
regulated currency can support a _global pause_, stopping all transfers of the coin type. This
feature exists for compliance-heavy assets like stablecoins; most currencies are created without
it.

## Legacy Coin Metadata

Before the `CoinRegistry`, currencies were created with `coin::create_currency`, which produced a
standalone `CoinMetadata<T>` object instead of a `Currency<T>`. This function is deprecated, but
plenty of currencies created with it are still live, and some applications still expect
`CoinMetadata` as an argument. The registry provides a bridge in both directions:

- `migrate_legacy_metadata` registers an existing `CoinMetadata` in the registry, creating a
  `Currency<T>` for it;
- `borrow_legacy_metadata` produces a `CoinMetadata` view of a registry-native `Currency<T>`, for
  compatibility with older interfaces (returned within the same transaction via a hot potato).

New code should always use the `coin_registry` flows.

## Summary

- `Coin<T>` is the main abstraction for fungible tokens: an object that can be owned, transferred,
  and passed into transactions;
- `Balance<T>` is the unit of accounting inside a `Coin`: a non-object value that cannot be copied
  or dropped, only moved, split, and joined - and the type applications embed to keep funds;
- `Currency<T>` describes the coin type: metadata, supply state, and regulatory status. It is
  created through the `CoinRegistry` system object, either with an OTW in `init` or dynamically -
  and can be _read_ onchain by any module;
- `Supply<T>` is the accounting authority: the only gate through which `Balance` value is created
  and destroyed. `TreasuryCap<T>` is its object form - it controls minting and burning, and can be
  given up to fix the supply;
- `MetadataCap<T>` controls metadata updates, and can be deleted to make them immutable;
- coin values are integers of base units; the `decimals` field of a `Currency` is display-only.

## Further Reading

- [Currency Standard](https://docs.sui.io/onchain-finance/fungible-tokens/currency) in Sui
  Documentation.
- [sui::coin_registry](https://docs.sui.io/references/framework/sui_sui/coin_registry) module
  documentation.
- [sui::coin](https://docs.sui.io/references/framework/sui_sui/coin) module documentation.
- [sui::balance](https://docs.sui.io/references/framework/sui_sui/balance) module documentation.
