---
description: "Dynamic object fields in Sui: attach objects as fields that remain accessible by ID, with differences from regular dynamic fields."
---

# Dynamic Object Fields

> This section expands on [Dynamic Fields](./dynamic-fields). Please read it first to understand
> the basics of dynamic fields.

Another variation of dynamic fields is _dynamic object fields_, which have certain differences from
regular dynamic fields. In this section, we will cover the specifics of dynamic object fields and
explain how they differ from regular dynamic fields.

> The general recommendation is to avoid using dynamic object fields in favor of (just) dynamic fields,
> especially if there's no need for direct discovery through the ID. The extra costs of dynamic
> object fields may not be justified by the benefits they provide.

## Definition

Dynamic Object Fields are defined in the `sui::dynamic_object_field` module in the
[Sui Framework](./sui-framework). They are similar to dynamic fields in many ways, but unlike them,
dynamic object fields have an extra constraint on the `Value` type. The `Value` must have a
combination of `key` and `store`, not just `store` as in the case of dynamic fields.

The module definition is smaller than that of dynamic fields - only the field _name_ gets a
wrapper type, while the value is stored as-is:

```move
module sui::dynamic_object_field;

/// Internal object used for storing the field and the name associated with the
/// value. The separate type is necessary to prevent key collision with direct
/// usage of dynamic_field
public struct Wrapper<Name> has copy, drop, store {
    name: Name,
}
```

Unlike the `Field` type in the [Dynamic Fields](./dynamic-fields#definition) section, the `Wrapper` type
only stores the name of the field. The value is the object itself, and is _not wrapped_.

_See [full documentation for sui::dynamic_object_field][dynamic-object-field-framework] module._

The constraints on the `Value` type become visible in the methods available for dynamic object
fields. Here's the signature for the `add` function:

```move
/// Adds a dynamic object field to the object `object: &mut UID` at field
/// specified by `name: Name`. Aborts with `EFieldAlreadyExists` if the object
/// already has that field with that name.
public fun add<Name: copy + drop + store, Value: key + store>(
    // we use &mut UID in several spots for access control
    object: &mut UID,
    name: Name,
    value: Value,
) { /* implementation omitted */ }
```

The rest of the methods are identical to the ones in the
[Dynamic Fields](./dynamic-fields#usage) section, and carry the same constraint on the `Value`
type. Let's list them for reference:

- `add` - adds a dynamic object field to the object
- `remove` - removes a dynamic object field from the object
- `borrow` - borrows a dynamic object field from the object
- `borrow_mut` - borrows a mutable reference to a dynamic object field from the object
- `exists_` - checks if a dynamic object field exists
- `exists_with_type` - checks if a dynamic object field exists with a specific type

Additionally, there is an `id` method which returns the `ID` of the `Value` object without
specifying its type.

## Usage and Differences with Dynamic Fields

The main difference between dynamic fields and dynamic object fields is that the latter allows
storing _only objects_ as values. This means that you can't store primitive types like `u64` or
`bool`. In exchange for this restriction, the attached object is _not wrapped_ into a separate
object: it keeps its ID and stays visible to offchain tooling.

> This is the property to weigh when choosing between the two: a value attached as a regular
> dynamic field is wrapped into a `Field` object and disappears from ID-based queries, while a
> value attached as a dynamic object field remains discoverable by its ID in wallets and explorers.

```move file=packages/samples/sources/programmability/dynamic-object-fields.move anchor=usage

```

In the example above, the `Accessory` has both `key` and `store`, so it can be attached as a
dynamic object field. The `Metadata`, however, only has `store`, so it can only be attached as a
regular dynamic field. Both kinds of fields coexist on the same `UID` - even under similar names -
because the internal `Wrapper` type prevents key collisions between the two modules. Lastly, the
example demonstrates the `id` function, which returns the `ID` of the attached object without
requiring its type - something only possible because the object keeps its identity.

## Pricing Differences

Dynamic object fields are a little more expensive than dynamic fields. Because of their internal
structure, a single dynamic object field is stored as two objects: an internal field storing the
name, and the value object itself. As a result, the cost of adding and accessing dynamic object
fields (loading 2 objects compared to 1 for dynamic fields) is higher.

## Summary

- Dynamic object fields require the value to be an object (`key` + `store`) and, unlike regular
  dynamic fields, keep the attached object discoverable by its ID in wallets and explorers.
- The methods mirror those of dynamic fields, with an extra `id` function that returns the `ID` of
  the attached object without specifying its type.
- Dynamic object fields are more expensive than dynamic fields, so prefer the latter unless
  ID-based discovery is required.

## Next Steps

Both dynamic fields and dynamic object fields are powerful features which allow for innovative
solutions in applications. However, they are relatively low-level and require careful handling to
avoid orphaned fields. In the next section, we will introduce a higher-level abstraction -
[Dynamic Collections](./dynamic-collections) - which can help with managing dynamic fields and
objects more effectively.

## Further Reading

- [sui::dynamic_object_field][dynamic-object-field-framework] module documentation.

[dynamic-object-field-framework]: https://docs.sui.io/references/framework/sui/dynamic_object_field