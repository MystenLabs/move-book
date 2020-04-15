# Resources

Resources are what makes Move unique, safe and powerful.
First, let's see description from [libra developers portal](https://developers.libra.org/docs/move-overview#move-has-first-class-resources):

> - The key feature of Move is the ability to define custom resource types. **Resource types are used to encode safe digital assets with rich programmability**.
> - **Resources are ordinary values in the language**. They can be stored as data structures, passed as arguments to procedures, returned from procedures, and so on.
> - **The Move type system provides special safety guarantees for resources**. Move resources can never be duplicated, reused, or discarded. A resource type can only be created or destroyed by the module that defines the type. These guarantees are enforced statically by the Move virtual machine via bytecode verification. The Move virtual machine will refuse to run code that has not passed through the bytecode verifier.
> - The Libra currency is implemented as a resource type named LibraCoin.T. LibraCoin.T has no special status in the language; every Move resource enjoys the same protections.

Okay, now how does it work syntax wise?

## Why `resource struct`?

As you can see in the heading a `resource struct` is also a `struct` and, currently, it's the only way to define a resource. Just like `struct`, a resource can only be defined in a module, and unlike struct, resource will outlive your script. To understand that let's look at struct syntax again:

```Move
module VinylShop {

    struct Record {
        author_id: u64,
        label_id: u64,
        year: u64
    }

    public fun add_new(author_id: u64, label_id: u64, year: u64): Record {
        Record {
            author_id,
            label_id,
            year
        }
    }
}
```

What happens if we use module `VinylShop` in a script and call a method `add_new()`? New struct will be created in a script context. What happens when script scope ends? All defined variables and structs will be dumped:

```Move
use {sender}::VinylShop;

fun main() {
    // nice one - record created inside code
    let _r = VinylShop::add_new(10, 10, 1999);
}
// but was it saved somewhere? where did it go when script ended? nowhere!
```

> That is when the `resource struct` comes into play. It can be saved, accessed,  updated and destroyed. It outlives the script and affects blockchain state.

## From `struct` to `resource`

Let's modify our example with VinylShop (imagine we want to store our catalogue in blockchain).

First order of business - `struct` becomes `resource struct`.

```Move
resource struct Record {
    author_id: u64,
    label_id: u64,
    year: u64
}
```


