# What is Resource

Resource is a concept described in Move Whitepaper. Originally it was implemented as its own type but later, with addition of abilities, replaced with two abilities: `Key` and `Store`. Resource is meant to be a perfect type for storing digital assets, to achieve that it must to be non-copyable and non-droppable. At the same time it must be storable and transferable between accounts. 

Resource is a concept described in Move Whitepaper, it is a type with set of restrictions created to make this type safe enough to represent digital assets. That being said, resource must meet the requirements for these assets: it cannot be copied nor can it be discarded or reused. We've already [been through](/resources) general description of its properties; let's see how these restrictions are implemented in the Move language.

### Definition

Resource is a struct that has only `key` and `store` abilities:

```Move
module M {
    struct T has key, store {
        field: u8
    }
}
```

### Key and Store abilities

Key ability allows struct to be used as a storage identifier. In other words, `key` is an ability to be stored as at top-level and be a storage; while `store` is the ability to be stored *under* key. You will see how it works in the next chapter. For now keep in mind that even primitive types have store ability - they can be stored, but yet they don't have `key` and cannot be used as a top-level containers.

Store ability allows value to be stored. That simple.

### Resource concept

Originally resource had its own type in Move, but with addition of abilities it became a more abstract concept that can be implemented with *key* and/or *store* abilities. Let's still go through description for a resource:

1. Resources is stored under account - therefore it *exists* only when assigned to account; and can only be *accessed* through this account;
2. Account can hold *only one* resource of *one type*, and this resource must have `key` ability;
3. Resource can't be copied nor dropped, but can be stored. 
4. Resource value *must be used*. When resource created or taken from account, it cannot be dropped and must be stored or destructured.

Enough theory, let's get to action!
