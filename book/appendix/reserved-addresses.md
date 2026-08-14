---
description: >-
  Reserved addresses on Sui: standard library (0x1), Sui framework (0x2), system
  objects, and other fixed address assignments.
title: 'Appendix B: Reserved Addresses'
keywords:
  - Move
  - Sui
  - Move tutorial
  - appendix
  - reserved
  - addresses
questions:
  - What addresses are reserved in Move?
  - What is address 0x1?
  - What is the Sui framework address?
answer: >-
  Move reserves specific addresses for system packages: 0x1 for the standard
  library, 0x2 for the Sui framework, and 0x3 for additional Sui system
  packages.
goal:
  description: Reader knows which addresses are reserved in Move and their purpose
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

# Appendix B: Reserved Addresses

Reserved addresses are special addresses that have a specific purpose on Sui. They stay the same
between environments and are used for specific native operations.

- `0x1` - address of the [Standard Library](./../move-basics/standard-library.md) (alias `std`)
- `0x2` - address of the [Sui Framework](./../programmability/sui-framework.md) (alias `sui`)
- `0x5` - address of the `SuiSystem` object
- `0x6` - address of the system [`Clock` object](./../programmability/epoch-and-time.md)
- `0x8` - address of the system [`Random` object](./../programmability/randomness.md)
- `0xc` - address of the system
  [`CoinRegistry` object](./../programmability/balance-and-coin.md#currency-and-the-coin-registry)
- `0xd` - address of the system `DisplayRegistry` object (see
  [Object Display](./../programmability/display.md))
- `0x403` - address of the `DenyList` system object
- `0xacc` - address of the system `AccumulatorRoot` object
