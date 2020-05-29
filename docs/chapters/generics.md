# Generics

Generics are essential to Move, they are what makes this language so unique to blockchain world, and they are the source of Move's flexibility.

To start I'll quote [Rust Book](https://doc.rust-lang.org/stable/book/ch10-00-generics.html): *Generics are abstract stand-ins for concrete types or other properties*. Practically speaking, they are the way of writing single function, which can then be used for any type, they can also be called templates as this function can be used as a template handler for any type.

In Move generics can be applied to signatures of `struct`, `function` and `resource`.

### In struct definition

First, we'll create a Box which will hold `u64` value. We've already been through this, so no need for comments.

```Move
module Storage {
    struct Box {
        value: u64
    }
}
```

This box can only contain value of `u64` type - this is clear. But what if we wanted to make the same box for `u8` type or a `bool`? Would we create type `Box1` and then `Box2`? Or would we publish another module for that? The answer is no - use generics instead.

```Move
module Storage {
    struct Box<T> {
        value: T
    }
}
```

Next to struct name we've placed `<T>`. Where angle brackets `<..>` is a place to define generic types, and `T` is a type we've *templated* in this struct. Inside the struct body definition we've used `T` as a regular type. Type T does not exist, it is a placeholder for *any type*.

### In function signature

Now let's create constructor for this struct which will first use type `u64` for value.

```Move
module Storage {
    struct Box<T> {
        value: T
    }

    // type u64 is put into angle brackets meaning
    // that we're using Box with type u64
    public fun create_box(value: u64): Box<u64> {
        Box<u64>{ value }
    }
}
```

Generics have a bit more complicated definitions - since they need to have type parameters specified, and regular struct `Box` becomes `Box<u64>`. There are no restrictions in what types you can pass into generic's angle brackets. Let's make our `create_box` method more gereric and let users specify any type. How do we do that? Using another generic, now in function signature!

```Move
module Storage {
    // ...
    public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }

    // we'll get to this a bit later, trust me
    public fun value<T: copyable>(box: &Box<T>): T {
        *&box.value
    }
}
```

### In function calls

What we did is we added angle brackets into function signature right after function name. Just the same way as we did with struct. Now how would we use this function? By specifying type in function call.

```Move
script {
    use {{sender}}::Storage;
    use 0x0::Transaction;
    use 0x0::Debug;

    fun main() {
        // value will be of type Storage::Box<bool>
        let bool_box = Storage::create_box<bool>(true);
        let bool_val = Storage::value(&bool_box);

        Transaction::assert(bool_val, 0);

        // we can do the same with integer
        let u64_box = Storage::create_box<u64>(1000000);
        let _ = Storage::value(&u64_box);

        // let's do the same with another box!
        let u64_box_in_box = Storage::create_box<Storage::Box<u64>>(u64_box);

        // accessing value of this box in box will be tricky :)
        // Box<u64> is a type and Box<Box<u64>> is also a type
        let value: u64 = Storage::value<u64>(
            &Storage::value<Storage::Box<u64>>( // Box<u64> type
                &u64_box_in_box // Box<Box<u64>> type
            )
        );

        // you've already seed Debug::print<T> method
        // which also uses generics to print any type
        Debug::print<u64>(&value);
    }
}
```

Here we have used Box struct with 3 types: `bool`, `u64` and with `Box<u64>` - last one may seem way too complicated but once you've gotten used to it and understood how it works, it becomes part of your routine.

<!-- , Move opens in new way - the way you probably could never imagine in blockchains. -->

Before we go any further, let's take a step back. By adding generics to `Box` struct we've made this box *abstract* - it's definition is fairly simple compared to capacity it gave us. Now we can create `Box` with any type - be it `u64` or `address`, or even another box, or another struct.

### Multiple types in generics

Just like you can use single type, you can use many. Generic types are put into angle brackets and separated by comma. Let's add new type `Shelf` which will hold two boxes of two different types.

