---
description: "Learn how Sui transactions work: structure, commands, gas payments, and how they change blockchain state through Move function calls."
---

# Transaction

A transaction is the fundamental way to interact with a blockchain. Transactions are used to
change the state of the blockchain, and they are the only way to do so. On Sui, a transaction can
call functions in published packages, deploy new packages, and upgrade existing ones.

## Transaction Structure

> Every transaction explicitly specifies the objects it operates on!

Transactions consist of:

- a sender - the [account](./what-is-an-account) that _signs_ the transaction;
- a list (or a chain) of commands - the operations to be executed;
- command inputs - the arguments for the commands: either `pure` - simple values like numbers or
  strings, or `object` - objects that the transaction will access;
- a gas object - the `Coin` object used to pay for the transaction;
- a gas price and budget - the cost of the transaction.

## Inputs

Transaction inputs are the arguments for the transaction, and come in two types:

- Pure arguments: These are mostly [primitive types](../move-basics/primitive-types) with some extra
  additions. A pure argument can be:
  - [`bool`](../move-basics/primitive-types#booleans).
  - [unsigned integer](../move-basics/primitive-types#integer-types) (`u8`, `u16`, `u32`, `u64`,
  `u128`, `u256`).
  - [`address`](../move-basics/address).
  - [`std::string::String`](../move-basics/string), UTF8 strings.
  - [`std::ascii::String`](../move-basics/string#ascii-strings), ASCII strings.
  - [`vector<T>`](../move-basics/vector), where `T` is a pure type.
  - [`std::option::Option<T>`](../move-basics/option), where `T` is a pure type.
  - [`sui::object::ID`](../storage/uid-and-id), typically points to an object. See also
  [What is an Object](../object/object-model).
- Object arguments: These are objects or references of objects that the transaction will access. An
  object argument needs to be either a shared object, a frozen object, or an object that the
  transaction sender owns for the transaction to be successful. For more see
  [Object Model](../object).

## Commands

Sui transactions may consist of multiple commands. Each command is a single built-in command (like
publishing a package) or a call to a function in an already published package. The commands are
executed in the order they are listed in the transaction, and they can use the results of the
previous commands, forming a chain. Transaction either succeeds or fails as a whole.

Any [`public`](../move-basics/visibility#public-visibility) function can be called as a command:
making a function `public` is all it takes for users to call it in a transaction, and it is the
default way to expose functionality in Move. (There is also the
[`entry`](../move-basics/visibility#entry-modifier) modifier, which creates functions callable
_only_ as transaction commands - a deliberately restricted option, covered in the
[Entry Functions](../move-advanced/entry-functions) section.)

Schematically, a transaction looks like this (in pseudo-code):

```
Inputs:
- sender = 0xa11ce

Commands:
- payment = SplitCoins(Gas, [ 1000 ])
- item = MoveCall(0xAAA::market::purchase, [ payment ])
- TransferObjects(item, sender)
```

In this example, the transaction consists of three commands:

1. `SplitCoins` - a built-in command that splits a new coin from the passed object, in this case,
   the `Gas` object;
2. `MoveCall` - a command that calls a function `purchase` in a package `0xAAA`, module `market`
   with the given arguments - the `payment` object;
3. `TransferObjects` - a built-in command that transfers the object to the recipient.

## Transaction Effects

Transaction effects are the changes that a transaction makes to the blockchain state. More
specifically, a transaction can change the state in the following ways:

- use the gas object to pay for the transaction;
- create, update, or delete objects;
- emit events;

The result of the executed transaction consists of different parts:

- Transaction Digest - the hash of the transaction which is used to identify the transaction;
- Transaction Data - the inputs, commands and gas object used in the transaction;
- Transaction Effects - the status and the "effects" of the transaction, more specifically: the
  status of the transaction, updates to objects and their new versions, the gas object used, the gas
  cost of the transaction, and the events emitted by the transaction;
- Events - the custom [events](./../programmability/events) emitted by the transaction;
- Object Changes - the changes made to the objects, including the _change of ownership_;
- Balance Changes - the changes made to the aggregate balances of the account involved in the
  transaction.

## Further Reading

- [Transactions](https://docs.sui.io/concepts/transactions) in the Sui Documentation.
- [Programmable Transaction Blocks](https://docs.sui.io/concepts/transactions/prog-txn-blocks) in
  the Sui Documentation.
- [Using Address Balances](https://docs.sui.io/onchain-finance/asset-custody/address-balances/using-address-balances)
  in the Sui Documentation - paying gas and moving funds without a `Coin` object.
