# What is Resource

Resource is a concept described in Move Whitepaper. Originally it was implemented as its own type but later, with addition of abilities, replaced with two abilities: `Key` and `Store`. Resource is meant to be a perfect type for storing digital assets, to achieve that it must to be non-copyable and non-droppable. At the same time it must be store-able and transferable between accounts. 

<!-- Resource is a defineable type with set of restrictions created to make this type safe enough to represent digital assets. That being said, resource must meet the requirements for these assets: it cannot be copied nor can it be discarded or reused. We've already [been through](/resources) general description of its properties; let's see how these restrictions are implemented in the Move language. -->

### Definition

Resource is a struct with `key` and `store` abilities:

```Move
module M {
    struct T has key, store {
        field: u8
    }
}
```

### Resource restrictions

In code resource type has few main limitations:

1. Resources is stored under account - therefore it *exists* only when assigned to account; and can only be *accessed* through this account;
2. Account can hold *only one* resource of *one type*;
3. Resource cannot be copied or duplicated; it is a special *kind* which differs from is not `copyable` - you've already seen it in [generics chapter](/advanced-topics/understanding-generics.md#resource).
4. Resource value *must be used*, which means that newly created resource *must be moved* to account. And resource *moved from* account must be *destructured* or stored under another account.

Enough theory, let's get to action!
