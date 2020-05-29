# Ownership

Move VM implements Rust-like ownership system. And the best description of it is in [Rust Book](https://doc.rust-lang.org/stable/book/ch04-01-what-is-ownership.html). <!-- There's one main difference between two languages: Move does not have *heap*, and all of its variables are *put on stack*. -->

I recommend you reading ownership chapter in Rust Book even though Rust syntax differs and some of the examples may not be easy to understand. In this chapter we will go through main points anyway.

> Each variable has only one owner scope. When owner scope ends - owned variables are dropped.

We've already seen this behavior in [expressions chapter](/chapters/expression-and-scope.md). Remember that variable lives as long as its scope? Now is the perfect time to get under the hood and learn why it happens.

Owner is a scope which *owns* a variable. Variable either can be defined in this scope (e.g. with keyword `let` in script) or be passed into scope as argument. Since the only scope in Move is function's - there are no other ways to put variable into scope.

Each variable has only one owner, which means that when variable is passed into function as argument, this function becomes the *new owner*, and variable no longer *owned* by the first function. Or you may say that function *takes ownership* of variable.

```Move
script {
    use {{sender}}::M;

    fun main() {
        // Module::T is a struct
        let a : Module::T = Module::create(10);

        // here variable `a` leaves scope of `main` function
        // and is being put into new scope of `M::value` function
        M::value(a);

        // variable a no longer exists in this scope
        // this code won't compile
        M::value(a);
    }
}
```

Let's look at what happens inside `value()` when we pass our value into it:

```Move
module M {
    // create_fun skipped
    struct T { value: u8 }

    public fun create(value: u8): T {
        T { value }
    }

    // variable t of type M::T passed
    // `value()` function takes ownership
    public fun value(t: T): u8 {
        // we can use t as variable
        t.value
    }
    // function scope ends, t dropped, only u8 result returned
    // t no longer exists
}
```

Of course, quick workaround is to return a tuple with original variable and additional results (return value would have been `(T, u8)`), but Move has a better solution for that.

## Move and Copy

First, you need to understand how Move VM works, and what happens when you pass your value into a function. There are two bytecode instructions in VM: *MoveLoc* and *CopyLoc* - both of them can be manually used with keywords `move` and `copy` respectively.

When variable is being passed into another function - it's being *moved* and *MoveLoc* OpCode is used. Let's see how our code would look if we've used keyword `move`:

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        M::value(move a); // variable a is moved

        // local a is dropped
    }
}
```

This is a valid Move code, however, knowing that value will still be moved you don't need to explicitly *move* it. Now when it's clear we can get to *copy*.

### Keyword `copy`

If you need to pass a value to the function (where it's being moved) and save a copy of your variable, you can use keyword `copy`.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        // we use keyword copy to clone structure
        // can be used as `let a_copy = copy a`
        M::value(copy a);
        M::value(a); // won't fail, a is still here
    }
}
```

In this example we've passed *copy* of variable (hence value) `a` into first call of method `value` and saved `a` in local scope to use it again in second call.

By copying value we've duplicated it and increased memory size of our program, so it can be used - but when you copy huge data it may become pricey in terms of memory. Remember - in blockchains every byte counts and affects price of execution, so using `copy` all the time may cost you a lot.

Now you are ready to learn about references which help you avoid unnecessary copying and literally save some money.

## References

