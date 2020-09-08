# What is Resource

Resource is a defineable type with set of restrictions created to make this type safe enough to represent digital assets. That being said, resource must meet the requirements for these assets: it cannot be copied nor can it be discarded or reused. We've already [been through](/resources) general description of its properties; let's see how these restrictions are implemented in the Move language.

### Definition

Resource definition is similar to struct's:

```Move
module M {
    resource struct T {
        field: u8
    }
}
```

Just like struct it can be defined only in the module and can be managed only by functions of its module. Resource in some sence is a special kind of struct, so all of the properties of struct are inherited by resource.

### Resource restrictions

In code resource type has few main limitations:

1. Resources is stored under account - therefore it *exists* only when assigned to account; and can only be *accessed* through this account;
2. Account can hold *only one* resource of *one type*;
3. Resource cannot be copied or duplicated; it is a special *kind* which differs from is not `copyable` - you've already seen it in [generics chapter](/advanced-topics/understanding-generics.md#resource).
4. Resource value *must be used*, which means that newly created resource *must be moved* to account. And resource *moved from* account must be *destructured* or stored under another account.

Enough theory, let's get to action!
