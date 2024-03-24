# Publisher Authority

In application design and development, it is often needed to prove publisher authority. This is especially important in the context of digital assets, where the publisher may enable or disable certain features for their assets. The Publisher Object is an object, defined in the [Sui Framework](./sui-framework.md), that allows the publisher to prove their *authority over a type*.

## Definition

The Publisher object is defined in the `sui::package` module of the Sui Framework. It is a very simple, non-generic object that can be initialized once per module (and multiple times per package) and is used to prove the authority of the publisher over a type. To claim a Publisher object, the publisher must present a [One Time Witness](./one-time-witness.md) to the `sui::package::claim` function.

File: sui-framework/sources/package.move
```move
// module: sui::package
public struct Publisher has key, store {
    id: UID,
    package: String,
    module_name: String,
}
```

> If you're not familiar with the One Time Witness, you can read more about it [here](./one-time-witness.md).

Here's a simple example of claiming a `Publisher` object in a module:

```move
module book::publisher {
    /// Some type defined in the module.
    public struct Book {}

    /// The OTW for the module.
    public struct PUBLISHER has drop {}

    /// Uses the One Time Witness to claim the Publisher object.
    fun init(otw: PUBLISHER, ctx: &mut TxContext) {
        // Claim the Publisher object.
        let publisher = sui::package::claim(otw, ctx);

        // Usually it is transferred to the sender.
        // It can also be stored in another object.
        transfer::public_transfer(publisher, ctx.sender())
    }
}
```

## Usage

The Publisher object has two functions associated with it which are used to prove the publisher's authority over a type:

```move
module book::use_publisher {
    public struct Book {}

    public struct USE_PUBLISHER has drop {}


#[test]
fun test_publisher() {
let ctx = tx_context::dummy();
let publisher = package::test_claim(USE_PUBLISHER, &mut ctx);
// ANCHOR: use_publisher
// Checks if the type is from the same module, hence the `Publisher` has the
// authority over it.
assert!(publisher.from_module<Book>(), 0);

// Checks if the type is from the same package, hence the `Publisher` has the
// authority over it.
assert!(publisher.from_package<Book>(), 0);
// ANCHOR_END: use_publisher
}
}
```
