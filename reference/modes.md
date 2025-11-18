---
title: 'Compilation Modes | Reference'
description: ''
---

# Compilation Modes

A mode is a named, compile-time switch that controls which declarations are included in a build.

- `#[mode(name1, name2, ...)]` filters declarations by enabled mode names.
- `#[test_only] ≡ #[mode(test)]`.
- Unannotated declarations are always included.
- Annotated declarations are included if and only if any listed name is enabled.
- Enabling any mode (including test) mean the build is not publishable.
- Modes affect compile-time inclusion only; other than publishability, they are erased at the
  bytecode level.

## Mode Basics

Modes are expressed with the attributes:

```move
#[mode(name1, name2, ...)]

#[test_only] // (shorthand for #[mode(test)])
```

Code compiled with any mode enabled (including test) is not publishable.

This section defines the syntax, inclusion rules, scope, and tool interactions for modes. (For an
introductory tutorial with examples, see the guide page.)

### Mode Annotations

The `#[mode(...)]` may be placed on modules and module members (functions, structs, constants,
etc.).


```move
#[mode(name1, name2, ...)]
module <addr_opt>::<ident> { ... }

module <addr_opt>::<ident> {
    #[mode(name1, name2, ...)]
    <decl>
}
```
> **Note**: `#[test_only]` is exactly equivalent to `#[mode(test)]`.

## Mode Names

Each name is a nonempty identifier. Mode names are compared case-sensitively.

## Inclusion model

Let `M` be the set of enabled modes for a build. Let `S(m)` be the set of modes listed on
declaration `m`, where `#[test_only]` contributes `{test}`, and unannotated declarations have `S(x)
= ∅`. A declaration x is included in the compilation unit if and only if one of the following is
true:

* `S(x) = ∅` (unannotated)
* `S(x) ∩ M ≠ ∅:` (annotation included)

That is: unannotated declarations are always included; annotated declarations are included if and
only if at least one of their listed names is enabled in the build, and otherwise they are excluded.

### Module scope

If a module is excluded, all of its members are excluded implicitly. If a module is included, an
annotated member may still be excluded if its own `S(m)` does not intersect `M`.

### Multiple modes on one attribute

The list in `#[mode(a, b, c)]` is disjunctive (logical OR): inclusion occurs if any listed name
matches.

## Name resolution & duplicates

Modes are a compile-time filter only. They do not introduce runtime conditionals and have no
representation in bytecode. All verification is performed on the included subset of the source.

Standard name resolution rules apply when duplicates are present. That means two modes may not
enable different modules or members with the same name in the same build. Similarly, a
mode-annotated definition may not override an unannotated declaration with the same name.

To provide mode-specific alternatives, place them in separate modules gated by modes, or use
distinct names and select them in tests or drivers.

## Usage Tooling & flags

For building and testing, `move build --mode <name>` adds `<name>` to `M`. Multiple modes may be
enabled by passing `--mode` repeatedly; `M ` is the union of all names passed, e.g., `move build
--mode test --mode debug`. This will enable all modules and members annotated with either
`#[mode(test)]` or `#[mode(debug)]`. Note that `move test` implicitly supplies `--mode test`.

## Publishability

Any build that enables at least one mode (including test) produces non-publishable outputs. To
create publishable artifacts, no modes may be enabled.
