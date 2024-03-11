# Understanding Generics

Generics are essential to Move, they are what makes this language so unique to the blockchain world, and they are the source of Move's flexibility.

To start I'll quote [Rust Book](https://doc.rust-lang.org/stable/book/ch10-00-generics.html): *Generics are abstract stand-ins for concrete types or other properties*. Practically speaking, they are the way of writing a single function, which can then be used for any type, they can also be called templates as this function can be used as a template handler for any type.

In Move generics can be applied to signatures of `struct` and `function`.

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

Next to the struct name we've placed `<T>`. Where angle brackets `<..>` is a place to define generic types, and `T` is a type we've *templated* in this struct. Inside the struct body definition we've used `T` as a regular type. Type T does not exist, it is a placeholder for *any type*.

### In function signature

Now let's create a constructor for this struct which will first use type `u64` for value.

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

Generics have a bit more complicated definitions - since they need to have type parameters specified, and regular struct `Box` becomes `Box<u64>`. There are no restrictions in what types you can pass into generic's angle brackets. Let's make our `create_box` method more generic and let users specify any type. How do we do that? By using another generic, now in function signature!

```Move
module Storage {
    // ...
    public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }

    // we'll get to this a bit later, trust me
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }
}
```

### In function calls

What we did is we added angle brackets into function signature right after function name. Just the same way as we did with struct. Now how would we use this function? By specifying type in function call.

```Move
script {
    use {{sender}}::Storage;
    use 0x1::Debug;

    fun main() {
        // value will be of type Storage::Box<bool>
        let bool_box = Storage::create_box<bool>(true);
        let bool_val = Storage::value(&bool_box);

        assert(bool_val, 0);

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

        // you've already seen Debug::print<T> method
        // which also uses generics to print any type
        Debug::print<u64>(&value);
    }
}
```

Here we have used Box struct with 3 types: `bool`, `u64` and with `Box<u64>` - last one may seem way too complicated but once you've gotten used to it and understood how it works, it becomes part of your routine.

<!-- , Move opens in new way - the way you probably could never imagine in blockchains. -->

Before we go any further, let's take a step back. By adding generics to `Box` struct we've made this box *abstract* - its definition is fairly simple compared to capacity it gave us. Now we can create `Box` with any type - be it `u64` or `address`, or even another box, or another struct.

### Constraints to check Abilities

We've learned about [abilities](/advanced-topics/abilities/README.md). They can be "checked" or *constrained* in generics; constraints are named after their abilities:

```Move
fun name<T: copy>() {} // allow only values that can be copied
fun name<T: copy + drop>() {} // values can be copied and dropped
fun name<T: key + store + drop + copy>() {} // all 4 abilities are present
```

...or with structs:

```Move
struct name<T: copy + drop> { value: T } // T can be copied and dropped
struct name<T: store> { value: T } // T can be stored in global storage
```

> Try to remember this syntax: `+` (plus) sign may not be intuitive first time; it is the only place in Move where `+` is used in keyword list.

Here's an example of a system with constraints:

```Move
module Storage {

    // contents of the box can be stored
    struct Box<T: store> has key, store {
        content: T
    }
}
```

It is also important to mention that inner types (or generic types) MUST have abilities of the container (for all abilities except `key`). If you think about it, everything is logical and intuitive: struct with **copy** ability must have contents that also have copy ability otherwise container object cannot be considered copyable. Move compiler will let you compile code that doesn't follow this logic but you won't be able to use these abilities. See this example: 

```Move
module Storage {
    // non-copyable or droppable struct
    struct Error {}
    
    // constraints are not specified
    struct Box<T> has copy, drop {
        contents: T
    }

    // this method creates box with non-copyable or droppable contents
    public fun create_box(): Box<Error> {
        Box { contents: Error {} }
    }
}
```

This code compiles and publishes successfully. But if you try to use it...

```Move
script {
    fun main() {
        {{sender}}::Storage::create_box() // value is created and dropped
    }   
}
```

You will get an error saying that Box is not droppable:
```
   ┌── scripts/main.move:5:9 ───
   │
 5 │   Storage::create_box();
   │   ^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

That happens because inner value doesn't have drop ability. Container abilities automatically limited by its contents, so, for example if you have a container struct that has copy, drop and store, and inner struct has only drop, it will be impossible to copy or store this container. Another way to look at this is that container doesn't have to have constraints for inner types and can be flexible - used for any type inside.

> But to avoid mistakes always check and, if needed, specify generic constraints in functions and structs. 

In this example safer struct definition could be:

```Move
// we add parent's constraints
// now inner type MUST be copyable and droppable
struct Box<T: copy + drop> has copy, drop {
    contents: T
}
```

### Multiple types in generics

Just like you can use a single type, you can use many. Generic types are put into angle brackets and separated by comma. Let's add a new type `Shelf` which will hold two boxes of two different types.

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

Type parameters for `Shelf` are listed and matched inside struct's fields definition. Also, as you can see, name of the type parameter inside generics does not matter - it's up to you to choose a proper one. And each type parameter is only valid within definition so no need to match `T1` or `T2` with `T`.

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

*You can have up to 18,446,744,073,709,551,615 (u64 size) generics in one definition. You definitely will never reach this limit, so feel free to use as many as you need without worrying about limits.*

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

Sometimes it is nice to have generic as a constraint or constant for some action. See how it can be used in script:

```Move

script {
    use {{sender}}::Storage;

    fun main() {
        // value will be of type Storage::Box<bool>
        let _ = Storage::create_box<bool, Storage::Abroad>(true);
        let _ = Storage::create_box<u64, Storage::Abroad>(1000);

        let _ = Storage::create_box<u128, Storage::Local>(1000);
        let _ = Storage::create_box<address, Storage::Local>(0x1);

        // or even u64 destination!
        let _ = Storage::create_box<address, u64>(0x1);
    }
}
```

Here we use generics to mark type, but we don't actually use it. You'll soon learn why this definition matters when you get to know resources concept. For now it's just another way to use them.


<!-- ### Copyable

*Copyable kind* - is a kind of types, value of which can be copied. `struct`, `vector` and primitive types - are three main groups of types fitting into this kind.

To understand why Move needs this constraint let's see this example:

```Move
module M {
    public fun deref<T>(t: &T): T {
        *t
    }
}
```

By using *dereference* on a reference you can *copy* the original value and return it as a regular. But what if we've tried to use `resource` in this example? Resource can't be copied, hence this code would fail. Hopefully compiler won't let you compile this type, and kinds exist to manage cases like this.

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

This example here is only needed to show syntax, we'll get to resources soon and you'll learn actual use cases for this constraint. -->
