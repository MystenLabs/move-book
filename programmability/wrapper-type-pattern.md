> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Pattern: Wrapper Type

Sometimes, there's a need to create a new type that behaves similarly to an existing type but with
certain modifications or restrictions. For example, you might want to create a
[collection type](./collections) that behaves like a vector but doesn’t allow modifying the elements
after they’ve been inserted. The wrapper type pattern is an effective way to achieve this.

## Definition

The wrapper type pattern is a design pattern in which you create a new type that wraps an existing
type. The wrapper type is distinct from the original but can be converted to and from it.

Often, it is implemented as a [positional struct](./../move-basics/struct.md#positional-structs)
with a single field.

```move
module book::wrapper_type_pattern;

/// Very simple stack implementation using the wrapper type pattern. Does not allow
/// accessing the elements unless they are popped.
public struct Stack<T>(vector<T>) has copy, store, drop;

/// Create a new instance by wrapping the value.
public fun new<T>(value: vector<T>): Stack<T> {
    Stack(value)
}

/// Push an element to the stack.
public fun push_back<T>(v: &mut Stack<T>, el: T) {
    v.0.push_back(el);
}

/// Pop an element from the stack. Unlike `vector`, this function won't
/// fail if the stack is empty and will return `None` instead.
public fun pop_back<T>(v: &mut Stack<T>): Option<T> {
    if (v.0.length() == 0) option::none()
    else option::some(v.0.pop_back())
}

/// Get the size of the stack.
public fun size<T>(v: &Stack<T>): u64 {
    v.0.length()
}
```

## Common Practices

In cases where the goal is to extend the behavior of an existing type, it is common to provide
accessors for the wrapped type. This approach allows users to access the underlying type directly
when needed. For example, in the following code, we provide the `inner()`, `inner_mut()`, and
`into_inner()` methods for the Stack type.

```move
/// Allows reading the contents of the `Stack`.
public fun inner<T>(v: &Stack<T>): &vector<T> { &v.0 }

/// Allows mutable access to the contents of the `Stack`.
public fun inner_mut<T>(v: &mut Stack<T>): &mut vector<T> { &mut v.0 }

/// Unpacks the `Stack` into the underlying `vector`.
public fun into_inner<T>(v: Stack<T>): vector<T> {
    let Stack(inner) = v;
    inner
}
```

## Advantages

The wrapper type pattern offers several benefits:

- Custom Functions: It allows you to define custom functions for an existing type.
- Robust Function Signatures: It constrains function signatures to the new type, thereby making the
  code more robust.
- Improved Readability: It often increases the readability of the code by providing a more
  descriptive type name.

## Disadvantages

The wrapper type pattern is powerful in two scenarios - when you want to limit the behavior of an
existing type while providing a custom interface to the same data structure, and when you want to
extend the behavior of an existing type. However, it does have some limitations:

- Verbosity: It can be verbose to implement, especially if you want to expose all the methods of the
  wrapped type.
- Sparse Implementation: The implementation can be quite minimal, as it often just forwards calls to
  the wrapped type.

## Next Steps

The wrapper type pattern is very useful, particularly when used in conjunction with collection
types, as demonstrated in the previous section. In the next section, we will cover
[Dynamic Fields](./dynamic-fields) - an important primitive that enables
[Dynamic Collections](./dynamic-collections), a way to store large collections of data in a more
flexible, albeit more expensive, way.