Many programming languages have implementation of references ([see Wikipedia](https://en.wikipedia.org/wiki/Reference_(computer_science))). *Reference* is a link to variable (usually to a section in memory) which you can pass into other parts of program instead of *moving* the value.

> References (marked with &) allow you to *refer* to value without taking *ownership* of it

Let's modify our example and see how references can be used.

```Move
module M {
    struct T { value: u8 }
    // ...
    // ...
    // instead of passing a value, we'll pass a reference
    public fun value(t: &T): u8 {
        t.value
    }
}
````

We added ampersand `&` to argument type T - and by doing that we've changed argument type from `T` to *reference to T* or simply `&T`.

> Move supports two types of references: *immutable* - defined with `&` (e.g. `&T`) and *mutable* - `&mut` (e.g. `&mut T`).

Immutable references allow reading value without changing it. Mutable - the opposite - give ability to read and change the value.

```Move
module M {
    struct T { value: u8 }

    // returned value is of non-reference type
    public fun create(value: u8): T {
        T { value }
    }

    // immutable references allow reading
    public fun value(t: &T): u8 {
        t.value
    }

    // mutable references allow reading and changing the value
    public fun change(t: &mut T, value: u8) {
        t.value = value;
    }
}
```

Now let's see how to use our upgraded module M.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let t = M::create(10);

        // create a reference directly
        M::change(&mut t, 20);

        // or write reference to a variable
        let mut_ref_t = &mut t;

        M::change(mut_ref_t, 100);

        // same with immutable ref
        let value = M::value(&t);

        // this method also takes only references
        // printed value will be 100
        0x0::Debug::print<u8>(&value);
    }
}
```

###  Borrow checking

Move controls the way you use references and helps you prevent unexpected bullet in your foot. To understand this let's look at example. I'll give you module and script and then will comment on what's going on and why.

```Move
module Borrow {

    struct B { value: u64 }
    struct A { b: B }

    // create A with inner B
    public fun create(value: u64): A {
        A { b: B { c: C { value } } }
    }

    // give a mutable reference to inner B
    public fun ref_from_mut_a(a: &mut A): &mut B {
        &mut a.b
    }

    // change B
    public fun change_b(b: &mut B, value: u64) {
        b.value = value;
    }
}
```

```Move
script {
    use {{sender}}::Borrow;

    fun main() {
        // create a struct A { b: B { value: u64 } }
        let a = Borrow::create(0);

        // get mutable reference to B from mut A
        let mut_a = &mut a;
        let mut_b = Borrow::ref_from_mut_a(mut_a);

        // change B
        Borrow::change_b(mut_b, 100000);

        // get another mutable reference from A
        let _ = Borrow::ref_from_mut_a(mut_a);
    }
}
```

This code compiles and runs without errors. First, what happens here: we use mutable reference to `A` to get mutable reference to its inner struct `B`. Then we change `B`, hence change `A`. Then operation can be repeated.

But what if we changed swapped two last expressions and first tried to create new mutable reference to `A` while mutable reference to `B` is still alive?

```Move
let mut_a = &mut a;
let mut_b = Borrow::ref_from_mut_a(mut_a);

let _ = Borrow::ref_from_mut_a(mut_a);

Borrow::change_b(mut_b, 100000);
```

Error will be:

```Move
    ┌── /scripts/script.move:10:17 ───
    │
 10 │         let _ = Borrow::ref_from_mut_a(mut_a);
    │                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invalid usage of reference as function argument. Cannot transfer a mutable reference that is being borrowed
    ·
  8 │         let mut_b = Borrow::ref_from_mut_a(mut_a);
    │                     ----------------------------- It is still being mutably borrowed by this reference
    │
```

This code won't compile. Why? Because `&mut A` is *being borrowed* by `&mut B`. If we could change A while still having mutable reference to its contents, we'd get into odd situation where A can be changed but its contents are still here. What would `mut_b` reference to if it no longer would be there.

We come to few conclusions:

1. You can create reference from reference, so that original reference will *be borrowed* by new one. Mutable and immutable from mutable and only immutable from immutable.
2. When reference *is borrowed* it cannot be *moved* because other values depend on it.
3. Move compiler has *borrow checking* in it and builds a *borrow graph* to track references. This is also a reason why Move is so safe to use in blockchains.


### Deferencing

References can be dereferenced to get linked value - to do it use asterisk `*`.

> When dereferencing you're actually making a *copy* - avoid

```Move
module M {
    struct T {}

    // value t here is of reference type
    public fun deref(t: &T): T {
        *t
    }
}
```

> Dereference operator does not move original value into current scope. It creates a *copy* of this value instead.

### Referencing primitive types

Primitive types (due to their simplicity) do not need to be passed as references and *copy* operation is done instead. Even if you pass them into function *by value* they will remain in current scope. You can intentionally use `move` keyword, but since primitives are very small in size copying them may even be cheaper than passing them by reference or even moving.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a = 10;
        M::do_smth(a);
        let _ = a;
    }
}
```

This script will compile even though we didn't pass `a` as a reference. Adding `copy` is unnecessary - it's already put there by VM.


<!--

Notes:

 - blocks are simply syntax sugar to simplify scripting, they don't set restrictions to using


-->

<!-- unless explicit `move` keyword used -->

<!--

To note here:

[x] references
[x] mutable
[x] only one mutable
[x] immutable
[x] reference as fun arg
[x] access by ref, get value
[ ] why primitives can be passed freely

[ ] kw copy, kw move
[ ] 1 mutable - example!

In generics:

resource
copyable

-->


