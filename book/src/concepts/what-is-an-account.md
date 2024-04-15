# Account

<!--

- user is an account
    - account is identified by an address
    - account is generated from a private key
    - account can own objects
    - account can send transactions
    - every transaction has a sender
    - sender is identified by an address
    - sui cryptographic agility
    - sui account types
    - supported curves: ed25519, secp256k1, zklogin

 -->

An account is a way to identify a user. An account is generated from a private key, and is
identified by an address. An account can own objects, and can send transactions. Every transaction
has a sender, and the sender is identified by an [address](./address.md).

Sui supports multiple cryptographic algorithms for account generation. The two supported curves are
ed25519, secp256k1, and there is also a special way of generating an account - zklogin. The
cryptographic agility - the unique feature of Sui - allows for flexibility in the account
generation.

<!-- The cryptographic agility allows for flexibility in the account generation -->

## Further Reading

- [Cryptography in Sui](https://blog.sui.io/wallet-cryptography-specifications/) in the
  [Sui Blog](https://blog.sui.io)
- [Keys and Addresses](https://docs.sui.io/concepts/cryptography/transaction-auth/keys-addresses) in
  the [Sui Docs](https://docs.sui.io)
- [Signatures](https://docs.sui.io/concepts/cryptography/transaction-auth/signatures) in the
  [Sui Docs](https://docs.sui.io)
