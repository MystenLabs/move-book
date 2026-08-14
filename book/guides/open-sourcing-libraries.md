---
description: >-
  Guide to open sourcing Move libraries: naming conventions, documentation,
  testing, and publishing reusable packages for Sui.
title: Open Sourcing Libraries
keywords:
  - Move
  - Sui
  - Move tutorial
  - open
  - sourcing
  - libraries
questions:
  - What is Open Sourcing Libraries in Move?
  - How do I use Open Sourcing Libraries in Move?
  - What is README in Move?
  - What is Named Addresses in Move?
answer: >-
  Guide to open sourcing Move libraries: naming conventions, documentation,
  testing, and publishing reusable packages for Sui.
goal:
  description: >-
    Reader understands guide to open sourcing Move libraries: naming
    conventions, documentation, testing, and publishing reusable packages for
    Sui
  requires:
    - has_frontmatter:
        - title
        - description
        - keywords
      label: Has required frontmatter fields
    - min_words: 50
      label: Needs content depth
    - has_questions: true
      label: Needs questions for AI search visibility
    - has_answer: true
      label: Needs answer summary for AI citation
---

# Open Sourcing Libraries

Open sourcing libraries is a great way to contribute to the Move ecosystem. This guide will help you
understand how to open source a library, how to write tests, and how to document your library.

## README

TODO: readme

## Named Addresses

TODO: named address

## Generating Documentation

TODO: docgen

## Adding Examples

When publishing a package that is intended to be used (an NFT protocol or a library), it is
important to showcase how this package can be used. This is where examples come in handy. There's no
special functionality for examples in Move, however, there are some conventions that are used to
mark examples. First of all, only sources are included into the package bytecode, so any code placed
in a different directory will not be included, but will be tested!

This is why placing examples into a separate `examples/` directory is a good idea.

```bash
sources/
    protocol.move
    library.move
tests/
    protocol_test.move
examples/
    my_example.move
Move.toml
```

## Tags and Releases (Git)

TODO: tags and releases

## Tricks to allow compatibility with closed source

TODO: compatibility via empty functions with signatures
