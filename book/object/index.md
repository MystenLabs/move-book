---
description: "The Sui Object Model explained: theory and concepts behind digital asset representation, ownership, and storage on the Sui blockchain."
---

# Object Model

So far we have studied Move as a language: types, functions, and abilities, all operating on values
that live and die within a single transaction. But a smart contract is only useful if its state
persists. This chapter introduces the _Object Model_ - the answer Sui gives to the question of how
data is stored, owned, and accessed onchain.

The chapter focuses on theory and concepts, preparing you for a practical dive into storage
operations and resource ownership. It reads best in order:

- [Language for Digital Assets](./digital-assets) - why Move treats assets as first-class values,
  and which properties make an asset;
- [Evolution of Move](./evolution-of-move) - how the original account-based storage model worked,
  and why Sui replaced it;
- [What is an Object?](./object-model) - the object as the unit of storage: type, ID, owner,
  version, and digest;
- [Ownership](./ownership) - the five ways an object can be owned, and what each of them allows;
- [Fast Path and Consensus](./fast-path-and-consensus) - how ownership determines the way a
  transaction is executed.

The chapters that follow build directly on these concepts: [Using Objects](./../storage) shows how
objects are defined and managed in code, and
[Advanced Programmability](./../programmability) covers the features built on top of them.

> This chapter is a high-level overview of the concepts and principles behind the Object Model. For
> a more detailed, protocol-level description, refer to the
> [Sui Documentation](https://docs.sui.io/guides/developer/objects/object-model).
