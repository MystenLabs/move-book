---
description: "How Move handles digital assets natively: from fungible tokens to NFTs, with built-in safety and type-level resource guarantees."
---

# Move - Language for Digital Assets

Smart-contract programming languages have historically focused on defining and managing digital
assets. For example, the ERC-20 standard in Ethereum pioneered a set of standards to interact with
digital currency tokens, establishing a blueprint for creating and managing digital currencies on
the blockchain. Subsequently, the introduction of the ERC-721 standard marked a significant
evolution, popularizing the concept of non-fungible tokens (NFTs), which represent unique,
indivisible assets. These standards laid the groundwork for the complex digital assets we see today.

<!-- ## Move and Digital Assets -->

<!-- note: consider "native" -> "fine-grained" -->

However, Ethereum's programming model lacked a native representation of assets. From the outside,
an ERC-20 token behaved like an asset, but inside the contract it existed only as entries in a
ledger - a mapping of addresses to balances - with no value in the language that _is_ the asset.
From the start, Move aimed to provide a first-class abstraction for assets, opening up new avenues
for thinking about and programming assets.

<!-- Move was initially created in 2018 as part of the Libra project. The language was designed to address shortcomings in existing smart contract languages, especially in handling assets and access control. The Move language aims to provide first-class abstractions for these concepts, improving the safety and productivity of smart contract programming. -->

It is important to highlight which properties are essential for an asset:

- **Ownership:** Every asset is associated with an owner, mirroring the straightforward concept of
  ownership in the physical world, just as you own a car, you can own a digital asset. Move
  enforces ownership in such a way that once an asset is _moved_, the previous owner completely
  loses any control over it. This mechanism ensures a clear and secure change of ownership.

- **Non-copyable:** In the real world, unique items cannot be duplicated effortlessly. Move applies
  this principle to digital assets, ensuring they cannot be arbitrarily copied within the program.
  This property is crucial for maintaining the scarcity and uniqueness of digital assets, mirroring
  the intrinsic value of physical assets.

- **Non-discardable:** Just as you cannot accidentally lose a house or a car without a trace, Move
  ensures that no asset can be discarded or lost in a program. Instead, assets must be explicitly
  transferred or destroyed. This property guarantees the deliberate handling of digital assets,
  preventing accidental loss and ensuring accountability in asset management.

You have already met all three of these properties as language features. Ownership is enforced by
[move semantics](./../move-basics/ownership-and-scope): passing a value by value _moves_ it, and
the previous scope loses access. And the ability system controls the other two: a struct without
the [`copy`](./../move-basics/copy-ability) ability cannot be duplicated, and a struct without the
[`drop`](./../move-basics/drop-ability) ability cannot be thrown away. What looked like a set of
restrictions in the [Move Basics](./../move-basics) chapter turns out to be the exact toolkit for
modeling assets: a type with neither `copy` nor `drop` _must_ be explicitly handled - stored,
transferred, or destroyed - every time it is created.

## Summary

- Move was designed to provide a first-class abstraction for digital assets, enabling developers to
  create and manage assets natively.
- Essential properties of digital assets include ownership, non-copyability, and non-discardability,
  which Move enforces in its design.
- These properties map directly onto language features you already know: move semantics and the
  `copy` and `drop` abilities.
- Move's asset model mirrors real-world asset management, ensuring secure and accountable asset
  ownership and transfer.

## Further Reading

- [Move: A Language With Programmable Resources (pdf)](https://developers.diem.com/papers/diem-move-a-language-with-programmable-resources/2019-06-18.pdf)
  by Sam Blackshear, Evan Cheng, David L. Dill, Victor Gao, Ben Maurer, Todd Nowacki, Alistair Pott,
  Shaz Qadeer, Rain, Dario Russi, Stephane Sezer, Tim Zakian, Runtian Zhou\*
