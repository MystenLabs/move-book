# Summary

<!--

    Things that we don't have:
        - VM and bytecode
        - why Move is safe
        - double spending and compiler checks
        - borrow checker
        - papers and research behind Move and Sui

        - use capability and not address
        - ownership

    Thoughts:
        - someone will jump, some sections will be skipped, some will be read in a different order;

    Audiences:
        - people who don't know anything about Move
        - people who know Move but don't know Sui
        - people who know Sui but don't know Move
        - people who tried Move and Sui and need more


 -->

<!--

comparison to docs.sui.io
    - strings (+)
    - collections (+)
    - module initializer (+)
    - entry functions (+)
    - one-time-witness (+)
    - patterns
        - capability
        - witness
        - transferable witness
        - hot potato
        - id pointer
    - conventions

- wrapped objects ???
- shared objects
- table and bag
- gas considerations
- custom transfer rules
- object and package versioning

-->

- [Introduction](introduction.md)
- [Foreword]() <!-- foreword.md) -->
- [History](history.md)
- [Before we begin](before-we-begin/README.md)
  - [Install Sui](before-we-begin/install-sui.md)
  - [Set up your IDE](before-we-begin/ide-support.md)
  - [Move 2024](before-we-begin/move-2024.md)
- [Your First Move](your-first-move/README.md)
  - [Hello World!](your-first-move/hello-world.md)
  - [Your First Sui App]() <!-- ./hello-sui/README.md) -->
  - [Publishing]()
  - [Hello Sui!]() <!--  ./hello-sui/hello-sui.md) -->
  - [Using Objects]()<!-- (./hello-sui/module-structure.md) -->
  - [Adding Tests]() <!--  your-first-move/adding-tests.md) -->
  - [Debugging]() <!-- your-first-move/debugging.md) -->
  - [Generating Docs]() <!-- your-first-move/generating-docs.md) -->
    <!-- TODO:  -->
    <!-- - [Send a Transaction]() -->
- [Concepts](./concepts/README.md)
  - [What is a Package](./concepts/packages.md)
  - [Manifest](./concepts/manifest.md)
  - [Addresses](./concepts/address.md)
  - [Module](./concepts/modules.md)
  - [Interacting with a Package](./concepts/user-interaction.md)
  - [Account](./concepts/what-is-an-account.md)
  - [Transaction](./concepts/what-is-a-transaction.md)
  - [Object Model](./concepts/object-model.md)
- [Syntax Basics](./basic-syntax/README.md)
  - [Module](./basic-syntax/module.md)
  - [Comments](./basic-syntax/comments.md)
  - [Primitive Types](./basic-syntax/primitive-types.md)
  - [Address Type](./basic-syntax/address.md)
  - [Expression](./basic-syntax/expression.md)
  - [Struct](./basic-syntax/struct.md)
  - [Ability: Drop](./basic-syntax/drop-ability.md)
  - [Importing Modules](./basic-syntax/importing-modules.md)
  - [Standard Library](./basic-syntax/standard-library.md)
  - [Vector](./basic-syntax/vector.md)
  - [Option](./basic-syntax/option.md) <!-- Option requires vector -->
  - [String](./basic-syntax/string.md) <!-- String requires vector and option for try_* -->
  - [Control Flow](./basic-syntax/control-flow.md)
  - [Constants](./basic-syntax/constants.md)
  - [Assert and Abort](./basic-syntax/assert-and-abort.md)
  - [Function](./basic-syntax/function.md)
  - [Struct Methods](./basic-syntax/struct-methods.md)
  - [Visibility Modifiers](./basic-syntax/visibility.md)
  - [Ownership and Scope](./basic-syntax/ownership-and-scope.md)
  - [Ability: Copy](./basic-syntax/copy-ability.md)
  - [References](./basic-syntax/references.md)
  - [Generics](./basic-syntax/generics.md)
  - [Type Reflection](./basic-syntax/type-reflection.md)
  - [Testing](./basic-syntax/testing.md)
    <!-- - [Enums]() (./basic-syntax/enums.md) -->
    <!-- - [Macro Functions]() (./basic-syntax/macro-functions.md) -->
    <!--
    Somewhere here we should mention that Move does not enforce a storage model
    -->
    <!--
    Don't forget to give an explainer on what an asset is and how it translates
    to Move and Sui. A reminder to the reader why we are learning all this.
     -->
- [Programming Digital Assets]()
    <!-- - [What is an Asset]()
    - [Asset Lifecycle]()
    - [Asset Transfer]()
    - [Asset Ownership]()
    - [Asset Metadata]() -->
- [It starts with an Object](./object/README.md)
  - [Ability: Key](./object/key-ability.md)
  - [What is an Object]() <!-- (./object/what-is-an-object.md) -->
  - [True Ownership]() <!-- (./object/true-ownership.md) -->
  - [Transfer Restrictions]() <!-- (./object/transfer-restrictions.md) -->
  - [Ability: Store]() <!-- ./object/store-ability.md) -->
  - [Shared State]() <!-- (./object/shared-state.md) -->
  - [Transfer to Object?]()<!-- (./object/transfer-to-object.md) -->
