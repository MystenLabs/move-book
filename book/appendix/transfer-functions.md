---
description: >-
  Quick reference for Sui transfer functions: transfer, share, freeze, receive,
  and their public variants with permissions and end states.
title: 'Appendix C: Transfer Functions'
keywords:
  - Move
  - Sui
  - Move tutorial
  - appendix
  - transfer
  - functions
questions:
  - 'What is Appendix C: Transfer Functions in Move?'
  - 'How do I use Appendix C: Transfer Functions in Move?'
  - 'How does Appendix C: Transfer Functions work on Sui?'
answer: >-
  Quick reference for Sui transfer functions: transfer, share, freeze, receive,
  and their public variants with permissions and end states.
goal:
  description: >-
    Reader understands and can apply Appendix C: Transfer Functions in Move
    programs
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

# Appendix C: Transfer Functions

## Transfer Functions Comparison

| Function                  | Public Function         | End State     | Permissions               |
| ------------------------- | ----------------------- | ------------- | ------------------------- |
| [`transfer`][transfer]    | `public_transfer`       | Address Owned | Full                      |
| [`share_object`][share]   | `public_share_object`   | Shared        | Ref, Mut Ref, Delete      |
| [`freeze_object`][freeze] | `public_freeze_object`  | Frozen        | Ref                       |
| [`party_transfer`][party] | `public_party_transfer` | Party         | [See Party table](#party) |

## States Comparison

| State         | Description                                               |
| ------------- | --------------------------------------------------------- |
| Address Owned | Object can be accessed fully by an address (or an object) |
| Shared        | Object can be referenced and deleted by anyone            |
| Frozen        | Object can be accessed via immutable reference            |
| Party         | Depends on the Party settings ([see Party table](#party)) |

## Party

| Function       | Description                                  |
| -------------- | -------------------------------------------- |
| `single_owner` | Object has same permissions as Address Owned |

[transfer]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_transfer
[share]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_share_object
[freeze]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_freeze_object
[party]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_party_transfer
