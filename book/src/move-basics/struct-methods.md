# Struct Methods

Move Compiler supports _receiver syntax_, which allows defining methods which can be called on
instances of a struct. This is similar to the method syntax in other programming languages. It is a
convenient way to define functions which operate on the fields of a struct.

## Method syntax

If the first argument of a function is a struct internal to the module, then the function can be
called using the `.` operator. If the function uses a struct from another module, then method won't
be associated with the struct by default. In this case, the function can be called using the
standard function call syntax.

When a module is imported, the methods are automatically associated with the struct.

```move
{{#include ../../../packages/samples/sources/move-basics/struct-methods.move:hero}}
```

## Method Aliases

For modules that define multiple structs and their methods, it is possible to define method aliases
to avoid name conflicts, or to provide a better-named method for a struct.

The syntax for aliases is:

```move
// for local method association
use fun function_path as Type.method_name;

// exported alias
public use fun function_path as Type.method_name;
```

> Public aliases are only allowed for structs defined in the same module. If a struct is defined in
> another module, an alias can still be created but cannot be made public.

In the example below, we changed the `hero` module and added another type - `Villain`. Both `Hero`
and `Villain` have similar field names and methods. And to avoid name conflicts, we prefixed methods
with `hero_` and `villain_` respectively. However, we can create aliases for these methods so that
they can be called on the instances of the structs without the prefix.

```move
{{#include ../../../packages/samples/sources/move-basics/struct-methods.move:hero_and_villain}}
```

As you can see, in the test function, we called the `health` method on the instances of `Hero` and
`Villain` without the prefix. The compiler will automatically associate the methods with the
structs.

## Aliasing an external module's method

It is also possible to associate a function defined in another module with a struct from the current
module. Following the same approach, we can create an alias for the method defined in another
module. Let's use the `bcs::to_bytes` method from the [Standard Library](./standard-library.md) and
associate it with the `Hero` struct. It will allow serializing the `Hero` struct to a vector of
bytes.

```move
{{#include ../../../packages/samples/sources/move-basics/struct-methods.move:hero_to_bytes}}
```

## Further reading

- [Method Syntax](/reference/method-syntax.html) in the Move Reference.
