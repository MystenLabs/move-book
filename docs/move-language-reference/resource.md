# Resources

Resources are what makes Move unique, safe and powerful.
First, let's see description from [libra developers portal](https://developers.libra.org/docs/move-overview#move-has-first-class-resources):

> - The key feature of Move is the ability to define custom resource types. **Resource types are used to encode safe digital assets with rich programmability**.
> - **Resources are ordinary values in the language**. They can be stored as data structures, passed as arguments to procedures, returned from procedures, and so on.
> - **The Move type system provides special safety guarantees for resources**. Move resources can never be duplicated, reused, or discarded. A resource type can only be created or destroyed by the module that defines the type. These guarantees are enforced statically by the Move virtual machine via bytecode verification. The Move virtual machine will refuse to run code that has not passed through the bytecode verifier.
> - The Libra currency is implemented as a resource type named LibraCoin.T. LibraCoin.T has no special status in the language; every Move resource enjoys the same protections.

## Why `resource`?

Just like `struct`, a `resource struct` (that's how it's called) can only be defined within module context, and unlike struct, resource will outlive your script. To understand that let's look at this example:

```Move
// here's our module to manage records on chain
module RecordsCollection {

    use 0x0::Transaction as Tx;

    // the very basic information about our record
    struct Record {
        name: vector<u8>,
        author: vector<u8>,
        year: u64
    }

    // imaginary collection of records
    struct Collection {
        records: vector<Record>
    }

    public fun create_record(name: vector<u8>, author: vector<u8>, year: u64): Record {
        Record { name, author, year }
    }
}
```

What happens if we use module `RecordsCollection` in a script and call a method `add_new()`? New struct will be created in a script context. What happens when script scope ends? All defined variables and structs will be dumped:

```Move
use {{sender}}::RecordsCollection as Collection;

fun main(name: vector<u8>, author: vector<u8>, year: u64) {

    let r = Collection::create_record(name, author, year);

    // record is created but it saved somewhere?
    // where does it go when script ends? nowhere!
}
```

Going further: even if we created `Collection` struct and pushed newly created `Record` in it, whole collection would still have been gone by the end of scope.

> That's when the **`resource struct`** comes into play. It can be saved, accessed,  updated and destroyed. It outlives the script and affects blockchain state.

## How to work with `resource`

Let's modify our example with RecordsCollection (imagine we want to store our catalogue in blockchain). Even better - we wan't to let anyone manage their record collection.

## Make `struct` a `resource struct`

