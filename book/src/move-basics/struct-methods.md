# Struct Methods

Move Compiler supports _receiver syntax_ `e.f()`, which allows defining methods which can be called on
instances of a struct. The term "receiver" specifically refers to the instance that receives the
method call. This is like the method syntax in other programming languages. It is a
convenient way to define functions that operate on the fields of a struct, providing direct access
to the struct's fields and creating cleaner, more intuitive code than passing the struct as a parameter.

## Method syntax

If the first argument of a function is a struct internal to the module that
defines the function, then the function can be called using the `.` operator.
However, if the type of the first argument is defined in another module, then
method won't be associated with the struct by default. In this case, the `.`
operator syntax is not available, and the function must be called using
standard function call syntax.

When a module is imported, its methods are automatically associated with the struct.

```move
{{#include ../../../packages/samples/sources/move-basics/struct-methods.move:hero}}
```

## Method Aliases

Method aliases help avoid name conflicts when modules define multiple structs and their methods.
They can also provide more descriptive method names for structs.

Here's the syntax:

```move
// for local method association
use fun function_path as Type.method_name;

// exported alias
public use fun function_path as Type.method_name;
```

> Public aliases are only allowed for structs defined in the same module. For structs defined in
> other modules, aliases can still be created but cannot be made public.

In the example below, we changed the `hero` module and added another type - `Villain`. Both `Hero`
and `Villain` have similar field names and methods. To avoid name conflicts, we prefixed methods
with `hero_` and `villain_` respectively. However, using aliases allows these methods to be called
on struct instances without the prefix:

```move
{{#include ../../../packages/samples/sources/move-basics/struct-methods-2.move:hero_and_villain}}
```

In the test function, the `health` method is called directly on the `Hero` and `Villain` instances
without the prefix, as the compiler automatically associates the methods with their respective
structs.

> Note: In the test function, `hero.health()` is calling the aliased method, not directly accessing
> the private `health` field. While the `Hero` and `Villain` structs are public, their fields remain private
> to the module. The method call `hero.health()` uses the public alias defined by `public use fun
> hero_health as Hero.health`, which provides controlled access to the private field.

## Aliasing an external module's method

It is also possible to associate a function defined in another module with a struct from the current
module. Following the same approach, we can create an alias for the method defined in another
module. Let's use the `bcs::to_bytes` method from the [Standard Library](./standard-library.md) and
associate it with the `Hero` struct. It will allow serializing the `Hero` struct to a vector of
bytes.

```move
{{#include ../../../packages/samples/sources/move-basics/struct-methods-3.move:hero_to_bytes}}
```

## Further reading

- [Method Syntax](/reference/method-syntax.html) in the Move Reference.
