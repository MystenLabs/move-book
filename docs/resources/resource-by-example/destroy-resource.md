# Take and Destroy Resource

Final function of this section is `move_from` which takes resource from account. We'll implement `destroy` function which will move collection resource *from* account and will destroy its contents.

```Move
// modules/Collection.move
module Collection {

    // ... skipped ...

    public fun destroy(account: &signer) acquires Collection {

        // account no longer has resource attached
        let collection = move_from<Collection>(Signer::address_of(account));

        // now we must use resource value - we'll destructure it
        // look carefully - Items must have drop ability
        let Collection { items: _ } = collection;

        // done. resource destroyed
    }
}
```

Resource value must be used. So resource, when taken from account, must be either destructured or passed as return value. However keep in mind that even if you pass this value outside and get it in the script, there are limited options of what to do next as script context does not allow you to do anything with struct or resource except passing it somewhere else. Knowing that - design your modules properly and give user an option to do something with returned resource.

The very last signature:

```Move

native fun move_from<T: key>(addr: address): T;

```
