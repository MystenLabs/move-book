---
description: "Learn Move language fundamentals: types, modules, functions, structs, abilities, generics, and control flow for Sui smart contracts."
---

# Move Basics

This chapter covers the foundations of the Move language: the syntax, the type system, and the
concepts that every Move program is built from. It focuses on the language itself and mostly sets
the blockchain aside - everything here applies to any Move program, and the features specific to
storage and Sui are covered right after, starting with the [Object Model](./../object/) chapter.

The sections build on one another and are meant to be read in order:

- **How code is organized:** [modules](./module), [comments](./comments),
  [primitive types](./primitive-types), the [address type](./address),
  [expressions](./expression), and [functions](./function).
- **Defining custom types:** [structs](./struct), and the
  [ability system](./abilities-introduction) that controls what values of a type can do -
  starting with [drop](./drop-ability).
- **Reusing existing code:** [imports](./importing-modules) and the
  [Standard Library](./standard-library) with its core types - [vector](./vector),
  [Option](./option), and [String](./string).
- **Writing logic:** [control flow](./control-flow), [enums with pattern
  matching](./enum-and-match), [struct methods](./struct-methods), and
  [visibility modifiers](./visibility).
- **The core of Move's safety story:** [ownership and scope](./ownership-and-scope), the
  [copy ability](./copy-ability), [constants](./constants) and
  [aborting execution](./assert-and-abort), and [references](./references).
- **Abstraction tools:** [generics](./generics), [macro functions](./macros),
  [internal permits](./internal-permit), [type reflection](./type-reflection), and, finally,
  [testing](./testing).

Every code sample in this chapter comes from a compiling, tested package. Most samples are
excerpts placed inside test functions, so you can copy any of them into the package created in the
[Hello World](./../your-first-move/hello-world) chapter and run them with `sui move test`.
