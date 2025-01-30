# Transaction

Transaction is a fundamental concept in the blockchain world. It is a way to interact with a
blockchain. Transactions are used to change the state of the blockchain, and they are the only way
to do so. In Move, transactions are used to call functions in a package, deploy new packages, and
upgrade existing ones.

<!--

- how user interacts with a program
    - mention public functions
    - give a concept of an entry / public function without getting into details
    - mention that functions are called in transactions
    - mention that transactions are sent by accounts
    - every transaction specifies object it operates on

 -->

## Transaction Structure

> Every transaction explicitly specifies the objects it operates on!

Transactions consist of:

- a sender - the [account](./what-is-an-account.md) that _signs_ the transaction;
- a list (or a chain) of commands - the operations to be executed;
- command inputs - the arguments for the commands: either `pure` - simple values like numbers or
  strings, or `object` - objects that the transaction will access;
- a gas object - the `Coin` object used to pay for the transaction;
- gas price and budget - the cost of the transaction;

## Inputs

Transaction inputs are the arguments for the transaction and are split between 2 types:
- Pure arguments: These are mostly [primitive types](../move-basics/primitive-types.html) with some
extra additions. A pure argument can be:
    - [`bool`](../move-basics/primitive-types.html#booleans).
    - [unsigned integer](../move-basics/primitive-types.html#integer-types) (`u8`, `u16`, `u32`, `u64`, `u128`, `u256`).
    - [`address`](../move-basics/address.html).
    - [`std::string::String`](../move-basics/string.html), UTF8 strings.
    - [`std::ascii::String`](../move-basics/string.html#ascii-strings), ASCII strings.
    - [`vector<T>`](../move-basics/vector.html), where `T` is a pure type.
    - [`std::option::Option<T>`](../move-basics/option.html), where `T` is a pure type.
    - [`std::object::ID`](../storage/uid-and-id.html), typically points to an object. See also [What is an Object](../object/object-model.html).
- Object arguments: These are objects or references of objects that the transaction will access. An
object argument needs to be either a shared object, a frozen object, or an object that the
transaction sender owns, in order for the transaction to be successful.
For more see [Object Model](../object/index.html).

## Commands

Sui transactions may consist of multiple commands. Each command is a single built-in command (like
publishing a package) or a call to a function in an already published package. The commands are
executed in the order they are listed in the transaction, and they can use the results of the
previous commands, forming a chain. Transaction either succeeds or fails as a whole.

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

<!--
> There are multiple different implementations of transaction building, for example
-->

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
- Events - the custom [events](./../programmability/events.md) emitted by the transaction;
- Object Changes - the changes made to the objects, including the _change of ownership_;
- Balance Changes - the changes made to the aggregate balances of the account involved in the
  transaction;
