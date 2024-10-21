// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// ANCHOR: main
module book::coffee_machine {
    /// Coffee machine is a shared object, hence requires `key` ability.
    public struct CoffeeMachine has key { id: UID, counter: u16 }

    /// Cup is an owned object.
    public struct Cup has key, store { id: UID, has_coffee: bool }

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
    public fun make_coffee(machine: &mut CoffeeMachine, cup: &mut Cup) {
        machine.counter = machine.counter + 1;
        cup.has_coffee = true;
    }

    /// Drink coffee from the cup. This is a fast path operation.
    public fun drink_coffee(cup: &mut Cup) {
        cup.has_coffee = false;
    }

    /// Put the cup back. This is a fast path operation.
    public fun put_back(cup: Cup) {
        let Cup { id, has_coffee: _ } = cup;
        id.delete();
    }
}
// ANCHOR_END: main
