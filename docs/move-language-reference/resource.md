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

What happens if we use module `RecrodsCollection` in a script and call a method `add_new()`? New struct will be created in a script context. What happens when script scope ends? All defined variables and structs will be dumped:

```Move
use {sender}::RecordsCollection as Collection;

fun main(name: vector<u8>, author: vector<u8>, year: u64) {

    let _r = Collection::create_record(name, author, year);

    // record is created but it saved somewhere?
    // where does it go when script ends? nowhere!
}
```

Going further: even if we created new `Collection` struct and pushed newly created `Record` in it, whole collection would still have been gone by the end of scope.

> That's when the **`resource struct`** comes into play. It can be saved, accessed,  updated and destroyed. It outlives the script and affects blockchain state.

## How to work with `resource`

Let's modify our example with RecordsCollection (imagine we want to store our catalogue in blockchain). Even better - we wan't to let anyone have their record collection in our blockchain.

### Make `struct` a `resource struct`

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

### Attach resource with `move_to_sender`

To start working with resource it needs to be attached to sender. Please keep in mind that the only place where you can manage `structs` and `resource`s is their module. You can't init resourse outside the module context but you can provide `public` method. That's how you do it:

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

### Check if resource `exists` at given address

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

### Read resource contents with `borrow_global`

Okay, we've linked resource to sender account and even protected ourselves from double initialization, let's learn to read our resource.

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

There's a lot happened. TBD.

#### Keyword `acquires`

### Change resource contents with `borrow_global_mut`

### Destroy resource with `move_from`

### Final contract

Here's final contract.

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

        Vector::push_back(&mut collection.records, record);
    }

    public fun get_my_collection(): vector<Record> acquires T {
        let sender = Tx::sender();
        let collection = borrow_global<T>(sender);

        *&collection.records
    }
}
```



## Functions to work with resource

```Move
borrow_global<T>(<ADDRESS>);
borrow_global_mut<T>(<ADDRESS>);

move_from<T>(<ADDRESS>); // destroy resource
::exists<T>(<ADDRESS>);  // check if resource exists at given address
move_to_sender<T>(T);    // move newly created resource to sender
```
