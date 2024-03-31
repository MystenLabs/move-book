# Abilities: Copy

In Move, the *copy* ability on a type indicates that the instance or the value of the type can be copied. While this behavior may feel very natural when working with numbers or other simple types, it is not the default for custom types in Move. This is because Move is designed to express digital assets and resources, and inability to copy is a key element of the resource model.

However, Move type system allows you to define custom types with the *copy* ability.

```move
public struct Copyable has copy {}
```

In the example above, we define a custom type `Copyable` with the *copy* ability. This means that instances of `Copyable` can be copied, both implicitly and explicitly.

```move
let a = Copyable {};
let b = a;   // `a` is copied to `b`
let c = *&b; // explicit copy via dereference operator
```

In the example above, `a` is copied to `b` implicitly, and then explicitly copied to `c` using the dereference operator. If `Copyable` did not have the *copy* ability, the code would not compile, and the Move compiler would raise an error.

## Copying and Drop

The `copy` ability is closely related to [`drop` ability](./drop-ability.md). If a type has the *copy* ability, very likely that it should have `drop` too. This is because the *drop* ability is required to clean up the resources when the instance is no longer needed. If a type has only *copy*, then managing its instances gets more complicated, as the values cannot be ignored.

```move
public struct Value has copy, drop {}
```

All of the primitive types in Move behave as if they have the *copy* and *drop* abilities. This means that they can be copied and dropped, and the Move compiler will handle the memory management for them.
