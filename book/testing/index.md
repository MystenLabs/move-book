---
description: "Testing Move smart contracts on Sui: unit tests, test scenarios, coverage reports, gas profiling, and best practices."
---

# Testing

Move is designed to be [secure by default](./../foreword.md) - its type system and built-in
safeguards prevent entire classes of bugs that plague other smart contract languages, such as
reentrancy, arithmetic overflow, and unauthorized access to assets. But language safety is not the
same as program correctness. A type system can ensure your code won't violate Move's rules, but it
cannot verify that your transfer logic sends funds to the right recipient, that your auction closes
at the right time, or that your access control matches your intended policy. These are properties of
your design, not the language - and they can only be verified through testing.

The stakes of getting it wrong are uniquely high in on-chain programming:

- **Financial risk**: Bugs in asset-handling code can lead to permanent loss of funds. A single
  overlooked edge case in transfer logic or access control can be exploited, resulting in
  irreversible damage.
- **Immutability**: Once deployed, smart contract code cannot always be easily modified, and even
  with the ability to upgrade, the previous version of the code will always be available. Thorough
  testing before deployment is your primary defense against vulnerabilities.
- **Adversarial environment**: Published Move packages are effectively open-source - anyone can read
  and decompile on-chain bytecode. This means malicious actors can study your code in detail,
  searching for exploitable flaws. Your code must handle not just expected inputs, but intentional
  attempts to break it.
- **Composability risks**: Move modules interact with other on-chain code. Testing must verify that
  your code behaves correctly not only in isolation but also when composed with other packages.

Given these stakes, comprehensive testing is not optional - it is essential for any Move application
that handles assets or implements any business logic.
