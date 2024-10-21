# Pattern: Hot Potato

A case in the abilities system - a struct without any abilities - is called _hot potato_. It cannot
be stored (not as [an object](./../storage/key-ability.md) nor as
[a field in another struct](./../storage/store-ability.md)), it cannot be
[copied](./../move-basics/copy-ability.md) or [discarded](./../move-basics/drop-ability.md). Hence,
once constructed, it must be gracefully [unpacked by its module](./../move-basics/struct.md), or the
transaction will abort due to unused value without drop.

> If you're familiar with languages that support _callbacks_, you can think of a hot potato as an
> obligation to call a callback function. If you don't call it, the transaction will abort.

The name comes from the children's game where a ball is passed quickly between players, and none of
the players want to be the last one holding it when the music stops, or they are out of the game.
This is the best illustration of the pattern - the instance of a hot-potato struct is passed between
calls, and none of the modules can keep it.

## Defining a Hot Potato

A hot potato can be any struct with no abilities. For example, the following struct is a hot potato:

```move
{{#include ../../../packages/samples/sources/programmability/hot-potato-pattern.move:definition}}
```

Because the `Request` has no abilities and cannot be stored or ignored, the module must provide a
function to unpack it. For example:

```move
{{#include ../../../packages/samples/sources/programmability/hot-potato-pattern.move:new_request}}
```

## Example Usage

In the following example, the `Promise` hot potato is used to ensure that the borrowed value, when
taken from the container, is returned back to it. The `Promise` struct contains the ID of the
borrowed object, and the ID of the container, ensuring that the borrowed value was not swapped for
another and is returned to the correct container.

```move
{{#include ../../../packages/samples/sources/programmability/hot-potato-pattern.move:container_borrow}}
```

## Applications

Below we list some of the common use cases for the hot potato pattern.

### Borrowing

As shown in the [example above](#example-usage), the hot potato is very effective for borrowing with
a guarantee that the borrowed value is returned to the correct container. While the example focuses
on a value stored inside an `Option`, the same pattern can be applied to any other storage type, say
a [dynamic field](./dynamic-fields.md).

### Flash Loans

Canonical example of the hot potato pattern is flash loans. A flash loan is a loan that is borrowed
and repaid in the same transaction. The borrowed funds are used to perform some operations, and the
repaid funds are returned to the lender. The hot potato pattern ensures that the borrowed funds are
returned to the lender.

An example usage of this pattern may look like this:

```move
// Borrow the funds from the lender.
let (asset_a, potato) = lender.borrow(amount);

// Perform some operations with the borrowed funds.
let asset_b = dex.trade(loan);
let proceeds = another_contract::do_something(asset_b);

// Keep the commission and return the rest to the lender.
let pay_back = proceeds.split(amount, ctx);
lender.repay(pay_back, potato);
transfer::public_transfer(proceeds, ctx.sender());
```

### Variable-path execution

The hot potato pattern can be used to introduce variation in the execution path. For example, if
there is a module which allows purchasing a `Phone` for some "Bonus Points" or for USD, the hot
potato can be used to decouple the purchase from the payment. The approach is very similar to how
some shops work - you take the item from the shelf, and then you go to the cashier to pay for it.

```move
{{#include ../../../packages/samples/sources/programmability/hot-potato-pattern.move:phone_shop}}
```

This decoupling technique allows separating the purchase logic from the payment logic, making the
code more modular and easier to maintain. The `Ticket` could be split into its own module, providing
a basic interface for the payment, and the shop implementation could be extended to support other
goods without changing the payment logic.

### Compositional Patterns

Hot potato can be used to link together different modules in a compositional way. Its module may
define ways to interact with the hot potato, for example, stamp it with a type signature, or to
extract some information from it. This way, the hot potato can be passed between different modules,
and even different packages within the same transaction.

The most important compositional pattern is the [Request Pattern](./request-pattern.md), which we
will cover in the next section.

### Usage in the Sui Framework

The pattern is used in various forms in the Sui Framework. Here are some examples:

- [sui::borrow](https://docs.sui.io/references/framework/sui-framework/borrow) - uses hot potato to
  ensure that the borrowed value is returned to the correct container.
- [sui::transfer_policy](https://docs.sui.io/references/framework/sui-framework/transfer_policy) -
  defines a `TransferRequest` - a hot potato which can only be consumed if all conditions are met.
- [sui::token](https://docs.sui.io/references/framework/sui-framework/token) - in the Closed Loop
  Token system, an `ActionRequest` carries the information about the performed action and collects
  approvals similarly to `TransferRequest`.

## Summary

- A hot potato is a struct without abilities, it must come with a way to create and destroy it.
- Hot potatoes are used to ensure that some action is taken before the transaction ends, similar to
  a callback.
- Most common use cases for hot potato are borrowing, flash loans, variable-path execution, and
  compositional patterns.
