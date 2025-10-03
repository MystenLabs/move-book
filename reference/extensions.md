---
title: 'Module Extensions | Reference'
description: ''
---

# Module Extensions

**Module Extensions** let a package add new declarations to an existing module **as if** they were
defined inside that module. Extensions are opt-in via a mode attribute and never modify or remove
existing items.

## Extension Syntax

Extension are defined by adding the `extend` keyword before the `module` keyword:

```move
#[mode(name1, name2, ...)]      // or #[test_only]
extend module <address>::<identifier> {
    (<use> | <type> | <function> | <constant>)*
}
```

Extensions are allowed for single-file module forms:

```move
#[mode(test)]
extend module p<address>::<identifier>;

(<use> | <type> | <function> | <constant>)*
```

In both cases:

* The extension must define a mode attribute.
* `<address>::<identifier>` is the package and module name.
* The module elements are as in a standard [module](modules).
* The extension block is compiled into the target module under the enabled modes.
* `<address>::<identifier>` must resolve to an existing module in the current build.

## Applying Extensions

Let `M` be a module in the current build. Let `E1, E2, ... En` be all extensions targeting `M` such
that:

- `Ei` is defined in the root package of the current build (others are ignored).
- `Ei` targets `M`
- `Ei` has an active mode attribute.

During expansion, the effective contents of `M` are transformed into:

```
module M {
    ... original contents of M ...
    ... contents of E1 ...
    ... contents of E2 ...
    ...
    ... contents of En ...
}
```

Name resolution, visibility, edition rules, type checking, etc., are applied to the resultant
module as a whole. This means each declaration in an extension is treated as if it were written
directly in the target module, and subject to the same visibility, edition features, duplicate
definition errors, name conflicts, etc.

This means that extensions may not modify or override existing declarations, and may not shadow
existing `use` definitions, etc. New use definitions may be added, but their compilation is still
subject to decidable dependency ordering, as described in the [`use`](uses) section.

> **Tip**: Extension code is subject of the same edition features as the target module. If the
> target module is in an older edition, the extension code must also be compatible with that
> edition.
