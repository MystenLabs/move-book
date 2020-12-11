# Programmable Resources

In this section we'll finally learn key feature of Move - resources. They are what makes Move unique, safe and powerful.

To start, let's go through key points from diem developers website (source page was removed after renaming Libra to Diem):

> 1. The key feature of Move is the ability to define custom resource types. *Resource types are used to encode safe digital assets with rich programmability*.
> 2. *Resources are ordinary values in the language*. They can be stored as data structures, passed as arguments to procedures, returned from procedures, and so on.

Resource is a special type of *structure*, and it is possible to define and create new (or use existing) resource right in the Move code. Therefore you're able to manage digital assets the same way you use any other data (like vector or struct).

> 3. *The Move type system provides special safety guarantees for resources*. Move resources can never be duplicated, reused, or discarded. A resource type can only be created or destroyed by the module that defines the type. These guarantees are enforced statically by the Move virtual machine via bytecode verification. The Move virtual machine will refuse to run code that has not passed through the bytecode verifier.

In [references and ownership chapter](/ownership.md) you've seen how Move secures scopes and controls variable's owner scope. And in [generics chapter](/generics.md) you've learned that there's a special way of kind-matching to separate *copyable* and *non-copyable* types. All of these features provide safety for resource type.

> 4. All Diem currencies are implemented using the generic Diem::T type. For example: the LBR currency is represented as Diem::T<LBR::T> and a hypothetical USD currency would be represented as Diem::T<USD::T>. Diem::T has no special status in the language; every Move resource enjoys the same protections.

Just like the Diem currency, other currencies or other types of assets can be represented in Move.

### Further reading

- [Move whitepaper](https://developers.diem.com/docs/technical-papers/move-paper/)
<!-- - [Diem Coin in standard library](https://github.com/diem/diem/blob/master/language/stdlib/modules/LBR.move) -->
<!-- - [Move language page on developers website](https://developers.diem.com/docs/crates/move-language) -->
