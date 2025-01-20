# Pattern: Newtype

Sometimes there's a need to create a new type that behaves similarly to another type, but with some
modifications or restrictions. For example, you might want to create a
[collection type](./collections.md) which behaves like a `vector` but doesn't allow modifying the
elements after they've been inserted. Newtype pattern is a good way to achieve this.

## Definition

The newtype pattern is a design pattern where you create a new type that wraps an existing type. The
new type is a distinct type from the original type, but it may be converted to and from the original
type.

Often it is implemented as a positional struct with a single field.

```move
{{#include ../../../packages/samples/sources/programmability/newtype-pattern.move:main}}
```

## Common Practices

For cases when the goal is extending the behavior of an existing type, it is fairly common to
provide accessors to the wrapped type. This allows the user to still access the underlying type
directly if needed. For example, in the following code, we provide `inner()` and `inner_mut()`
methods to the `Stack` type.

```move
{{#include ../../../packages/samples/sources/programmability/newtype-pattern.move:common}}
```

## Advantages

The newtype pattern has several benefits:

- Allows defining custom functions for an existing type.
- Constrains function signatures to the newtype, thereby making the code more robust.
- Often increases the readability of the code by providing a more descriptive type name.

## Disadvantages

The newtype pattern is a very powerful pattern in two scenarios: when you want to limit the behavior
of an existing type and provide a custom interface to the same data structure, and when you want to
extend the behavior of an existing type. However, it does have some limitations:

- It can be verbose to implement, especially if you want to expose all the methods of the wrapped
  type.
- The implementation can be quite sparse, as it often just forwards the calls to the wrapped type.
