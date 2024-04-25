# Foreword

This book is dedicated to Move, a smart contract language that captures the essence of safe
programming with digital assets. Move is designed around the following values:

1. **Secure by default:** Insecure languages are a serious barrier both to accessible smart contract
   development and to mainstream adoption of digital assets. The first duty of a smart contract
   language is to prevent as many potential safety issues as possible (e.g. re-entrancy, missing
   access control checks, arithmetic overflow, ...) by construction. Any changes to Move should
   preserve or enhance its existing security guarantees.

2. **Expressive by nature:** Move must enable programmers to write any smart contract they can
   imagine. But we care as much about the way it _feels_ to write Move as we do about what Move
   allows you to do - the language should be rich enough that the features needed for a task are
   available, and minimal enough that the choice is obvious. The Move toolchain should be a
   productivity enhancer and a thought partner.

3. **Intuitive for all:** Smart contracts are only one part of a useful application. Move should
   understand the broader context of its usage and design with both the smart contract developer and
   the application developer in mind. It should be easy for developers to learn how to read
   Move-managed state, build Move powered transactions, and write new Move code.

The core technical elements of Move are:

- Safe, familiar, and flexible abstractions for digital assets via programmable _objects_.
- A rich _ability_ system (inspired by linear types) that gives programmers extreme control of how
  values are created, destroyed, stored, copied, and transferred.
- A _module_ system with strong encapsulation features to enable code reuse while maintaining this
  control.
- _Dynamic fields_ for creating hierarchical relationships between objects.
- _Programmable transaction blocks_ (PTBs) to enable atomic client-side composition of Move-powered
  APIs.

Move was born in 2018 as part of Facebook's Libra project. It was publicly revealed in 2019, the
first Move-powered network launched in 2020. As of April 2024, there are numerous Move-powered
chains in production with several more in the works. Move is an embedded language with a
platform-agnostic core, which means it takes on a slightly different personality in each chain that
uses it.

Creating a new programming language and bootstrapping a community around it is an ambitious, long
term project. A language has to be an order of magnitude better than alternatives in relevant ways
to have a chance, but even then the quality of the community matters more than the technical
fundamentals. Move is a young language, but it's off to a good start in terms of both
differentiation and community. A small, but fanatical group of smart contract programmers and core
contributors united by the Move values are pushing the boundaries of what smart contracts can do,
the applications they can enable, and who can (safely) write them. If that inspires you, read on!

— Sam Blackshear, creator of Move
