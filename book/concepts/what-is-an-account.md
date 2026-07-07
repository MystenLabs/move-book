---
description: "Understand Sui accounts: how they are generated from private keys, identified by addresses, and support multiple crypto schemes."
---

# Account

An account is a way to identify a user. An account is generated from a private key, and is
identified by an address. An account can own objects, and can send transactions. Every transaction
has a sender, and the sender is identified by an [address](./address).

An account does not need to be created or registered anywhere: it exists as soon as a keypair is
generated, and any valid address can receive objects without prior setup. There is no onchain
record of "all accounts" - an address with no objects and no transaction history is
indistinguishable from one that was never used.

Sui supports multiple signature schemes for accounts: ed25519, ECDSA (over the secp256k1 and
secp256r1 curves), passkeys (device authenticators such as Face ID, Touch ID, or a hardware
security key, based on the WebAuthn standard), multisig (an account controlled by a combination of
keys), and zkLogin, which derives an account from a Web2 login. This _cryptographic agility_ gives
Sui unusual flexibility in how accounts are created and controlled.

## Further Reading

- [Cryptography in Sui](https://blog.sui.io/wallet-cryptography-specifications/) in the
  [Sui Blog](https://blog.sui.io)
- [Keys and Addresses](https://docs.sui.io/guides/developer/transactions/transaction-auth/auth-overview) in
  the [Sui Docs](https://docs.sui.io)
- [Signatures](https://docs.sui.io/guides/developer/cryptography/signing) in the
  [Sui Docs](https://docs.sui.io)
- [Passkey](https://docs.sui.io/develop/cryptography/passkeys) in the [Sui Docs](https://docs.sui.io)
