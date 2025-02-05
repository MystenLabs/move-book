# Abilities: Copy

In Move, the _copy_ ability on a type indicates that the instance or the value of the type can be
copied, or duplicated. While this behavior is provided by default when working with numbers or other
primitive types, it is not the default for custom types. Move is designed to express digital
assets and resources, and controlling the ability to duplicate resources is a key principle of the
resource model. However, the Move type system allows you to add the _copy_ ability to custom types:

```move
{{#include ../../../packages/samples/sources/move-basics/copy-ability.move:copyable}}
```

In the example above, we define a custom type `Copyable` with the _copy_ ability. This means that
instances of `Copyable` can be copied, both implicitly and explicitly.

```move
{{#include ../../../packages/samples/sources/move-basics/copy-ability.move:copyable_test}}
```

In the example above, `a` is copied to `b` implicitly, and then explicitly copied to `c` using the
dereference operator. If `Copyable` did not have the _copy_ ability, the code would not compile, and
the Move compiler would raise an error.

> Note: In Move, destructuring with empty brackets is often used to consume unused variables,
> especially for types without the drop ability. This prevents compiler errors from values
> going out of scope without explicit use. Also, Move requires the type name in destructuring
> (e.g., `Copyable` in `let Copyable {} = a;`) because it enforces strict typing and ownership rules.

## Copying and Drop

The `copy` ability is closely related to the [`drop` ability](./drop-ability.md). If a type has the
_copy_ ability, it is very likely that it should have `drop` too. This is because the _drop_ ability is
required to clean up resources when the instance is no longer needed. If a type only has _copy_,
managing its instances gets more complicated, as the instances must be explicitly used or consumed. 

```move
{{#include ../../../packages/samples/sources/move-basics/copy-ability.move:copy_drop}}
```

All of the primitive types in Move behave as if they have the _copy_ and _drop_ abilities. This
means that they can be copied and dropped, and the Move compiler will handle the memory management
for them.

## Types with the `copy` Ability

All native types in Move have the `copy` ability. This includes:

- [bool](./../move-basics/primitive-types.md#booleans)
- [unsigned integers](./../move-basics/primitive-types.md#integer-types)
- [vector](./../move-basics/vector.md)
- [address](./../move-basics/address.md)

All of the types defined in the standard library have the `copy` ability as well. This includes:

- [Option](./../move-basics/option.md)
- [String](./../move-basics/string.md)
- [TypeName](./../move-basics/type-reflection.md#typename)

## Further reading

- [Type Abilities](/reference/abilities.html) in the Move Reference.
