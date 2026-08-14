---
title: Bool | Reference
description: >-
  Move bool type reference: true and false literals, logical operators (and, or,
  not), and boolean expression semantics.
keywords:
  - Move
  - Sui
  - Move reference
  - bool
  - reference
questions:
  - How does Bool work in Move?
  - What is the syntax for Bool in Move?
  - What is Literals in Move?
  - What is Operations in Move?
answer: >-
  Move bool type reference: true and false literals, logical operators (and, or,
  not), and boolean expression semantics.
goal:
  description: >-
    Reader understands move bool type reference: true and false literals,
    logical operators (and, or, not), and boolean expression semantics
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

# Bool

`bool` is Move's primitive type for boolean `true` and `false` values.

## Literals

Literals for `bool` are either `true` or `false`.

## Operations

### Logical

`bool` supports three logical operations:

| Syntax                    | Description                  | Equivalent Expression                                               |
| ------------------------- | ---------------------------- | ------------------------------------------------------------------- |
| `&&`                      | short-circuiting logical and | `p && q` is equivalent to `if (p) q else false`                     |
| <code>&vert;&vert;</code> | short-circuiting logical or  | <code>p &vert;&vert; q</code> is equivalent to `if (p) true else q` |
| `!`                       | logical negation             | `!p` is equivalent to `if (p) false else true`                      |

### Control Flow

`bool` values are used in several of Move's control-flow constructs:

- [`if (bool) { ... }`](./../control-flow/conditionals)
- [`while (bool) { .. }`](./../control-flow/loops)
- [`assert!(bool, u64)`](./../abort-and-assert)

## Ownership

As with the other scalar values built-in to the language, boolean values are implicitly copyable,
meaning they can be copied without an explicit instruction such as
[`copy`](.././variables#move-and-copy).
