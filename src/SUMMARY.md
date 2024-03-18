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

- [Introduction](introduction.md)
- [Foreword](foreword.md)
- [History](history.md)
- [Before we begin](before-we-begin/README.md)
    - [Install Sui](before-we-begin/install-sui.md)
    - [Set up your IDE](before-we-begin/ide-support.md)
    - [Move 2024](before-we-begin/move-2024.md)
- [Your First Move](your-first-move/README.md)
    - [Hello World!](your-first-move/hello-world.md)
    - [Adding Tests](your-first-move/adding-tests.md)
    - [Debugging](your-first-move/debugging.md)
    - [Generating Docs](your-first-move/generating-docs.md)
- [Concepts](./concepts/README.md)
    - [What is a Package](./concepts/packages.md)
    - [Manifest](./concepts/manifest.md)
    - [Addresses](./concepts/address.md)
    - [Module](./concepts/modules.md)
    - [Interacting with a Package](./concepts/user-interaction.md)
    - [Account](./concepts/what-is-an-account.md)
    - [Transaction](./concepts/what-is-a-transaction.md)
    - [Object Model](./concepts/object-model.md)
- [Your First Sui App](./hello-sui/README.md)
    - [Hello Sui!](./hello-sui/hello-sui.md)
    - [Using Objects](./hello-sui/module-structure.md)
    - [Testing]()
    - [Publish and Interact]()
    - [Ideas]()
- [Syntax Basics](./basic-syntax/README.md)
    - [Module](./basic-syntax/module.md)
    - [Comments](./basic-syntax/comments.md)
    - [Primitive Types](./basic-syntax/primitive-types.md)
    - [Address Type](./basic-syntax/address.md)
    - [Expression](./basic-syntax/expression.md)
    - [Struct](./basic-syntax/struct.md)
    - [Abilities: Drop](./basic-syntax/drop-ability.md)
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
    - [Abilities: Copy](./basic-syntax/copy-ability.md)
    - [References](./basic-syntax/references.md)
    - [Generics](./basic-syntax/generics.md)
    - [Type Reflection](./basic-syntax/type-reflection.md)
    <!-- - [Enums]() (./basic-syntax/enums.md) -->
    <!-- - [Macro Functions]() (./basic-syntax/macro-functions.md) -->
    <!--
    Somewhere here we should mention that Move does not enforce a storage model
    and can be used with different storage models like UTXO, account-based, or
    object-based. And then it's okay to proceed to how Sui does it.
    -->
    <!--
    Don't forget to give an explainer on what an asset is and how it translates
    to Move and Sui. A reminder to the reader why we are learning all this.
     -->
- [It starts with an Object]() <!-- (./object/README.md) -->
    - [The Key Ability]() <!-- (./object/key-ability.md) -->
    - [What is an Object]() <!-- (./object/what-is-an-object.md) -->
    - [True Ownership]() <!-- (./object/true-ownership.md) -->
    - [Transfer Restrictions]() <!-- (./object/transfer-restrictions.md) -->
    - [Shared State]() <!-- (./object/shared-state.md) -->
    - [Transfer to Object?]()<!-- (./object/transfer-to-object.md) -->
- [Advanced Programmability](./programmability/README.md)
    - [Fast Path](./programmability/fast-path.md)
    - [Transaction Context](./programmability/transaction-context.md)
    - [Collections](./programmability/collections.md)
    - [Dynamic Fields](./programmability/dynamic-fields.md)
    - [Dynamic Collections]() <!-- (./programmability/dynamic-collections.md) -->
    - [Testing](./programmability/testing.md)
    - [Epoch and Time](./programmability/epoch-and-time.md)
    - [Package Upgrades]()<!-- (./programmability/package-upgrades.md) -->
    - [Witness and Abstract Implementation](./programmability/witness-and-abstract-implementation.md)
    - [Transaction Blocks]()<!-- (./programmability/transaction-blocks.md) -->
    - [Authorization Patterns]()<!-- (./programmability/authorization-patterns.md) -->
    - [Cryptography and Hashing]()<!-- (./programmability/cryptography-and-hashing.md) -->
    - [Randomness]()<!-- (./programmability/randomness.md) -->
- [Standards]()
    - [Coin]()
    - [Transfer Policy]()
    - [Kiosk]()
    - [Closed Loop Token]()
- [Special Topics]()
    - [BCS]()
    - [Coding Conventions]()
- [Guides](./guides/README.md)
    - [2024 Migration Guide](./guides/2024-migration-guide.md)
    - [Upgradability Practices](./guides/upgradeability-practices.md)
    - [Building against Limits](./guides/building-against-limits.md)
    - [Better error handling](./guides/better-error-handling.md)
    - [Testing]()<!-- (./guides/testing.md) -->
    - [Debugging]()<!-- (./guides/debugging.md) -->
- [Appendix]()
    - [Glossary](./appendix/glossary.md)
    - [References]() <!-- (./appendix/references.md) -->
    - [Contributing]() <!-- (./appendix/contributing.md) -->
    - [Acknowledgements]() <!-- (./appendix/acknowledgements.md) -->




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
