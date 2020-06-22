# Sender as Signer

Before we get to how to use resources, you need to learn about `signer` type, and why this type exists.

> Signer is a native non-copyable (resource-like) type which holds address of transaction sender.

Signer type represents sender authority. In other words - using signer means accessing sender's address and resources. It has no direct relation to *signatures* or literally *signing*, in terms of Move VM it simply represents sender.

Important! `0x1::Transaction::sender()` may soon be deprecated [as mentioned here](https://community.libra.org/t/signer-type-and-move-to/2894). So in the future using `signer` will be the only way to get sender's address.

### Signer in scripts

Since signer is a native type, it has to be created. Though unlike `vector` it cannot be directly created in code, but can be received as script argument:

```Move
script {
    // signer is a reference type here!
    fun main(account: &signer) {
        let _ = account;
    }
}
```

Signer argument is put into your scripts automatically by VM, which means that there's no way nor need to pass it into script manually. One more thing - it's always a *reference*. Even though standard library (in case of Libra it's - [LibraAccount](https://github.com/libra/libra/blob/master/language/stdlib/modules/LibraAccount.move)) has access to actual value of signer, functions using this value are private and there's no way to use or pass signer value anywhere else.

> Currently, canonical name of the variable holding signer type is *account*

### Signer module in standard library

Native types require native functions, and for signer type it is `0x1::Signer`. This module is fairly simple ([link to original module in libra](https://github.com/libra/libra/blob/master/language/stdlib/modules/Signer.move)):

```Move
module Signer {
    // Borrows the address of the signer
    // Conceptually, you can think of the `signer`
    // as being a resource struct wrapper arround an address
    // ```
    // resource struct Signer { addr: address }
    // ```
    // `borrow_address` borrows this inner field
    native public fun borrow_address(s: &signer): &address;

    // Copies the address of the signer
    public fun address_of(s: &signer): address {
        *borrow_address(s)
    }
}
```

As you can see, there're 2 methods, one of which is native and the other one is more handy as it copies address with dereference operator.

Usage of this module is just as simple:

```Move
script {
    fun main(account: &signer) {
        let _ : address = 0x1::Signer::address_of(account);
    }
}
```

### Signer in module

```Move
module M {
    use 0x1::Signer;

    // let's proxy Signer::address_of
    public fun get_address(account: &signer): address {
        Signer::address_of(account)
    }
}
```

> Methods using `&signer` type as argument explicitly show that they are using sender's address.

One of the reasons for this type was to show which methods require sender authority and which ones do not. So method cannot trick user into unauthorized access to its resources.

<!--  MAYBE ADD HISTORY OF THIS TYPE? -->

### Further reading and PRs

- [Libra Community thread on signer](https://community.libra.org/t/signer-type-and-move-to/2894)
- [Issue in libra repository with reasoning](https://github.com/libra/libra/issues/3679)
- [PR in libra repository](https://github.com/libra/libra/pull/3819)