```Move
module Storage {

    struct Box<T> {
        value: T
    }

    struct Shelf<T1, T2> {
        box_1: Box<T1>,
        box_2: Box<T2>
    }

    public fun create_shelf<Type1, Type2>(
        box_1: Box<Type1>,
        box_2: Box<Type2>
    ): Shelf<Type1, Type2> {
        Shelf {
            box_1,
            box_2
        }
    }
}
```

Type paramereters for `Shelf` are listed and matched inside struct's fields definition. Also, as you can see, name of the type parameter inside generics does not matter - it's up to you to chose a proper one. And each type parameter is only valid within definition so no need to match `T1` or `T2` with `T`.

Using multiple generic type parameters is similar to using single:

```Move
script {
    use {{sender}}::Storage;

    fun main() {
        let b1 = Storage::create_box<u64>(100);
        let b2 = Storage::create_box<u64>(200);

        // you can use any types - so same ones are also valid
        let _ = Storage::create_shelf<u64, u64>(b1, b2);
    }
}
```

*You can have up to 18,446,744,073,709,551,615 (u64 size) generics in one definition. You definetely will never reach this limit, so feel free to use as many as you need without worrying about limits.*

### Unused type params

Not every type specified in generic must be used. Look at this example:

```Move
module Storage {

    // these two types will be used to mark
    // where box will be sent when it's taken from shelf
    struct Abroad {}
    struct Local {}

    // modified Box will have target property
    struct Box<T, Destination> {
        value: T
    }

    public fun create_box<T, Dest>(value: T): Box<T, Dest> {
        Box { value }
    }
}
```

In script this can be used :

```Move

script {
    use {{sender}}::Storage;

    fun main() {
        // value will be of type Storage::Box<bool>
        let _ = Storage::create_box<bool, Storage::Abroad>(true);
        let _ = Storage::create_box<u64, Storage::Abroad>(1000);

        let _ = Storage::create_box<u128, Storage::Local>(1000);
        let _ = Storage::create_box<address, Storage::Local>(0x0);

        // or even u64 destination!
        let _ = Storage::create_box<address, u64>(0x0);
    }
}
```

Here we use generics to mark type, but we don't actually use it. You'll soon learn why this definition matters when you get to know `resources`. For now it's just another way to use them.

### Kind-matching and :copyable

In [ownership chapter](/chapters/ownership.md) we learned about *copy* and *move* operations in VM. Not every value in Move can be copied (but all of them can be moved!) - in the [resources chapter](/chapters/resource.md) you'll study `resources`, which are not *copyable*. But before we jump there, let's learn what *Kind* is.

Kind (in terms of VM) - is a group of types, there're only 2 kinds: `copyable` and `resource`. Kinds can be used to limit (or restrict) generic types passed into function.

### Copyable

*Copyable kind* - is a kind of types, value of which can be copied. `struct`, `vector` and primitive types - are three main groups of types fitting into this kind.

To understand why Move needs this constraint let's see this example:

```Move
module M {
    public fun deref<T>(t: &T): T {
        *t
    }
}
```

By using *dereference* on a reference you can *copy* original value and return it as a regular. But what if we've tried to use `resource` in this example? Resource can't be copied, hence this code would fail. Hopefully compiler won't let you compile this type, and kinds exist to manage cases like this.

```Move
module M {
    public fun deref<T: copyable>(t: &T): T {
        *t
    }
}
```

We've added `: copyable` constraint into generic definition, and now type `T` must be of kind *copyable*. So now function accepts only `struct`, `vector` and primitives as type parameters. This code compiles as constraint provides safety over used types and passing non-copyable value here is impossible.

### Resource

Another kind has only one type inside is a `resource` kind. It is used in the same manner:

```Move
module M {
    public fun smth<T: resource>(t: &T) {
        // do smth
    }
}
```

This example here is only needed to show syntax, we'll get to resources soon and you'll learn actual use cases for this constraint.

<!--
  + generics in general
  + templating
  + example
  + back to types
  + multiple type params

  + unused type params
  + trait-like bounds - introducing kinds

  ? hard-coded types - no way
-->
