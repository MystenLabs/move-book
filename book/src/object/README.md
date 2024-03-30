# Object Model

This chapter describes the Object Model of Sui. It focuses on the theory and concepts behind the Object Model, and prepares you for the practical dive into the Sui Storage operations.

## Digital Assets

Smart-contract programming languages have historically focused on defining and managing digital assets. Take Ethereum as an example: the ERC-20 standard pioneered the concept of digital currency tokens, establishing a blueprint for creating and managing digital currencies on the blockchain. Following this, the introduction of the ERC-721 standard marked a significant evolution, bringing about the concept of non-fungible tokens (NFTs), which represent unique, indivisible assets. These standards laid the groundwork for the complex digital assets we see today.

However, the programming model that Ethereum had, lacked a native representation of the asset. In other words, externally, a Smart-Contract behaved like an asset but the language itself did not have a way to represent assets. The goal of Move from the start was to provide first-class abstraction for assets, to open up a new way of thinking and programming assets.

It is important to highlight which properties are essential for an asset:

- Ownership: Every asset is associated with an owner. This is a straightforward concept mirroring the physical world—just as you own a car, you can own a digital asset. Move enforces ownership in such a way that once an asset is transferred, the previous owner completely loses any control over it. This mechanism ensures a clear and secure change of ownership.

- Non-copyable: In the real world, unique items cannot be duplicated effortlessly. Move applies this principle to digital assets, ensuring they cannot be arbitrarily copied within the program. This property is crucial for maintaining the scarcity and uniqueness of digital assets, mirroring the intrinsic value we see in physical assets.

- Non-discardable: Just as you cannot accidentally lose a house or a car without a trace, Move ensures that digital assets cannot be "lost" or discarded within a program. Instead, assets must be explicitly transferred or destroyed. This property guarantees the deliberate handling of digital assets, preventing accidental loss and ensuring accountability in asset management.

Move managed to capture these properties in its design, becoming the language for digital assets.

<!-- By integrating these properties, Move's resource-oriented model offers a novel and secure framework for digital asset management on the blockchain. This foundational focus distinguishes Move and, by extension, Sui, as pioneering platforms that offer unique solutions to the challenges of digital asset representation and security in the blockchain space. -->

## From Account to Object

While Move was created to manage digital assets, its first version had rather bulky storage model which was not very suited for majority of the use-cases. For example, in a case where Alice wants to transfer an asset X to Bob, Bob has to create a new "empty" resource and then Alice can transfer the asset X to Bob. This is not very intuitive and also not very convient to implement, however, it was part of the restrictive design that Diem had. Another drawback of the original design was the lack of built-in support for "transfer" operation, which meant that every module had to implement its own storage transfer logic. Lastly, the hardest part of the original storage model was storing and managing heterogeneous collections of assets in a single account.

Sui took this as a challenge and re-designed the storage model to make look closer to real-world objects. If there is a native concept of ownership and *transfer*, then Alice can directly transfer the asset X to Bob. Additionally, Bob could have a collection of different assets without any overhead or a preparation step. These properties laid the foundation for the Object Model in Sui.

## Object Model

The Object Model in Sui is a high-level abstraction that represents digital assets as *objects*. Objects have their own type and associated behaviours, unique identifier and support native storage operations like *transfer* and *share*. The Object Model is designed to be intuitive and easy to use, enabling for a wide range of use-cases to implemented with ease.

Objects on Sui have following properties:

- Type: Every object has a type, which defines the structure and behaviour of the object. The type is defined in the Move code and is used to create objects of that type. Objects of different types cannot be mixed or used interchangeably, and the type system ensures that objects are used correctly.

- Unique ID: Every object has a unique identifier, which is used to distinguish it from other objects. This identifier is generated when the object is created and is immutable throughout the object's lifetime. The unique ID is used to track and identify objects in the system. This allows for distinguishing between different objects in calls and operations.

- Owner: Every object is associated with an owner, who has control over the object. The owner on Sui can either be an account - then only the account can control, modify and transfer the object. Or shared - then the object is available to everyone on the network. Lastly, the object can be *frozen* - then the object can be read by everyone but cannot be modified or transferred. We discuss ownerhip in more detail in a bit.

- Data: Object encapsulates its data, making it easy to manage and manipulate. The data structure and operations on it are defined by the object's type.

- Version: With elimination of accounts and introduction of objects, the versioning of objects became a necessity. Normally, blockchains implement a *nonce* - a number that is incremented every time the account sends a transaction, and prevents replay attacks. On Sui, the state is represented with objects, and the version of the object is used as a nonce. This way the replay attack is prevented for every object.

- Digest: Every object has a digest, which is a hash of the object's data. The digest is used to verify the integrity of the object's data and ensure that it has not been tampered with. The digest is calculated when the object is created and is updated whenever the object's data changes.

## Ownership: Account

Ownership is a fundamental concept in the Sui Object Model. Every object has an owner, and it 
