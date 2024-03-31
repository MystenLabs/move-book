# It starts with an Object

In the [Basic Syntax](../basic-syntax/README.md) section, we learned about the basics of Move. And there was one topic that we never touched upon - storage. As a language, Move does not have a built-in storage model, and it is up to the platform developers to implement the storage model. This is an important aspect of Move, as it allows the platform to be flexible and adapt to different use cases. In this section, we will focus on the Sui storage model, which is the _Object Model_. We will dive into the details of parallel execution, and how the Object Model helps solve the scalability and concurrent data access challenges of blockchain platforms.

This chapter is split into the following sections:

- [The Key Ability](./key-ability.md) - there we introduce the `key` ability and explain how it is used in Sui to define Objects.
- [What is an Object](./what-is-an-object.md) - we expand on the [concept of an Object](./../concepts/object-model.md) and provide a more in-depth explanation of its use in practice.
- [True Ownership](./true-ownership.md) - we explain the concept of _true ownership_ and how it is addressed and implemented in the Sui Object Model. It has its befenits and drawbacks, and we will illustrate and explain them.
- [Transfer Restrictions](./transfer-restrictions.md) - a fundamental concept in Sui - the ability to restrict or relax the transfer ability of an Object using the `store` ability.
- [Immutable Data](./shared-state.md) - fundamental principles of shared state in Sui, and how shared immutable data is used in concurrent execution.
- [Shared State](./shared-state.md) - we explain how shared state works in Sui, and how it is used to implement concurrent execution.
- [Transfer to Object](./transfer-to-object.md) - rather special scenario in the Object model which allows transferring an Object to another Object.

The goal of this chapter is to provide a comprehensive understanding of the Object Model and its use on Sui. And in the [next chapter](./../programmability/README.md), we will dive deepere into _special_ features of Sui which make it unique and powerful.

# Object

- Move has explicit definition of an object - the `key` ability.
- Every object with the `key` ability must have a field `id: UID` which we will talk about later.
- The `key` ability is required for a struct to be "storable" at the top level in the Sui storage model.
- The `key` ability is a requirement for `transfer`, `share_object` and `freeze_object` functions.
- A struct with `id: UID` but without a `key` ability is not an object and can't be used in storage functions.
- `UID` can't be dropped, hence it is impossible to define a combination of `key` and `drop`. This makes objects non-discardable by design.
- `UID`, `TxContext`, `object` are all implicitly imported into the module, so no need to add an extra import.

A very typical object instantiation on Sui looks like this:

```move
public struct Object has key { id: UID }

public fun new_object(ctx: &mut TxContext): Object {
    Object {
        id: object::new(ctx)
    }
}
```



<!--

```move
///
public struct Object has key {
    id: UID
}
```

## UID type
## Creating an Object
## Deleting an Object
## UID freshness requirement

Sui Verifier will not allow using a UID that wasn't generated in the same function. In other words - reusing UID or passing it from another function won't work.

##

-->

# UID type

The `UID` type is defined in the `sui::object` module and is a wrapper around an `ID` which, in turn, wraps the `address` type. The UIDs on Sui are guaranteed to be unique, and can't be reused.

Fresh UID generation:

- UID is derived from the `tx_hash` and an `index` which is incremented for each new UID.
