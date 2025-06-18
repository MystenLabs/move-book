# Enums and Match

An enum is a user-defined data structure that, unlike a [struct](./struct), can represent multiple
variants. Each variant can contain primitive types, structs, or other enums. However, recursive enum
definitions — similar to recursive struct definitions — are not allowed.

## Definition

An enum is defined using the `enum` keyword, followed by optional abilities and a block of variant
definitions. Each variant has a tag name and may optionally include either positional values or
named fields. Enum must have at least one variant. The structure of each variant is not flexible,
and the total number of variants can be relatively large - up to 100.

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=definition

```

In the code sample above we defined a public `Segment` enum, which has the `drop` and `copy`
abilities, and 3 variants:

- `Empty`, which has no fields.
- `String`, which contains a single positional field of type `String`.
- `Special`, which uses named fields: `content` of type `vector<u8>` and `encoding` of type `u8`.

## Instantiating

Enums are _internal_ to the module in which they are defined. This means an enum can only be
constructed, read, and unpacked within the same module.

[Similar to structs](./struct#create-and-use-an-instance), enums are instantiated by specifying the
type, the variant, and the values for any fields defined in that variant.

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=constructors

```

Depending on the use case, you may want to provide public constructors, or instantiate enums
internally as a part of application logic.

## Using in Type Definitions

The biggest benefit of using enums is the ability to represent varying data structures under a
single type. To demonstrate this, let’s define a struct that contains a vector of `Segment` values:

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=struct

```

All variants of the Segment enum share the same type – `Segment` – which allows us to create a
homogeneous vector containing instances of different variants. This kind of flexibility is not
achievable with structs, as each struct defines a single, fixed shape.

## Pattern Matching

Unlike structs, enums require special handling when it comes to accessing the inner value or
checking the variant. We simply cannot read the inner fields of an enum using the `.` (dot) syntax,
because we need to make sure that the value we are trying to access is the right one. For that Move
offers _pattern matching_ syntax.

> This chapter doesn't intend to cover all the features of pattern matching in Move. Refer to the
> [Pattern Matching](./../../reference/control-flow/pattern-matching) section in the Move Reference.

Pattern matching allows conditioning the logic based on the _pattern_ of the value. It is performed
using the `match` expression, followed by the matched value in parenthesis and the block of _match
arms_, defining the patten and expression to be performed if the pattern is right.

Let's extend our example by adding a set of `is_variant`-like functions, so external packages can
check the variant. Starting with `is_empty`.

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=is_empty

```

The `match` keyword begins the expression, and `s` is the value being tested. Each match arm checks
for a specific variant of the `Segment` enum. If `s` matches `Segment::Empty`, the function returns
`true`; otherwise, it returns `false`.

For variants with fields, we need to bind the inner structure to local variables (even if we don’t
use them, marking unused values with `_` to avoid compiler warnings).

### Trick #1 - _any_ Condition

The Move compiler infers the type of the value used in a `match` expression and ensures that the
_match arms_ are exhaustive – that is, all possible variants or values must be covered.

However, in some cases, such as matching on a primitive value or a collection like a vector, it's
not feasible to list every possible case. For these situations, match supports a wildcard pattern
(`_`), which acts as a default arm. This arm is executed when no other patterns match.

We can demonstrate this by simplifying our `is_empty` function and replacing the non-`Empty`
variants with a wildcard:

```move
public fun is_empty(s: &Segment): bool { file=packages/samples/sources/move-basics/enum-and anchor=matcmove:is_empty_2}}
```

Similarly, we can use the same approach to define `is_special` and `is_string`:

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=accessors

```

### Trick #2 - `try_into` Helpers

With the addition of `is_variant` functions, we enabled external modules to check which variant an
enum instance represents. However, this is often not enough – external code still cannot access the
inner value of a variant due to enums being internal to their module.

A common pattern for addressing this is to define `try_into` functions. These functions match on the
value and return an `Option` containing the inner contents if the `match` succeeds.

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=try_into_inner_string

```

This pattern safely exposes internal data in a controlled way, avoiding abort.

### Trick #3 - Matching on Primitive Values

The `match` expression in Move can be used with values of any type – enums, structs, or primitives.
To demonstrate this, let’s implement a `to_string` function that creates a new `String` from a
`Segment`. In the case of the `Special` variant, we will match on the `encoding` field to determine
how to decode the content.

```move file=packages/samples/sources/move-basics/enum-and-match.move anchor=to_string

```

This function demonstrates two key things:

- Nested `match` expressions can be used for deeper logic branching.
- Wildcards are essential for covering all possible values in primitive types like `u8`.

## The Final Test

Now we can finalize the test we started before using the features we have added. Let's create a
scenario where we build enums into a vector.

```move file=packages/samples/sources/move-basics/enum-and-match-2.move anchor=enum_test

```

This test demonstrates the full enum workflow: instantiating different variants, using public
accessors, and performing logic with pattern matching. That should be enough to get you started!

To learn more about enums and pattern matching, refer to the resources listed in the
[further reading](#further-reading) section.

## Summary

- Enums are user-defined types that can represent multiple variants under a single type.
- Each variant can contain different types of data (primitives, structs, or other enums).
- Enums are internal to their defining module and require pattern matching for access.
- Pattern matching is done using the `match` expression, which:
  - Works with enums, structs, and primitive values;
  - Must handle all possible cases (be exhaustive);
  - Supports the `_` wildcard pattern for remaining cases;
  - Can return values and be used in expressions;
- Common patterns for enums include `is_variant` checks and `try_into` helper functions.

## Further Reading

- [Enums](./../../reference/enums) in the Move Reference
- [Pattern Matching](/reference/control-flow/pattern-matching) in the Move Reference
