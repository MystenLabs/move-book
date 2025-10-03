# Extensions

Sometimes tests (or local tools) need to reach into a module’s internals without changing the module
itself. Extensions let you add code that behaves as if it were written inside an existing module,
while keeping those additions opt-in (for example, only when running tests).

Extensions are ordinary Move definitions that live alongside your code. They compile with the same
visibility as the target module and can call its private functions or destructure its private
types, all without making those details public to the world.

## Example 1: Extended testing without public internals

Suppose you have a module with a private type:

```move
// balance.move
module my::wallet {
    struct Balance { amount: u64 } // private
    public fun new(amount: u64): Balance { Balance { amount } }
}
```

While you could define your tests in this module to expose `Balance`'s internals, that may cause
code organization pains, forcing your tests and test definitions to live in the same file. As an
alternative, you can add test-only helpers in an extension (e.g., `balance_tests.move`):

```move
// balance_tests.move
#[test_only]
extend module my::wallet {
    // Compiles as if it is written inside `my::wallet`.
    fun destroy_for_test(b: Balance): u64 {
        let Balance { amount } = b; // private destructuring is allowed
        amount
    }

    #[test]
    fun can_peek_amount() {
        let b = new(42);
        assert!(destroy_for_test(b) == 42, 0);
    }
}
```

Similar to `#[test_only]` function annotations, this keeps your tests close to the code they
exercise, but it also allows you to keep your production code clean.

> **Note:** Extensions are not limited to `#[test_only]` code, but each extension must be annotated
> with a mode, as described in [Modes](modes). All other mode rules apply as usual.

## Example 2: Extensions to downstream packages

Imagine you have an off-the-shelf module that you want to test in your package, but it lacks some
internal accessors or testing operations that would allow you to write full tests over it. As a toy
example, consider a simple counter module defined as a library:

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

## See also

* [Testing basics](../move-basics/testing) in the Move Book.
* [Extensions](/reference/extensions) in the Move Reference.
