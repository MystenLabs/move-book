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
