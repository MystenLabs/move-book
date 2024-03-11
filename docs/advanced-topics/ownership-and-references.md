# Ownership and References

Move VM implements Rust-like ownership system. And the best description of it is in the [Rust Book](https://doc.rust-lang.org/stable/book/ch04-01-what-is-ownership.html). 

I recommend you reading the ownership chapter in the Rust Book even though Rust syntax differs and some of the examples may not be easy to understand. In this chapter we will go through main points anyway.

> Each variable has only one owner scope. When owner scope ends - owned variables are dropped.

We've already seen this behavior in the [expressions chapter](/syntax-basics/expression-and-scope.md). Remember that a variable lives as long as its scope? Now is the perfect time to get under the hood and learn why it happens.

Owner is a scope which *owns* a variable. Variables either can be defined in this scope (e.g. with keyword `let`) or be passed into the scope as arguments. Since the only scope in Move is function's - there are no other ways to put variables into scope.

Each variable has only one owner, which means that when a variable is passed into function as argument, this function becomes the *new owner*, and the variable is no longer *owned* by the first function. Or you may say that this other function *takes ownership* of the variable.

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

Let's look at what happens inside the `value()` function when we pass our value into it:

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

Of course, a quick workaround is to return a tuple with the original variable and additional results (return value would have been `(T, u8)`), but Move has a better solution for that.

### Move and Copy

First, you need to understand how Move VM works, and what happens when you pass your value into a function. There are two bytecode instructions in VM: *MoveLoc* and *CopyLoc* - both of them can be manually used with keywords `move` and `copy` respectively.

When a variable is being passed into another function - it's being *moved* and *MoveLoc* OpCode is used. Let's see how our code would look if we've used keyword `move`:

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

In this example we've passed a *copy* of a variable (hence value) `a` into the first call of the method `value` and saved `a` in local scope to use it again in a second call.

By copying a value we've duplicated it and increased the memory size of our program, so it can be used - but when you copy huge data it may become pricey in terms of memory. Remember - in blockchains every byte counts and affects the price of execution, so using `copy` all the time may cost you a lot.

Now you are ready to learn about references - a tool that will help you avoid unnecessary copying and literally save some money.

## References

Many programming languages have implementation of references ([see Wikipedia](https://en.wikipedia.org/wiki/Reference_(computer_science))). *Reference* is a link to a variable (usually to a section in the memory) which you can pass into other parts of the program instead of *moving* the value.

> References (marked with &) allow you to *refer* to a value without taking *ownership* of it.

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

Immutable references allow reading value without changing it. Mutable - the opposite - ability to read and change the value.

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
        0x1::Debug::print<u8>(&value);
    }
}
```

> Use immutable (&) references to read data from structs, use mutable (&mut) to modify them. By using proper type of references you help maintaining security and help reading your modules so the reader will know whether this method changes the value or only reads.

### Borrow checking

Move controls the way you use references and helps you prevent unexpected bullet in your foot. To understand that let's see an example. I'll give you a module and a script and then will comment on what's going on and why.

```Move
module Borrow {

    struct B { value: u64 }
    struct A { b: B }

    // create A with inner B
    public fun create(value: u64): A {
        A { b: B { value } }
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

This code compiles and runs without errors. First, what happens here: we use mutable reference to `A` to get mutable reference to its inner struct `B`. Then we change `B`. Then operation can be repeated.

But what if we've swapped two last expressions and first tried to create a new mutable reference to `A` while mutable reference to `B` is still alive?

```Move
let mut_a = &mut a;
let mut_b = Borrow::ref_from_mut_a(mut_a);

let _ = Borrow::ref_from_mut_a(mut_a);

Borrow::change_b(mut_b, 100000);
```

We would have gotten an error:

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

This code won't compile. Why? Because `&mut A` is *being borrowed* by `&mut B`. If we could change `A` while having mutable reference to its contents, we'd get into an odd situation where `A` can be changed but reference to its contents is still here. Where would `mut_b` point to if there was no actual `B`?

We come to few conclusions:

1. We get a compilation error which means that the Move compiler prevents these cases. It's called *borrow checking* (originally concept from Rust language). Compiler builds a *borrow graph* and disallows *moving borrowed values*. This is one of the reasons why Move is so safe to use in blockchains.
2. You can create reference from reference, so that original reference will *be borrowed* by the new one. Mutable and immutable can be created from mutable and only immutable from immutable.
3. When reference *is borrowed* it cannot be *moved* because other values depend on it.

### Dereferencing

References can be dereferenced to get linked value - to do it use asterisk `*`.

> When dereferencing you're making a *copy*. Make sure that value has Copy ability.

```Move
module M {
    struct T has copy {}

    // value t here is of reference type
    public fun deref(t: &T): T {
        *t
    }
}
```

> Dereference operator does not move original value into current scope. It creates a *copy* of this value instead.

There's a technique in Move used to copy inner field of a struct: `*&` - dereference a reference to the field. Here's a quick example:

```Move
module M {
    struct H has copy {}
    struct T { inner: H }

    // ...

    // we can do it even from immutable reference!
    public fun copy_inner(t: &T): H {
        *&t.inner
    }
}
```

By using `*&` (even compiler will advise you to do so) we've copied the inner value of a struct.

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
