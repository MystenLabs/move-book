---
description:
  'Entry functions in Move: how the entry modifier restricts a function to transaction-only calls,
  and the static hot-potato guarantee its arguments receive in return.'
---

# Entry Functions

An [`entry`](./../move-basics/visibility#entry-modifier) function is a special kind of
transaction-callable function - one that deliberately _limits_ the options of its caller. As
covered in the [Visibility Modifiers](./../move-basics/visibility) chapter, `entry` is not a
visibility level, and it is not how functions are normally made callable from a
[transaction](./../concepts/what-is-a-transaction) - a `public` function already is, and `public`
remains the default. The `entry` modifier is only meaningful on _non-public_ functions - private or
`public(package)` - and what it creates is a function with a narrowed contract, in two directions:

- _who can call it:_ outside of its own module (or package), the function can be invoked only as a
  command in a transaction - no other package can wrap it, act on its result, or build it into
  larger logic;
- _what the call can be combined with:_ the arguments passed to it must be free of obligations
  created by other commands in the same transaction - they are checked to behave as if the `entry`
  function were the only command.

The first restriction follows directly from visibility rules and was covered in Move Basics. This
chapter describes the second - a static guarantee about the arguments, and the rules behind it. The
material requires familiarity with the
[hot potato pattern](./../programmability/hot-potato-pattern), the
[abilities](./../move-basics/abilities-introduction), and how transactions are structured, which is
why it lives here rather than in Move Basics.

## The Hot Potato Guarantee

Arguments to a non-`public` `entry` function (either private or `public(package)`) cannot be
_entangled_ with a [hot potato](./../programmability/hot-potato-pattern) - a value whose type has
neither `store` nor `drop`, and which therefore must be dealt with before the transaction ends. In
practice this means the arguments behave as if the `entry` function were the only command in the
transaction: no earlier command can force behavior on the transaction after the `entry` function is
called.

> This guarantee is checked _statically_, before the transaction begins execution. A transaction
> that violates it fails verification and is not executed. These rules were introduced in Sui v1.62,
> replacing an older, more restrictive set.

The canonical motivation is a _flash loan_ - borrowing funds that must be repaid within the same
transaction. A simplified lender looks like this:

```move
module flash::loan;

use sui::balance::Balance;
use sui::sui::SUI;

public struct Bank has key {
    id: UID,
    holdings: Balance<SUI>,
}

/// A hot potato: no `store`, no `drop`. Once issued, the transaction
/// cannot succeed until it is destroyed by calling `repay`.
public struct Loan {
    amount: u64,
}

public fun issue(bank: &mut Bank, amount: u64): (Balance<SUI>, Loan) {
    assert!(bank.holdings.value() >= amount);
    let loaned = bank.holdings.split(amount);
    (loaned, Loan { amount })
}

public fun repay(bank: &mut Bank, loan: Loan, repayment: Balance<SUI>) {
    let Loan { amount } = loan;
    assert!(repayment.value() == amount);
    bank.holdings.join(repayment);
}
```

A developer writing an `entry` function that accepts a `Coin` may want to be sure the coin is really
"owned" by the sender, and not borrowed from such a bank with an outstanding repayment obligation.
The `entry` rules provide exactly that.

## The Rules

The verification tracks how many hot potato values are outstanding and which values they could
influence. Some terminology:

- A _value_ is any argument of a transaction command: a transaction input, the result of a previous
  command, or the gas coin.
- A value is _hot_ if its type has neither `store` nor `drop`. This leaves three possible shapes: a
  type with no abilities at all, a type with only `copy`, or a type with only `key` (a type cannot
  have both `key` and `copy`, since `sui::object::UID` does not have `copy`).
- Every value belongs to a _clique_ - a group of values that have been used together as arguments to
  a command, along with the results of that command. Each clique counts its outstanding hot values.

The algorithm walks the commands of the transaction in order:

1. Each transaction input starts in its own clique with a count of zero.
2. When values are used together in a command - by value or by reference - their cliques are merged,
   and their counts are added together.
3. The count is decremented for each hot value _moved_ into the command (taken by value, not
   copied).
4. If the command calls a non-`public` `entry` function, the count of the merged clique must be zero
   at this point. Note that this means an `entry` function _can_ take hot values - they must just be
   the last hot values in their clique.
5. The results of the command join the merged clique, and the count is incremented for each hot
   result.

Let's walk through it. Given a module with the following functions:

```move
module book::example;

use sui::coin::Coin;
use sui::sui::SUI;

public struct HotPotato()

public fun hot(coin: &mut Coin<SUI>): HotPotato { /* ... */ HotPotato() }
public fun cool(potato: HotPotato) { let HotPotato() = potato; }

entry fun spend(coin: &mut Coin<SUI>) { /* ... */ }
```

The following transaction is rejected. The call to `hot` produced a hot potato, so `Input(0)` is in
a clique with an outstanding hot value when `spend` is called:

```text
// Invalid transaction
// Input 0: Coin<SUI>
// cliques: { Input(0) } => 0
0: book::example::hot(Input(0));
// cliques: { Input(0), Result(0) } => 1
1: book::example::spend(Input(0)); // INVALID, Input(0)'s clique has a count > 0
2: book::example::cool(Result(0));
```

Destroying the hot potato first brings the count back to zero, and the same call becomes valid:

```text
// Valid transaction
// Input 0: Coin<SUI>
// cliques: { Input(0) } => 0
0: book::example::hot(Input(0));
// cliques: { Input(0), Result(0) } => 1
1: book::example::cool(Result(0));
// cliques: { Input(0) } => 0
2: book::example::spend(Input(0)); // Valid! Input(0)'s clique has a count of 0
```

The clique is what makes the rule robust: entanglement spreads through _any_ shared usage, not just
direct one. Using the `flash::loan` module, the `Coin` below was created from the loaned `Balance`
and never touched the `Loan` directly - yet it is in the same clique, and cannot be passed to the
`entry` function until the loan is repaid:

```text
// Invalid transaction
// Input 0: flash::loan::Bank
// Input 1: u64
// cliques: { Input(0) } => 0, { Input(1) } => 0
0: flash::loan::issue(Input(0), Input(1));
// cliques: { Input(0), NestedResult(0,0), NestedResult(0,1) } => 1
1: sui::coin::from_balance(NestedResult(0,0));
// cliques: { Input(0), NestedResult(0,1), Result(1) } => 1
2: book::example::spend(Result(1)); // INVALID, Result(1)'s clique has count > 0
3: sui::coin::into_balance(Result(1));
4: flash::loan::repay(Input(0), NestedResult(0,1), Result(3));
```

If the loan were repaid before calling `spend`, the transaction would pass verification.

## Shared Objects

There is one special case: when a command takes a _shared object_ by value, the count of the merged
clique is set to infinity. A non-`public` `entry` function can still take a shared object by value
directly, but it cannot take a value whose clique previously interacted with one.

The reason is that a shared object taken by value can force behavior in the rest of the transaction
much like a hot potato does: it cannot be wrapped or transferred, so it must be either re-shared or
deleted before the transaction ends. But unlike a hot potato, this obligation is not visible in the
type's abilities, so the verification has to assume the worst.

[Party objects](./../appendix/transfer-functions) taken by value fall under the same restriction,
although in narrower cases than shared objects.

> Because the rules are applied statically, before execution, they are deliberately pessimistic: a
> dynamic check could be more precise, but a static one is easier to describe and to rely on.

## Further Reading

- [Visibility Modifiers](./../move-basics/visibility) in Move Basics, for the basics of `entry`.
- [Visibility](./../../reference/functions#visibility) in the Move Reference.
