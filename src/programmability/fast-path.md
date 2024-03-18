# Fast Path

Due to the object model and the data organization model of Sui, some operations can be performed in a more efficient and parallelized way. This is called the **fast path**. Transaction that touches shared state requires consensus because it can be accessed by multiple parties at the same time. However, if the transaction only touches the private state (owned objects), there is no need for consensus. This is the fast path.

We have a favorite example for this: a coffee machine and a coffee cup. The coffee machine placed in the office is a shared resource - everyone can use it, but there can be only one user at a time. The coffee cup, on the other hand, is a private resource - it belongs to a specific person, and only that person can use it. To make coffee, one needs to use the coffee machine and wait if there's someone else using it. However, once the coffee is made and poured into the cup, the person can take the cup and drink the coffee without waiting for anyone else.

The same principle applies to Sui. If a transaction only touches the private state (the cup with coffee), it can be executed without consensus. If it touches the shared state (the coffee machine), it requires consensus. This is the fast path.

## Frozen objects

Consensus is only required for mutating the shared state. If the object is immutable, it is treated as a "constant" and can be accessed in parallel. Frozen objects can be used to share unchangable data between multiple parties without requiring consensus.

## In practice

```move
module book::coffee_machine {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    /// Coffee machine is a shared object, hence requires `key` ability.
    struct CoffeeMachine has key { id: UID, counter: u16 }

    /// Cup is an owned object.
    struct Cup has key, store { id: UID, has_coffee: bool }

    /// Initialize the module and share the `CoffeeMachine` object.
    fun init(ctx: &mut TxContext) {
        transfer::share_object(CoffeeMachine {
            id: object::new(ctx),
            counter: 0
        });
    }

    /// Take a cup out of thin air. This is a fast path operation.
    public fun take_cup(ctx: &mut TxContext): Cup {
        Cup { id: object::new(ctx), has_coffee: false }
    }

    /// Make coffee and pour it into the cup. Requires consensus.
    public fun make_coffee(mut machine: &mut CoffeeMachine, mut cup: &mut Cup) {
        machine.counter = machine.counter + 1;
        cup.has_coffee = true;
    }

    /// Drink coffee from the cup. This is a fast path operation.
    public fun drink_coffee(mut cup: &mut Cup) {
        cup.has_coffee = false;
    }

    /// Put the cup back. This is a fast path operation.
    public fun put_back(cup: Cup) {
        let Cup { id, has_coffee: _ } = cup;
        object::delete(id);
    }
}
```

## Special case: Clock

The `Clock` object with the reserved address `0x6` is a special case of a shared object which maintains the fast path. While being a shared object, it cannot be passed by a mutable reference in a regular transaction. An attempt to do so will not succeed, and the transaction will be rejected.

<!-- Add more on why and how -->
