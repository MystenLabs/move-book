# The Key Ability

For the [Object Model](./../concepts/object-model.md) to work, the object has to have a formal definition. And for that Move offers the `key` ability.

```move
///
public struct Object has key {
    id: UID
}
```

## UID type

...

## Creating an Object

...

## Deleting an Object

## UID freshness requirement

Sui Verifier will not allow using a UID that wasn't generated in the same function. In other words - reusing UID or passing it from another function won't work.

##
