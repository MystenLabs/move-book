---
description: "Learn how to use Sui objects in Move: storage abilities, transfer functions, ownership rules, and object lifecycle management."
---

# Using Objects

The [Object Model][object-model] chapter introduced objects conceptually: the unit of storage,
with an identity, an owner, and an ownership state that shapes execution. This chapter turns those
concepts into code. You will learn how to define an object type, how to create and destroy
objects, and how to move them between ownership states - transfer, freeze, and share.

The sections build on each other and are meant to be read in order:

- [Ability: Key](./key-ability) - the ability that turns a struct into an object;
- [Ability: Store](./store-ability) - the ability that permits a type to be stored inside objects,
  and controls who can operate on the object;
- [Sui Verifier: Internal Constraint](./internal-constraint) - the bytecode-level rule that
  reserves critical operations for the module defining the type;
- [Storage Functions](./storage-functions) - the operations that place objects into storage:
  transfer, freeze, and share;
- [UID and ID](./uid-and-id) - the identity of every object, and its lifecycle;
- [Receiving as Object](./transfer-to-object) - the mechanism that lets objects own other objects.

> Two types from the [Sui Framework](./../programmability/sui-framework) appear in almost every
> example of this chapter: `UID` - the unique identifier stored in every object - and `TxContext` -
> a special value describing the current transaction, available to any function as its last
> argument. Both are covered in depth later ([UID and ID](./uid-and-id) in this chapter,
> [Transaction Context](./../programmability/transaction-context) in the next one); to get
> started, it is enough to know that `object::new(ctx)` uses the transaction context to produce a
> fresh, unique `UID`.

If you haven’t read the [Object Model][object-model] chapter yet, we recommend starting there
before continuing.

[object-model]: ./../object
