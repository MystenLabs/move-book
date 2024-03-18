Publisher Object serves as a way to represent the publisher authority. The object itself does not imply any specific use case and has only two main functions: `package::from_module<T>` and `package::from_package<T>` which allow checking whether a type `T` belongs to a module or a package for which the `Publisher` object is created.

> Although `Publisher` itself is a utility, it enables the _"proof of ownership"_ functionality, for example, it is crucial for the [[Using Display]] model.

To set up a Publisher, an One-Time-Witness (OTW) is requred - this way we ensure the `Publisher` object is initialized only once for a specific module (but can be multiple for a package) as well as that the creation function is called in the publish transaction.

```rust
/// Dummy example of a package that defines an OTW and claims
/// a `Publisher` object for the sender. While not giving any
module example::owner {
    use sui::tx_context::{sender, TxContext};
    use sui::transfer;
    use sui::sui::SUI;

    // defines the Publisher type
    use sui::package::{Self, Publisher};

    /// OTW is a struct with only `drop` and is named 
    /// after the module - but uppercased
    struct OWNER has drop {}

    /// Some other type to use in a dummy check
    struct ThisType {}

    fun init(otw: OWNER, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        transfer::transfer(publisher, sender(ctx))
    }

    /// Function to check if `ThisType` is defined in the same
    /// module as the `Publisher` was created
    entry fun is_this_type_mine(pub: &Publisher): bool {
        package::from_module<ThisType>(pub)
    }

    /// Function to check if `SUI` type is defined in the
    /// same package as the `Publisher` object
    entry fun is_publisher_mine(pub: &Publisher): bool {
        package::from_package<SUI>(pub)
    }
}
```

Cases when `Publisher` object is needed in the Sui Framework:

- Creating a `Display<T>` object to define an off-chain representation of the type. For more details visit [[Using Display]] page.
- 