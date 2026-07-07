---
description: "Ownership and scope in Move: how values are moved between scopes, why they cannot be copied or lost, and how the compiler enforces it."
---

# Ownership and Scope

Ownership is the central concept of Move - it is even where the language got its name. Move is
designed for digital assets, and its main promise is that a value cannot be duplicated and cannot be
accidentally lost. The mechanism behind this promise is ownership, and it is enforced by the
compiler: a program that breaks the rules does not compile.

The rules are:

- Every value has exactly one owner - the scope in which it is defined.
- When a value is passed to a function, assigned to a new variable, or returned, it is _moved_ to a
  new owner, and the previous owner can no longer use it.
- When a scope ends, every value it still owns must be either discardable or already moved out.

The rest of this section walks through these rules one by one. If some of them seem strict - that is
the point: the restrictions are what make it safe to treat a value in Move as an asset.

## Variable Scope

A scope is the range of code in which a value is valid. A variable defined in a function is owned by
that function's scope: it comes into scope at the declaration, and goes out of scope when the
function ends.

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=scope

```

Nothing surprising so far - this is how local variables behave in most languages. Ownership becomes
interesting when a value needs to leave its scope.

## Moving a Value

To demonstrate the rules, we will use a small module with a `Coin` type and two functions - one that
creates a coin and one that destroys it:

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=coin

```

The `Coin` struct has no [abilities](./abilities-introduction), so the compiler places the strictest
constraints on its values: they cannot be copied and cannot be discarded. A value like this can only
change hands - which is exactly what we want from an asset.

When a value is passed to a function, it is _moved_ into the function's scope. The function becomes
the new owner, and the caller loses access to the value. This is called _move semantics_.

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=move_to_function

```

Let's see what happens if we break the rule and try to use `coin` after it was moved:

```move
#[test]
fun test_move_semantics() {
    let coin = mint(100);
    spend(coin); // ownership of the value moves into `spend`
    spend(coin); // ERROR! `coin` was already moved
}
```

The code above will not compile, and the compiler will point at the exact spot where the value was
moved:

```text
error[E06002]: use of unassigned variable
   ┌─ sources/ownership.move:12:11
   │
11 │     spend(coin);
   │           ----
   │           │
   │           The value of 'coin' was previously moved here.
   │           Suggestion: use 'copy coin' to avoid the move.
12 │     spend(coin);
   │           ^^^^ Invalid usage of previously moved variable 'coin'.
```

The compiler suggests using `copy coin`, but that only works for values that can be copied - and
`Coin` cannot. There is no way to spend the same coin twice, and this guarantee is checked before
the code ever runs.

Assigning a value to a new variable is also a move. The value itself is not changed or copied - only
its owner is:

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=move_to_variable

```

## Returning a Value

Moves also work in the opposite direction: a function can return a value, moving it to the caller's
scope. This is how the `mint` function from our example transfers ownership of a newly created coin
to whoever called it. Combined with passing by value, this gives a full picture of a value's
lifetime: `mint` creates the coin and hands it to the test function, which then hands it over to
`spend`, which destroys it. At every point in the program, the coin has exactly one owner.

## Every Value Must Be Used

What if a value is never passed on? Let's mint a coin and simply let the function end:

```move
#[test]
fun test_lose_a_coin() {
    let coin = mint(100);
} // ERROR! `coin` still contains a value which cannot be discarded
```

The third rule kicks in: a scope cannot end while it still owns a value that is not discardable.

```text
error[E06001]: unused value without 'drop'
  ┌─ sources/ownership.move:7:35
  │
4 │ public struct Coin { value: u64 }
  │               ---- To satisfy the constraint, the 'drop' ability would need to be added here
  ·
7 │     let coin = mint(100);
  │         ----  ↑ The local variable 'coin' still contains a value.
  │                The value does not have the 'drop' ability and must
  │                be consumed before the function returns
```

Whether a value can be discarded is controlled by the `drop` ability, which we covered in the
[Ability: Drop](./drop-ability) section. For a type like `Coin`, the absence of `drop` means a coin
cannot be forgotten in a local variable and silently vanish - the code holding it is forced to do
something with it.

## Copyable Types

Some values do not need this level of protection. All primitive types - integers, `bool`, `address`
- have the `copy` ability, and instead of being moved, they are copied when assigned or passed to a
function:

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=copy_types

```

Copying is implicit for primitive types because they are small and cheap to duplicate. Custom types
can also opt into this behavior by adding the `copy` ability, which we cover in the
[Ability: Copy](./copy-ability) section.

If needed, a copyable value can still be moved explicitly with the `move` keyword:

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=explicit_move

```

## Scopes and Blocks

Besides the function's main scope, every block forms its own scope. Variables declared inside a
block are owned by it and go out of scope when the block ends. Code inside a block can access the
variables of the enclosing scope, but not the other way around:

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=blocks

```

A block is an expression, and its resulting value is moved out to the enclosing scope - the same
move semantics as returning a value from a function:

```move file=packages/samples/sources/move-basics/ownership-and-scope.move anchor=block_return

```

## Next Steps

So far, the only way to let a function use a value was to give the ownership away. Doing that for
every operation would be impractical - reading a field should not require handing over the whole
value. Move solves this with _references_, which allow a function to borrow a value without taking
ownership. We cover them in the [References](./references) section.

## Further Reading

- [Local Variables and Scopes](./../../reference/variables) in the Move Reference.
