# Testing

Testing is crucial in any software project, but it takes on special importance in Move. Because Move
is designed for programming digital assets and financial applications, bugs can have severe and
irreversible consequences. Unlike traditional software where issues can be patched quickly, smart
contracts manage real value and are often immutable or difficult to upgrade after deployment. This
creates unique challenges:

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
