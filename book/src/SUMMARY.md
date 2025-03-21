# Summary

<!--

    Things that we don't have:
        - VM and bytecode
        - borrow checker

    Thoughts:
        - someone will jump, some sections will be skipped, some will be read in a different order;

    Audiences:
        - people who don't know anything about Move
        - people who know Move but don't know Sui
        - people who know Sui but don't know Move
        - people who tried Move and Sui and need more

 -->

<!--

- wrapped objects ???
- gas considerations
- custom transfer rules
- object and package versioning

-->

<!-- - [The Move Book](README.md) -->

- [The Move Book](README.md)
- [Foreword](foreword.md)
<!-- - [Introduction](introduction.md) -->
- [Before we begin](before-we-begin/README.md)
  - [Install Sui](before-we-begin/install-sui.md)
  - [Set up your IDE](before-we-begin/ide-support.md)
  - [Move 2024](before-we-begin/move-2024.md)
- [Hello, World!](your-first-move/hello-world.md)
- [Hello, Sui!](your-first-move/hello-sui.md)
<!--
    - [Prepare Package]()
    - [Create Account]()
    - [Publishing]()
    - [Sending Transactions]()
    - [Code Walkthrough]()
    - [Ideas]()
    - [Debugging]()
    - [Generating Docs]()
-->
- [Concepts](./concepts/README.md)
  - [Package](./concepts/packages.md)
  - [Manifest](./concepts/manifest.md)
  - [Address](./concepts/address.md)
  - [Account](./concepts/what-is-an-account.md)
  - [Transaction](./concepts/what-is-a-transaction.md)
- [Move Basics](./move-basics/README.md)
  - [Modules](./move-basics/module.md)
  - [Comments](./move-basics/comments.md)
  - [Primitive Types](./move-basics/primitive-types.md)
  - [Address Type](./move-basics/address.md)
  - [Expressions](./move-basics/expression.md)
  - [Structs](./move-basics/struct.md)
  - [Abilities: Introduction](./move-basics/abilities-introduction.md)
  - [Ability: Drop](./move-basics/drop-ability.md)
  - [Importing Modules](./move-basics/importing-modules.md)
  - [Standard Library](./move-basics/standard-library.md)
  - [Vector](./move-basics/vector.md)
  - [Option](./move-basics/option.md)
  - [String](./move-basics/string.md)
  - [Control Flow](./move-basics/control-flow.md)
  - [Constants](./move-basics/constants.md)
  - [Aborting Execution](./move-basics/assert-and-abort.md)
  - [Functions](./move-basics/function.md)
  - [Struct Methods](./move-basics/struct-methods.md)
  - [Visibility Modifiers](./move-basics/visibility.md)
  - [Ownership and Scope](./move-basics/ownership-and-scope.md)
  - [Ability: Copy](./move-basics/copy-ability.md)
  - [References](./move-basics/references.md)
  - [Generics](./move-basics/generics.md)
  - [Type Reflection](./move-basics/type-reflection.md)
  - [Testing](./move-basics/testing.md)
- [Object Model](./object/README.md) -pattern
  - [Language for Digital Assets](./object/digital-assets.md)
  - [Evolution of Move](./object/evolution-of-move.md)
  - [What is an Object?](./object/object-model.md)
  - [Ownership](./object/ownership.md)
  - [Fast Path & Consensus](./object/fast-path-and-consensus.md)
- [Using Objects](./storage/README.md)
  - [Ability: Key](./storage/key-ability.md)
  - [Storage Functions](./storage/storage-functions.md)
    <!-- - [Prices and Rebates]() -->
  - [Ability: Store](./storage/store-ability.md)
  - [UID and ID](./storage/uid-and-id.md)
  - [Restricted and Public Transfer](./storage/transfer-restrictions.md)
  - [Transfer to Object]() <!-- (./storage/transfer-to-object.md) -->
- [Advanced Programmability](./programmability/README.md)
  - [Transaction Context](./programmability/transaction-context.md)
  - [Module Initializer](./programmability/module-initializer.md)
  - [Pattern: Capability](./programmability/capability.md)
  - [Epoch and Time](./programmability/epoch-and-time.md)
  - [Collections](./programmability/collections.md)
  - [Pattern: Wrapper Type](./programmability/wrapper-type-pattern.md)
  - [Dynamic Fields](./programmability/dynamic-fields.md)
  - [Dynamic Object Fields](./programmability/dynamic-object-fields.md)
  - [Dynamic Collections](./programmability/dynamic-collections.md)
  - [Pattern: Witness](./programmability/witness-pattern.md)
  - [One Time Witness](./programmability/one-time-witness.md)
  - [Publisher Authority](./programmability/publisher.md)
  - [Display](./programmability/display.md) <!-- End Block: from Witness to Display -->
  - [Events](./programmability/events.md)
  - [Balance & Coin]() <!-- ./programmability/balance-and-coin.md) -->
  - [Sui Framework](./programmability/sui-framework.md)
  - [Pattern: Hot Potato](./programmability/hot-potato-pattern.md)
  - [Pattern: Request]()
  - [Pattern: Object Capability]()
  - [Package Upgrades]()<!-- (./programmability/package-upgrades.md) -->
  - [Transaction Blocks]()<!-- (./programmability/transaction-blocks.md) -->
  - [Authorization Patterns]()<!-- (./programmability/authorization-patterns.md) -->
  - [Cryptography and Hashing]()<!-- (./programmability/cryptography-and-hashing.md) -->
  - [Randomness]()<!-- (./programmability/randomness.md) -->
  - [BCS](./programmability/bcs.md)

# Guides

- [2024 Migration Guide](./guides/2024-migration-guide.md)
- [Upgradability Practices](./guides/upgradeability-practices.md)
- [Building against Limits](./guides/building-against-limits.md)
- [Better error handling](./guides/better-error-handling.md)
- [Open-sourcing Libraries]()
- [Creating an NFT Collection]()
- [Tests with Objects]()<!-- (./guides/testing.md) -->
<!-- - [Debugging]()(./guides/debugging.md) -->
- [Coding Conventions](./guides/coding-conventions.md)

# Appendix

- [A - Glossary](./appendix/glossary.md)
- [B - Reserved Addresses](./appendix/reserved-addresses.md)
- [C - Publications](./appendix/publications.md)
- [D - Contributing](./appendix/contributing.md)
- [E - Acknowledgements](./appendix/acknowledgements.md)
