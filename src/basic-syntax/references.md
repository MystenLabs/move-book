# References

<!--

Chapter: Basic Syntax
Goal: Show what the borrow checker is and how it works.
Notes:
    - give the metro pass example
    - show why passing by reference is useful
    - mention that reference comparison is faster
    - references can be both mutable and immutable
    - immutable access to shared objects is faster
    - implicit copy
    - moving the value
    - unpacking a reference (mutable and immutable)

 -->

In [the previous section](./ownership-and-scope.md) we explained the ownership and scope in Move. We showed how the value is *moved* to a new scope, and how it changes the owner. In this section, we will explain how to *borrow* a reference to a value to avoid moving it, and how Move's *borrow checker* ensures that the references are used correctly.

## Reference

References are a way to borrow a value without changing its owner. Immutable references allow the function to read the value without changing it or moving it. And mutable references allow the function to read and modify the value without moving it. To illustrate this, let's consider a simple example - an application for a metro (subway) pass. We will look at 4 different scenarios:

1. Card can be purchased at the kiosk for a fixed price
2. Card can be shown to inspectors to prove that the passenger has a valid pass
3. Card can be used at the turnstile to enter the metro, and spend a ride
4. Card can be recycled once it's empty

```move
module book::references {

    /// Error code for when the card is empty.
    const ENoUses: u64 = 0;

    /// Number of uses for a metro pass card.
    const USES: u8 = 3;

    /// A metro pass card
    struct Card { uses: u8 }

    /// Purchase a metro pass card.
    public fun purchase(/* pass a Coin */): Card {
        Card { uses: USES }
    }

    /// Show the metro pass card to the inspector.
    public fun show(card: &Card): bool {
        card.uses > 0
    }

    /// Use the metro pass card at the turnstile to enter the metro.
    public fun enter_metro(card: &mut Card) {
        assert!(card.uses > 0, ENoUses);
        card.uses = card.uses - 1;
    }

    /// Recycle the metro pass card.
    public fun recycle(card: Card) {
        assert!(card.uses == 0, ENoUses);
        let Card { uses: _ } = card;
    }

    #[test]
    fun test_card() {
        // declaring variable as mutable because we modify it
        let mut card = purchase();

        card.enter_metro(); // modify the card but don't move it
        assert!(card.show(), true); // read the card!

        card.enter_metro(); // modify the card but don't move it
        card.enter_metro(); // modify the card but don't move it

        card.recycle(); // move the card out of the scope
    }
}
```

## Mutable References

<!-- TODO: talk about the number of references at a time -->

## Dereference and Copy

<!-- TODO: defer and copy, *& -->

## Notes

<!--
    Move 2024 is great but it's better to show the example with explicit &t and &mut t
    ...and then say that the example could be rewritten with the new syntax


-->
