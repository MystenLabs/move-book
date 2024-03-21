Notes for consideration

[Introduction](introduction.md)

This should explain what exactly Move is a little more. Explaining the language and how it's used on blockchains. Is it used the same across all blockchains? As a reader, there should be enough information here that I can determine if I should keep reading or if I've made a mistake coming here.

[History](history.md)

Does knowing the history of Diem help anyone learn Move? I'd recommend not having this page.  

[Before we begin](before-we-begin/README.md)

Dig it.

[Install Sui](install-sui.md) 

Dig it. Maybe add Chocolatey for Windows?

[Set up your IDE](before-we-begin/ide-support.md)

It's called set up, but is just a list of stuff. I imagine the only people reading this section are those that don't have an IDE in mind or are just making sure the one they want to use is on there. Would like to see some additional content around why those are the most populart IDEs. Maybe mention that you can use whatever IDE you choose, but there might not be tools to help.

[Move 2024](before-we-begin/move-2024.md)

Could use some more info. Is all the code I see online that doesn't use 2024 obsolete? It might say that in the Migration Guide, but we can't be sure the reader ever gets that far.

[Your First Move](your-first-move/README.md)

It reads not to worry about details and to wait until later, but then provides hyperlinks for users to jump. Suggest either mentioning you can jump ahead if you want (but shouldn't) or removing those hyperlinks in this section's pages. 

I like this being at the top of the nav. Jump right in before getting bogged down with concepts.

I think the title needs some tweaking.

I was expecting a full experience, including publishing. Maybe set expectations better of what reader can expect to have accomplished at the end of the chapter.

[Hello World!](your-first-move/hello-world.md)

> Revisit, decide if we should go that deep and detailed; Expect the user to know how to use a terminal and a text editor?

I think the detail in here is good. Because it's Hello World, I'd suggest biasing towards the most novice. If you don't need, you're probably still running the basic steps in your mind as you read them (rather than actually greping).

That said, I think there are still some opportunities to provide more details.

[Adding Tests](your-first-move/adding-tests.md)

Likey.

[Debugging](your-first-move/debugging.md)

Nice.

[Generating Docs](your-first-move/generating-docs.md)

This seems to kind of come out of nowhere. Probably just me. I think adding some words to the top section about this being here would help (set expectations comment above).

[Concepts](./concepts/README.md)

This is one of those areas where we need to consider what info goes where. Should it all live on one or the other? Briefly describe here and link to sui docs? 

Even though there's a nav on the left and a forward back option, I feel like a hyperlinked list would be beneficial here. Reader may have the nav closed. The list would help skip to the content of interest if they are familiar with some of the concepts.

I feel like a Move compiler topic would be useful here. How does it interact with the move code you write and what is actually published on chain?

[What is a Package](./concepts/packages.md)

I believe this was the first mention of bytecode. Maybe I missed it. Added a move compiler topic suggestion ^.

[Manifest](./concepts/manifest.md)

Good info. Could use some more info on requirements, if any, and scenarios of using local deps versus on-chain ones.

[Addresses](./concepts/address.md)

This might should go above Manifest as Manifest uses addresses (since this is in book format).  

[Module](./concepts/modules.md)

I'm assuming there'll be more? It doesn't explicitly mention that it's just Move code. 

[Interacting with a Package](./concepts/user-interaction.md)

Assuming there'll be more. I think you can describe how packages ultimately end up on a block chain and how you interact with their bytecode there. Could also mention different networks (mainnet/testnet) and how they're completely separate. Transactions are mentioned, but not PTBs.

[Account](./concepts/what-is-an-account.md)

Is an account an object? Do you have to have an account to publish a package? Are accounts the same across blockchains? 

This should go above Interacting/Package, as accounts are mentioned there.

[Transaction](./concepts/what-is-a-transaction.md)

Are there different kinds of transactions or are they always initiated by an address?  PTBs? 

Should go after module as it's used in other topics.

[Object Model](./concepts/object-model.md)

Definitely could use more here.



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
    - [Testing](./programmability/testing.md)
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
- [Programming Digital Assets]()
    <!-- - [What is an Asset]()
    - [Asset Lifecycle]()
    - [Asset Transfer]()
    - [Asset Ownership]()
    - [Asset Metadata]() -->
- [It starts with an Object](./object/README.md)
    - [The Key Ability]() <!-- (./object/key-ability.md) -->
    - [What is an Object]() <!-- (./object/what-is-an-object.md) -->
    - [True Ownership]() <!-- (./object/true-ownership.md) -->
    - [Transfer Restrictions]() <!-- (./object/transfer-restrictions.md) -->
    - [Shared State]() <!-- (./object/shared-state.md) -->
    - [Transfer to Object?]()<!-- (./object/transfer-to-object.md) -->
- [Advanced Programmability](./programmability/README.md)
    - [Transaction Context](./programmability/transaction-context.md)
    - [Pattern: Capability](./programmability/capability.md)
    - [Fast Path](./programmability/fast-path.md)
    - [Collections](./programmability/collections.md)
    - [Dynamic Fields](./programmability/dynamic-fields.md)
    - [Dynamic Collections]() <!-- (./programmability/dynamic-collections.md) -->
    - [Epoch and Time](./programmability/epoch-and-time.md)
    - [Package Upgrades]()<!-- (./programmability/package-upgrades.md) -->
    - [Witness and Abstract Implementation](./programmability/witness-and-abstract-implementation.md)
    - [One Time Witness]()
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
    - [Glossary](./appendix/glossary.md)
    - [References]() <!-- (./appendix/references.md) -->
    - [Contributing]() <!-- (./appendix/contributing.md) -->
    - [Acknowledgements]() <!-- (./appendix/acknowledgements.md) -->







General notes:

I suggest pretty much never using the word "please". It conveys that the instruction is not a requirement, even though it almost always is. Readers know that they always have the option of following instruction or not, so please is also pretty much always a throw away word. The only time I suggest using is if the reader is perceived to have been inconvenienced in some way. "If you get this error, please email us." And even then, I personally wouldn't use.

Consistent use of active voice is the best way to improve any writing. It's used well in here so far, but I'll be making suggestions where it isn't.

Future tense. Writing is better without it unless there is an actual temporal clause. The reader is currently reading, so most their actions happen now versus "will" happen sometime in the future. And using future tense always adds extra words. Fewer unneccessary words are always better in this form of writing.

Heading capitalizations are inconsistent. Should decide on what they should be and stick to it throughout.

The use of "we" is sometimes odd. "We learn about...". Why is my instructor also learning this stuff?