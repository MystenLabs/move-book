# Pattern: Hot Potato

A case in the abilities system - a struct without any abilities - is called _hot potato_. It cannot be stored (not as [an object](./../storage/key-ability.md) nor as [a field in another struct](./../storage/store-ability.md)), it cannot be [copied](./../move-basics/copy-ability.md) or [discarded](./../move-basics/drop-ability.md). Hence, once constructed, it must be gracefully [unpacked by its module](./../move-basics/struct.md), or the transaction will abort due to unused value without drop.

The name comes from the children's game where a ball is passed quickly between players, and none of the players want to be the last one holding it when the music stops, or they are out of the game. This is the best illustration of the pattern - the instance of a hot-potato struct is passed between calls, and none of the modules can keep it.

## Defining a Hot Potato

A hot potato can be any struct with no abilities. For example, the following struct is a hot potato:

```move
public struct Request {}
```

Because the struct has no abilitied, once constructed,

<!-- it must be unpacked by the module that created it. And typically the module would implement special logic to define the behavior of the hot potato. Let's consider an example, where the value stored in a `Container` object can be borrowed with a "promise" to be returned later. To practically illustrate the pattern we will show two implementations, one without the hot potato and one with it. -->

```move
module book::container_borrow {
    const EContainerEmpty: u64 = 0;

    /// A generic container for any Object with `key + store`. The Option type
    /// is used to allow taking and putting the value back.
    public struct Container<T: key + store> has key {
        id: UID,
        value: Option<T>,
    }

    /// A Hot Potato struct that will be used to ensure the borrowed value
    /// is returned.
    public struct Promise {}

    /// A module that allows borrowing the value from the container.
    public fun borrow<T>(container: &mut Container<T>): (T, Promise) {
        assert!(container.value.is_some(), EContainerEmpty);
        container.value.extract()
    }

    /// Put the taken item back into the container.
    public fun put_back<T>(container: &mut Container<T>, value: T) {
        container.value.fill(value);
    }
}
```

<!-- In this example the `Container` struct which stores other objects, allows `borrow`-ing the value from it. However, in this implementation, we cannot enforce the return of the value back to the container. The borrowed `T` can be freely transferred anywhere and the Container can be left empty. To solve this issue, we need to introduce a hot potato struct. The struct would ensure that the borrowed value is returned back to the container. For simplicity we will only show changed parts of the code: -->

## Applications

### Borrowing

### Atomic Swaps

### Switches

### Compositional Patterns
