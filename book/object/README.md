# It starts with an Object

In the [Basic Syntax](../basic-syntax/README.md) section, we learned about the basics of Move. And there was one topic that we never touched upon - storage. As a language, Move does not have a built-in storage model, and it is up to the platform developers to implement the storage model. This is an important aspect of Move, as it allows the platform to be flexible and adapt to different use cases. In this section, we will focus on the Sui storage model, which is the *Object Model*. We will dive into the details of parallel execution, and how the Object Model helps solve the scalability and concurrent data access challenges of blockchain platforms.

This chapter is split into the following sections:

- [The Key Ability](./key-ability.md) - there we introduce the `key` ability and explain how it is used in Sui to define Objects.
- [What is an Object](./what-is-an-object.md) - we expand on the [concept of an Object](./../concepts/object-model.md) and provide a more in-depth explanation of its use in practice.
- [True Ownership](./true-ownership.md) - we explain the concept of *true ownership* and how it is addressed and implemented in the Sui Object Model. It has its befenits and drawbacks, and we will illustrate and explain them.
- [Transfer Restrictions](./transfer-restrictions.md) - a fundamental concept in Sui - the ability to restrict or relax the transfer ability of an Object using the `store` ability.
- [Immutable Data](./shared-state.md) - fundamental principles of shared state in Sui, and how shared immutable data is used in concurrent execution.
- [Shared State](./shared-state.md) - we explain how shared state works in Sui, and how it is used to implement concurrent execution.
- [Transfer to Object](./transfer-to-object.md) - rather special scenario in the Object model which allows transferring an Object to another Object.

The goal of this chapter is to provide a comprehensive understanding of the Object Model and its use on Sui. And in the [next chapter](./../programmability/README.md), we will dive deepere into *special* features of Sui which make it unique and powerful.

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

# UID type

The `UID` type is defined in the `sui::object` module and is a wrapper around an `ID` which, in turn, wraps the `address` type. The UIDs on Sui are guaranteed to be unique, and can't be reused.

Fresh UID generation:

- UID is derived from the `tx_hash` and an `index` which is incremented for each new UID.
- The `derive_id` function is implemented in the `sui::tx_context` module, and that is why TxContext is required for UID generation.
- Sui Verifier will not allow using a UID that wasn't created in the same function. That prevents UIDs from being pre-generated and reused after the object was unpacked.

New UID is created with the `object::new(ctx)` function. It takes a mutable reference to TxContext, and returns a new UID.

```move
let ctx = &mut tx_context::dummy();
let uid = object::new(ctx);
```

On Sui, `UID` acts as a representation of an object, and allows defining behavious and features of an object. One of the key-features - [Dynamic Fields]() - is possible because of the `UID` type being explicit. Additionally, it allows the [Transfer To Object (TTO)]() which we will explain later in this chapter.

## UID lifecycle

The `UID` type is created with the `object::new(ctx)` function, and it is destroyed with the `object::delete(uid)` function. The `object::delete` consumes the UID *by value*, and it is impossible to delete it unless the value was unpacked from an Object.

```move
let ctx = &mut tx_context::dummy();

let char = Character {
    id: object::new(ctx)
};

let Character { id } = char;
id.delete();
```

## Keeping the UID

The `UID` does not need to be deleted immediately after the object struct is unpacked. Sometimes it may carry [Dynamic Fields](./../programmability/dynamic-fields.md) or objects transferred to it via [Transfer To Object](./transfer-to-object.md). In such cases, the UID may be kept and stored in a separate object.

## Proof of Deletion

The ability to return the UID of an object may be utilized in pattern called *proof of deletion*. It is a rarely used technique, but it may be useful in some cases, for example, the creator or an application may incentivize the deletion of an object by exchanging the deleted IDs for some reward.

In framework development this method could be used ignore / bypass certain restrictions on "taking" the object. If there's a container that enforces certain logic on transfers, like Kiosk does, there could be a special scenario of skipping the checks by providing a proof of deletion.

This is one of the open topics for exploration and research, and it may be used in various ways.

## ID

When talking about `UID`s we should also mention the `ID` type. It is a wrapper around the `address` type, and is used to represent an address-pointer. Usually, `ID` is used to point at an object, however, there's no restriction, and no guarantee that the `ID` points to an existing object.

> ID can be received as a transaction argument in a [Transaction Block](). Alternatively, ID can be created from an `address` value using `to_id()` function.

```move

```

## fresh_object_address

TxContext provides the `fresh_object_address` function which can be utilized to create unique addresses and `ID`s - it may be useful in some application that assign unique identifiers to user actions - for example, an order_id in a marketplace.


# Storage Model

Now that we introduced the `key` ability and the `UID` type, we can finally talk about storage in Sui.
