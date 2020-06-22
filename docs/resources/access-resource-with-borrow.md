# Read and Modify Resource

To read and modify resource Move has two more built-in functions. Their names perfectly match their goals: `borrow_global` and `borrow_global_mut`.

## Immutable borrow with `borrow_global`

In [ownership and references chapter](/advanced-topics/ownership-and-references.md) you've got to know mutable (&mut) and immutable references. It's time to put this knowledge to practice!

```Move
// modules/Collection.move
module Collection {

    // added a dependency here!
    use 0x1::Signer;
    use 0x1::Vector;

    struct Item {}
    resource struct T {
        items: vector<Item>
    }

    // ... skipped ...

    /// get collection size
    /// mind keyword acquires!
    public fun size(account: &signer): u64 acquires T {
        let owner = Signer::address_of(account);
        let collection = borrow_global<T>(owner);

        Vector::length(&collection.items)
    }
}
```

A lot has happened here. First, let's deal with method signature. Global function `borrow_global<T>` gives a immutable reference to resource T. It's signature is like:

```Move
native fun borrow_global<T: resource>(addr: address): &T;
```

By using this function we get *read access* to resource stored at specific address. Which means that module has capability to read any of its resources at any addresses (if this functionality is implemented).

Another conclusion: due to borrow checking you cannot return reference to resource nor to its contents (as original reference to resource will die on scope end).

> Since resource is a non-copyable type, it is impossible to use dereference operator '*' on it.

### Acquires keyword

There's another detail worth explanation: keyword `acquires` which is put after function return value. This keyword explicitly defines all the resources *acquired* by this function. You must specify each acqured resource, even if it's a nested function call actually acquires resource - parent scope must have this resource specified in acquires list.

Syntax for function with `acquires` is like this:

```Move
fun <name>(<args...>): <ret_type> acquires T, T1 ... {
```

## Mutable borrow with `borrow_global_mut`

To get mutable reference to resource, add `_mut` to your `borrow_global` and that's all. Let's add a function to add new (currently empty) item to collection.

```Move
module Collection {

    // ... skipped ...

    public fun add_item(account: &signer) acquires T {
        let collection = borrow_global_mut<T>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }
}
```

Mutable reference to resource allows creating mutable references to its contents. That is why we're able to modify inner vector `items` in this example.

Signature for `borrow_global_mut` could be:

```Move
native fun borrow_global_mut<T: resource>(addr: address): &mut T;
```