- [Advanced Programmability](./programmability/README.md)
  - [Transaction Context](./programmability/transaction-context.md)
  - [Module Initializer](./programmability/module-initializer.md)
  - [Pattern: Capability](./programmability/capability.md)
  - [Epoch and Time](./programmability/epoch-and-time.md)
  - [Fast Path](./programmability/fast-path.md)
  - [Collections](./programmability/collections.md)
  - [Dynamic Fields](./programmability/dynamic-fields.md)
  - [Dynamic Object Fields](./programmability/dynamic-object-fields.md)
  - [Dynamic Collections](./programmability/dynamic-collections.md)
  - [Package Upgrades]()<!-- (./programmability/package-upgrades.md) -->
  - [Pattern: Witness]() <!-- ./programmability/witness-pattern.md) <!-- Block: from Witness to Display -->
  - [One Time Witness](./programmability/one-time-witness.md)
  - [Publisher Authority](./programmability/publisher.md)
  - [Display](./programmability/display.md) <!-- End Block: from Witness to Display -->
  - [Events](./programmability/events.md)
  - [Balance & Coin]() <!-- ./programmability/balance-and-coin.md) -->
  - [Sui Framework](./programmability/sui-framework.md)
  - [Pattern: Request]() <!-- - [Witness and Abstract Implementation](./programmability/witness-and-abstract-implementation.md) -->
  - [Pattern: Hot Potato]()
  - [Pattern: Object Capability]()
  - [Transaction Blocks]()<!-- (./programmability/transaction-blocks.md) -->
  - [Authorization Patterns]()<!-- (./programmability/authorization-patterns.md) -->
  - [Cryptography and Hashing]()<!-- (./programmability/cryptography-and-hashing.md) -->
  - [Randomness]()<!-- (./programmability/randomness.md) -->
  - [BCS](./programmability/bcs.md)
- [Patterns (?)]()
  - [Getters and Setters]()
  - [Abstract Class]()
  - [Hot Potato]()
  - [Request]()
  - [Object Capability]()
  - [Witness Registry]()
- [Standards]()
  - [Balance]()
  - [Coin]()
  - [Closed Loop Token]()
  - [Transfer Policy]()
  - [Kiosk]()
- [Guides](./guides/README.md)
  - [2024 Migration Guide](./guides/2024-migration-guide.md)
  - [Upgradability Practices](./guides/upgradeability-practices.md)
  - [Building against Limits](./guides/building-against-limits.md)
  - [Better error handling](./guides/better-error-handling.md)
  - [Open-sourcing Libraries]()
  - [Testing]()<!-- (./guides/testing.md) -->
  - [Debugging]()<!-- (./guides/debugging.md) -->
  - [Coding Conventions]()
- [Appendix]()
  - [A - Glossary](./appendix/glossary.md)
  - [B - Publications]() <!-- ./appendix/publications.md) -->
  - [C - References]() <!-- (./appendix/references.md) -->
  - [D - Contributing](./appendix/contributing.md)
  - [E - Acknowledgements]() <!-- (./appendix/acknowledgements.md) -->

<!-- - [Syntax Basics](basic-syntax/README.md)
    - [Module](modules.md)
    - [Comments](comments.md)
    - [Address](address.md)
    - [Primitive Types](primitive-types.md)
    - [Expression and Scope](expression-and-scope.md)
    - [Control Flow]()
        - [If](if.md)
        - [Loop](loop.md)
        - [While](while.md)
    - [Constants](constants.md)
    - [Error Handling]()
    - [Function](function.md)
    - [Imports](imports.md)
    - [Struct](struct.md)
    - [Standard Library]()
        - [Vector](managing-collections-with-vectors.md)
        - [Option](option.md)
        - [String](string.md)
- [It starts with an Object]()
    - [What is an Object]()
    - [True Ownership]()
    - [Transfer Restrictions]()
    - [Shared State]()
        - [Freezing an Object]()
        - [Mutable Shared State]()
    - [Transfer to Object?]()
    - [Dynamic Fields]()
- [Know the Context]()
    - [Epochs]()
    - [Sender]()
- [Patterns]()
    - [Getters and Setters]()
    - [Capability]()
    - [Witness]()
    - [Abstract Class]()
    - [Hot Potato]()
    - [Request + Policy]()
- [Sui Framework]()
    - [TxContext]()
    - [String]()
    - [Url]()
    - [Choose a Collection type]()
    - [VecSet]()
    - [VecMap]()
    - [vector]()
    - [Dynamic Fields]()
    - [Table]()
    - [Linked Table]()
    - [Testing]()
    - [Test Scenario]()
    - [Transfer]()
    - [Cryptography]()
    - [Hashes](hashes.md)
    - [Clock](clock.md)
    - [Randomness]()
    - [Freeze Object]()
    - [TypeName and Reflection]()
    - [ID and UID]()
    - [Public Transfer Functions]()
    - [Share Object]()
    - [Key Ability and UID]()
    - [Balance]()
    - [Coin]()
    - [Token]()
    - [Capability]()
    - [Error Constants]()
