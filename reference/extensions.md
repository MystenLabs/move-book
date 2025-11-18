---
title: 'Module Extensions | Reference'
description: ''
---

# Module Extensions

**Module Extensions** let a package add new declarations to an existing module **as if** they were
defined inside that module. Extensions are opt-in via a mode attribute and never modify or remove
existing items.

### Example

Imagine you have an off-the-shelf module that you want to test in your package, but it
lacks some internal accessors or testing operations that would allow you to write full tests over
it. As a toy example, consider a simple counter module defined as a library:

```move
module counter::counter {
    public struct Counter has drop { value: u64 }

    public fun new(): Counter { Counter { value: 0 } }

    public fun incr(mut c: Counter): Counter {
        c.value = c.value + 1;
        c
    }

    public fun destroy(c: Counter): u64 {
        let Counter { value } = c;
        value
    }
}
```

You might use this module in your own package to implement a step counter:

```move
module app::step_counter {
    use counter::counter::{Counter, new, incr, destroy};
    enum Step { Once, Many(u64) }

    public fun step(c: Counter, s: Step): Counter {
        match s {
            Step::Once => incr(c),
            Step::Many(n) => {
                let mut c = c;
                let mut i = 0;
                while (i < n) {
                    c = incr(c);
                    i = i + 1;
                }
                c
            }
        }
    }
}
```

Suppose you wanted to write additional tests for this counter behavior, including ensuring
invariants and the ability to peek at the current value without consuming the counter. Extensions
allow you to add this behavior as test definitions in your own package without forking and updating
the downstream dependency.

```move
#[test_only]
extend module counter::counter {
    /// Peek at the current value without consuming the counter.
    public fun peek(c: &Counter): u64 { c.value }
}

#[test_only]
extend module app::step_counter {
    use counter::counter::{Counter, new, incr, peek};

    // Local test helper to keep assertions tidy.
    fun expect_value(c: &Counter, want: u64) { assert!(c.peek() == want, 0); }

    /// Equivalence: Once == Many(1).
    #[test]
    fun once_equals_many1() {
        let c1a = step(new(), Step::Once);
        let c1b = step(new(), Step::Many(1));
        expect_value(&c1a, 1);
        expect_value(&c1b, 1);
    }
}
```

In this usage, you extend both the `counter::counter` module (to add helpers and tests) and the
`app::step_counter` module (to add tests for the step logic). All of this code lives in your
package, and it only affects test builds. The publishable code remains unchanged.


> **Note**: Extensions can only add new items; they cannot modify or remove existing items. In >
> addition, only extensions defined in the root package are applied (extensions in dependencies are
> not).

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
