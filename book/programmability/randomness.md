---
description:
  'Onchain randomness in Sui: generate secure random values in Move smart contracts using the
  Random shared object.'
---

# Onchain Randomness

Randomness is a surprisingly hard problem for a blockchain. Execution has to be deterministic -
every validator must run a transaction and arrive at exactly the same result - and every input is
public. Values that may look random, such as the [current time](./epoch-and-time), the epoch, or a
transaction digest, are predictable or, worse, can be influenced by the sender or by validators.
When there is money on the line, "looks random" is not enough: any source of randomness that can be
predicted or biased will eventually be exploited.

To solve this, Sui generates randomness _collectively_: at the beginning of each epoch, validators
run a distributed key generation protocol, and then, on every consensus commit, they jointly produce
a new random value that no single party - not even a validator - could know in advance. This value
is written into the `Random` system object and made available to Move programs.

## The `Random` Object

The `Random` object is defined in the `sui::random` module and has a reserved address `0x8` (see
[Reserved Addresses](./../appendix/reserved-addresses)). The address is the same on every network -
localnet, devnet, testnet, and mainnet - so it can be safely hardcoded in applications and client
code. Similar to the [Clock](./epoch-and-time#time) object, it is a shared object which cannot be
accessed mutably - a transaction attempting to take it by a mutable reference will fail. This allows
parallel access to randomness, and protects the global state from tampering.

```move
module sui::random;

/// Singleton shared object which stores the global randomness state.
/// The actual state is stored in a versioned inner field.
public struct Random has key {
    id: UID,
    inner: Versioned,
}
```

The inner state of the object is updated by the system on every consensus commit, and its
unpredictability does not degrade over the course of an epoch.

## Using Randomness

Randomness is not read from the `Random` object directly. Instead, a transaction creates a
`RandomGenerator` - a local source of random values, derived from the global state and unique to the
transaction. The generator provides methods for the common needs: booleans, integers of every size,
integers in a range (bounds are inclusive), raw bytes, and shuffling of vectors:

```move file=packages/samples/sources/programmability/randomness.move anchor=generator

```

A typical use looks like this: a function takes `&Random`, creates a generator with `new_generator`,
and uses it to produce as many values as it needs. The following example mints a `Medal` of a random
quality - 10% chance of Gold, 30% of Silver, and 60% of Bronze:

```move file=packages/samples/sources/programmability/randomness.move anchor=main

```

The example is intentionally split into two functions, and this split is the recommended way to
structure code that uses randomness. Let's look at why.

## Encapsulating Randomness Correctly

The `mint_medal` function is declared as a private [entry](./../move-basics/visibility) function -
it can be called from a transaction, but not from other modules. This is intentional, and it is the
single most important rule of using randomness:

> Functions that take `&Random` (or `RandomGenerator`) as a parameter should never be `public`. This
> includes `public entry` - a `public entry` function is still callable from other modules. For
> randomness, always use a private `entry` function.

To see why, let's break the rule. Here is a variation of the same function which is `public` and
returns the result of the roll:

```move
/// Mints a `Medal`, transfers it to the caller, and returns the quality.
public fun risky_mint(random: &Random, ctx: &mut TxContext): u8 {
    let mut generator = random.new_generator(ctx);
    let medal = mint_medal_impl(&mut generator, ctx);
    let quality = medal.quality;
    transfer::transfer(medal, ctx.sender());
    quality
}
```

Nothing prevents another module from wrapping this function, inspecting the outcome, and aborting if
it is not favorable. An abort rolls back all effects of the transaction, so at the price of gas, the
attacker gets to "re-roll" - retrying until they win:

```move
/// The module of an attacker.
module attacker::exploit;

entry fun re_roll(random: &Random, ctx: &mut TxContext) {
    let quality = book::randomness::risky_mint(random, ctx);

    // Not Gold? Abort, revert all effects, and try again
    // in the next transaction.
    assert!(quality == 0);
}
```

Importantly, this is not a hard limit - the `risky_mint` function compiles. The Move linter flags
the risky signature with the `public_random` warning, which should be treated as an error unless you
know exactly what you are doing:

```
warning[Lint W99006]: Risky use of 'sui::random'
  │
  │ public fun risky_mint(random: &Random, ctx: &mut TxContext): u8 {
  │                               ^^^^^^^ 'public' function 'risky_mint' accepts 'Random' as a parameter
  │
  = Functions that accept 'sui::random::Random' as a parameter might be abused by attackers
    by inspecting the results of randomness
  = Non-public functions are preferred
```

What Sui does enforce - at the protocol level - is transaction composition: in a programmable
transaction block, a command that uses `Random` can only be followed by `TransferObjects` or
`MergeCoins` commands. Neither of them can inspect a value or abort based on it, which makes
randomness _non-composable by design_: the result of a random roll can never be acted upon by any
other code in the same transaction. The outcome is delivered exclusively through the effects of the
function - such as the `Medal` object transferred to the caller.

The `entry` function is still inconvenient to test: it requires the full `Random` object - a shared
object which takes effort to set up in a test. This is why the actual logic lives in a separate
function with `public(package)` visibility, which takes a `RandomGenerator` instead of `Random`:

- the `entry` function is a thin facade: it creates the generator and passes it on;
- the `public(package)` function contains the logic, returns a value, and can be called directly in
  tests - with a test-only generator, no `Random` object required.

Note that the inner function must not be `public` either - passing a `RandomGenerator` to an
untrusted caller is just as dangerous as passing `Random`, since the caller can inspect the result
and conditionally abort. The linter warns about `public` functions with `RandomGenerator` parameters
as well.

## Calling from a Transaction

To call an entry function which expects `&Random`, pass the `Random` object at `0x8` as the
argument - as mentioned above, the address is identical on every network. For example, with the Sui
CLI:

```bash
sui client ptb \
    --move-call $PACKAGE_ID::randomness::mint_medal @0x8
```

Due to the restrictions described in the previous section, the call must effectively be the last
command in the transaction block - only `TransferObjects` and `MergeCoins` commands may follow it.

## Testing

The pattern above pays off in tests. The `sui::random` module provides test-only functions to create
generators without the `Random` object: `new_generator_for_testing` and
`new_generator_from_seed_for_testing`. A seeded generator always produces the same sequence of
values, which makes tests reproducible - and since different seeds produce different sequences, you
can search for seeds that lead the test into a specific branch, covering every outcome
deterministically. A non-seeded generator is useful for property-style checks that must hold for any
outcome:

```move file=packages/samples/sources/programmability/randomness.move anchor=test_unit

```

To test the entry function itself - the full flow, as a transaction would execute it - use
[Test Scenario](./../testing/test-scenario) and create the shared `Random` object with
`random::create_for_testing`. Note that the `Random` object can only be created and updated by the
system address `0x0`:

```move file=packages/samples/sources/programmability/randomness.move anchor=test_scenario

```

See [Creating and Using System Objects in Tests](./../testing/using-system-objects) for more details
on testing with system objects.

> Onchain randomness should not be confused with the [`#[random_test]`](./../testing/random-test)
> attribute, which is a compiler feature for generating random test inputs.

## Limitations

Onchain randomness is unpredictable _before_ the transaction executes, but it is not a secret: once
the transaction is committed, the result is public, like everything else onchain. This makes it a
great fit for fair selection - raffles, loot tables, matchmaking, shuffling - but not for hidden
information. A card game where players hold concealed hands cannot be built on the `Random` object
alone and requires additional cryptography.

Other limitations follow from the security rules described above:

- randomness is non-composable by design: the consuming function must be `entry` and effectively the
  last meaningful command in the transaction, so its result cannot be inspected or acted upon within
  that transaction - the outcome is delivered through effects, such as objects created or
  transferred by the function;
- the outcome cannot be known in advance - a dry run of the transaction will not match the actual
  execution;
- randomness is only available in transactions, there is no way to "peek" at the next value.

## Attacks and Mitigations

Even with correct encapsulation, one class of attacks remains, and it is the responsibility of the
application developer: _conditional failure_ attacks. The platform guarantees the attacker cannot
choose the outcome, but if the transaction can be made to fail more often on a loss than on a win
(or vice versa), the attacker still gains an edge - a failed transaction rolls everything back,
granting a free retry.

The main variation is the _gas-based_ attack. If the winning and losing branches consume different
amounts of gas, an attacker can set the gas budget between the two costs: the cheaper branch
completes, and the more expensive one fails with an out-of-gas error, undoing the unfavorable
result. Similar tricks can rely on other limited resources, such as the number of new objects or
dynamic field accesses in a transaction.

To mitigate exposure:

- keep the gas cost of all outcomes as close as possible - avoid expensive logic that only runs on
  one of the branches (in the `Medal` example, every outcome performs the same work);
- if outcomes do require different processing, split the flow into two transactions: the first one
  draws the randomness and stores the raw result in an object, using the same cost for every
  outcome; the second one - a regular function which no longer touches `Random` - applies the
  consequences;
- never expose `Random` or `RandomGenerator` through `public` functions, and always create a fresh
  generator inside the function that uses it.

## Further Reading

- [Onchain Randomness](https://docs.sui.io/guides/developer/advanced/randomness-onchain) guide in
  Sui documentation.
- [sui::random](https://docs.sui.io/references/framework/sui/random) module documentation.