First order of business - turning `struct` into `resource struct`. We will do it only for collection (you'll see why):

```Move
resource struct Collection {
    records: vector<Record>
}
```

Even better (or say more correct) way to name main resource in module is `"T"`:

```Move
// since whole module is named RecordsCollection
// everyone will understand that T equals Collection
resource struct T {
    records: vector<Record>
}
```

<!-- MB rewrite this part later when done with structure; -->
As you can see, nothing but an addition of one keyword. What actually happens? Collection remains a type. Just like struct you can initialize it (in resource-specific way), you can push records into it and (!) what's really important: this `resource struct` will be saved on chain linked to your address making it possible to read and change it again in future transactions. Even more! If module is properly organized, you can even let other people see your collection, and (only if you want to do so!) you can let them add records into your collection.
<!-- END;  -->

TLDR; It's time to code!

Move has 5 built-in functions to work with collections, we'll go through all of them in order.

## Attach resource with `move_to_sender`

To start working with resource it needs to be attached to sender. Please keep in mind that the only place where you can manage `structs` and `resources` is their module. You can't init resource outside the module context but you can provide `public` method. That's how you do it:

```Move
module RecordsCollection {

    use 0x0::Vector;

    // -- some definitions skipped --

    resource struct T {
        records: vector<Record>
    }

    public fun initialize() {
        move_to_sender<T>(T { records: Vector::empty() })
    }
}
```

> Function `move_to_sender<RESOURCE>(RESOURCE)` links resource to account. It uses some internal magic to define transaction sender so there's no need to specify one.

## Check if resource `exists` at given address

It's good to initialize resource once but not to be mistaken and not to inizalize it twice we can check if resource is linked to address. Here's how it looks if we modify previously defined `initialize()` function:

```Move
module RecordsCollection {

    // -- some definitions skipped --

    use 0x0::Transaction as Tx;

    public fun initialize() {
        let sender = Tx::sender();

        if (!exists<T>(sender)) {
            move_to_sender<T>(T { records: Vector::empty() })
        }
    }
}
```

> Function `exists<RESOURCE>(<ADDRESS>): bool` checks if resource is linked to address and returns boolean result. You can use this function to check any resource and any address - this information is meant to be public on blockchain.

## Using existing resources with `acquires`

Before we proceed. There is a huge difference between *using* resource and *checking or initializing* it. When you initialize resource you create a link between newly created resource, when you check existence you actually check this link exists. But when you *read*, *modify* or *destroy* resource, you need to actually **use resource**.

That is when keyword `acquires` appears. If your function *reads*, *modifies* or *destroys* resource, you MUST put this keyword. Here's how:

```Move
module RecordsCollection {

    // here's our resource T
    resource struct T {
        records: vector<Record>
    }

    // and here we're going to read our resource T
    public fun get_my_records(): vector<Record> acquires T {
        // ...
    }
```

> Keyword `acquires` is put only in function definition after return value or parentheses (when function has no return value). Resource names *acquired* by this function have to be listed after. If there're multiple resources, use comma-separated list: `fun my_fun() acquires R1, R2`.

Functions requiring `acquire`:
- borrow_global_mut
- borrow_global
- move_from

## Read resource contents with `borrow_global`

Okay, we've already linked resource to sender account and even protected ourselves from double initialization, it's time to learn to read it.

```Move
module RecordsCollection {

    // -- some definitions skipped --

    use 0x0::Transaction as Tx;

    resource struct T {
        records: vector<Record>
    }

    public fun get_my_records(): vector<Record> acquires T {

        let sender = Tx::sender();
        let collection = borrow_global<T>(sender);

        *&collection.records
    }
}
```

> Function `borrow_global<RESOURCE>(<ADDRESS>): &<RESOURCE>` requests immutable reference to resource at given address. You can read resource contents just how you'd normally read struct's.

## Modify resource with `borrow_global_mut`

We've come a long way to get here, and finally we're ready to learn how to modify resource.

```Move
module RecordsCollection {

    // -- some definitions skipped --

    use 0x0::Transaction as Tx;
    use 0x0::Vector;

    resource struct T {
        records: vector<Record>
    }

    public fun add_to_my_collection(
        name: vector<u8>,
        author: vector<u8>,
        year: u64
    ) acquires T {

        let sender = Tx::sender();

        // not to do additional call let's put it here
        initialize(sender);

        let record = Record { name, author, year };
        let collection = borrow_global_mut<T>(sender);

        Vector::push_back(&mut collection.records, record)
    }
}
```

> Function `borrow_global_mut<RESOURCE>(<ADDRESS>): &mut <RESOURCE>` creates mutable reference to resource at given address. All the changes you apply via this mutable reference are going to be stored on chain.

## Destroy resource with `move_from`

Finally, to destroy our RecordCollection we will use `move_from` method.

```Move
module RecordsCollection {

    // -- some definitions skipped --

    resource struct T {
        records: vector<Record>
    }

    // see return value here, it is important!
    public fun destroy_collection(): T acquires T {

        let sender = Tx::sender();

        move_from<T>(sender)
    }
}
```

Even though it looks simple - it's not. `move_from` is the most tricky of all methods in this article. Let's go through rules:

1. Value returned by `move_from` MUST be used - in module as a return value;
2. You can't destroy resource twice;
3. Value returned by `move_from` is a full (non-reference) instance of resource;

That's it. Let's summarise.

> To destroy resource under address use `move_from<RESOURCE>(<ADDRESS>): <RESOURCE>` method. Returned value MUST be used (eg passed as return value of destroy function).

## Final contract

Here's final contract. What it does:

- allows anyone store their own RecordCollection on chain;
- provides security for RecordCollection - only owner can access it.

```Move
module RecordsCollection {

    use 0x0::Transaction as Tx;
    use 0x0::Vector;

    struct Record {
        name:   vector<u8>,
        author: vector<u8>,
        year:   u64
    }

    resource struct T {
        records: vector<Record>
    }

    fun initialize(sender: address) {
        if (!::exists<T>(sender)) {
            move_to_sender<T>(T { records: Vector::empty() })
        }
    }

    public fun add_to_my_collection(
        name: vector<u8>,
        author: vector<u8>,
        year: u64
    ) acquires T {

        let sender = Tx::sender();

        initialize(sender);

        let record = Record { name, author, year };
        let collection = borrow_global_mut<T>(sender);

        Vector::push_back(&mut collection.records, record)
    }

    public fun get_my_collection(): vector<Record> acquires T {
        let sender = Tx::sender();
        let collection = borrow_global<T>(sender);

        *&collection.records
    }

    public fun remove_from_me(): T acquires T {
        move_from<T>(Tx::sender())
    }
}
```

## List of function for resource

For reference here's list of methods:

```Move
::exists<T>(<ADDRESS>);  // check if resource exists at given address
move_to_sender<T>(T);    // move newly created resource to sender

// ones below require `acquires` keyword:

borrow_global<T>(<ADDRESS>);
borrow_global_mut<T>(<ADDRESS>);
move_from<T>(<ADDRESS>); // destroy resource
```
