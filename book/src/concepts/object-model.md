# Object Model

<!--

- now objects?
    - Sui does not have global storage
    - storage is split into a pool of objects
    - objects are identified by a 32-byte value
    - objects are stored in the blockchain storage
    - focus on infrastructure properties of objects

 -->

Sui does not have global storage. Instead, storage is split into a pool of objects. Some of the objects are owned by accounts and available only to them, and some are *shared* and can be accessed by anyone on the network. There's also a special kind of *shared immutable* objects, also called *frozen*, which can't be modified, and act as public chain-wide constants.

Each object has a unique 32-byte identifier - UID, it is used to access and reference the object.

<!-- TODO: better intro -->

Sui object consists of:

- UID - 32-byte unique identifier (address)
- Type - Move type with the `key` ability
- Owner - can be `shared`, `account_address`, `object_owner` or `immutable`
- Digest - hash of the object's content
- Version - acts as a nonce
- Content - the actual data represented as BCS

<!--

    - UID is also an address
    - Object has an owner field which can be w`shared`, `account_address`, `object_owner` or `immutable`.
    - Object has a version which acts as a nonce - hence Sui does not require an account nonce
    - Object has a Move type with the `key` ability
    - Object has a digest which is a hash of the object's content
    - Object has a content field which is the actual data represented as BCS

    - Reentrancy protection is built into the object model, and account can execute txs in parallel
      if they don't modify the same object

 -->
