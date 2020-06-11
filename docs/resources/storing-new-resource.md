# Creating and Moving Resource

First, let's create our module:

```Move
// modules/Collection.move
module Collection {


    struct Item {
        // we'll think of the properties later
    }

    resource struct T {
        items: vector<Item>
    }
}
```

> There's a convention to call main resource of a module - **T**. If you follow it, your modules will be easy to read and use by other people.

### Create and Move

We've defined a resource struct `T`, which will hold vector of type `Item`. Now let's see how to start new collection and how *to store a resource under account*. Stored resource in this implementation will live forever under sender's address. No one can modify or take this resource from owner.

```Move
// modules/Collection.move
module Collection {

    use 0x0::Vector;

    struct Item {}

    resource struct T {
        items: vector<Item>
    }

    /// note that &signer type is passed here!
    public fun start_collection(account: &signer) {
        move_to<T>(account, T {
            items: Vector::empty<T>()
        })
    }
}
```

Remember [signer](/resources/signer-type.md)? Now you see how it in action! To *move* resource to account you have built-in function *move_to* which takes `signer` as a first argument and `T` as second. Signature of `move_to` function could be represented like:

```Move
native fun move_to<T: resource>(account: &signer, value: T);
```

That leads to two conclusions:

1. You can only put a resource under your account. You cannot have access to `signer` value of another account, hence cannot put resource there.
2. Only one resource of single type can be stored under one address. Doing the same operation twice would lead to discarding existing resource and this must not happen (imagine you have your coins stored and by inaccurate action you discard all your savings by pushing empty balance!). Second attempt to create existing resource will fail with error.

### Check existence at address

To check if resource exists at given address Move has `exists` function, which signature looks similar to this:

```Move
native fun exists<T: resource>(addr: address): bool;
```

By using generics this function is made type-independent and you can use any resource type to check if it exists at address. Actually, anyone can check if resource exists at given address. But checking existence is not accessing stored value!

Let's write a function to check if user already has collection:

```Move
// modules/Collection.move
module Collection {

    struct Item {}

    resource struct T {
        items: Item
    }

    // ... skipped ...

    /// this function will check if resource exists at address
    public fun exists(at: address): bool {
        ::exists<T>(at)
    }
}
````

Note that we've put `::` - double colon before `exists` function. This is the way to access global functions (such as `move_to` or `exists`) without having conflicts with local functions with the same name.

---

Now you know how to create a resource, how to move it to sender and how to check if resource already exists. It's time to learn to read this resource and to modify it!
