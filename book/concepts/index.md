---
description: >-
  Core Sui and Move concepts: packages, accounts, transactions, addresses, and
  how data is stored on the Sui blockchain.
title: Concepts
keywords:
  - Move
  - Sui
  - Move tutorial
  - concepts
questions:
  - What are the core concepts in Move?
  - How are Move packages structured?
  - What is Move.toml?
answer: >-
  Core Move concepts include packages (units of code organization), the
  Move.toml manifest, named addresses, and the account/address model on Sui.
goal:
  description: 'Reader understands packages, manifests, addresses, and accounts in Move'
  requires:
    - has_frontmatter:
        - title
        - description
        - keywords
      label: Has required frontmatter fields
    - min_words: 30
      label: Needs content depth
    - has_questions: true
      label: Needs questions for AI search visibility
    - has_answer: true
      label: Needs answer summary for AI citation
---

# Concepts

In this chapter you will learn about the basic concepts of Sui and Move: what a package is and how
to interact with it, what an account and a transaction are, and how data is stored on Sui. While
this chapter is not a complete reference - refer to the [Sui Documentation](https://docs.sui.io)
for that - it will give you a good understanding of the concepts required to write Move programs
on Sui.
