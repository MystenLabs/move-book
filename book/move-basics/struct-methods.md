---
description: "Struct methods in Move: use receiver syntax to call functions on struct instances with dot notation for cleaner code."
---

# Struct Methods

Throughout the previous sections we have called functions on values with the dot operator:
`v.length()`, `opt.is_some()`, `artist.name()`. This is the _receiver syntax_ - "receiver" refers
to the instance that receives the method call - and this section explains how it works and how to
control it. Methods make code that operates on a struct read naturally: the value comes first, the
operation follows, and there is no need to import or spell out the function's module.

## Method Syntax

The core rule: a function is callable with the `.` operator when its first argument is a struct
defined in the _same module_ as the function. Such methods are automatically available everywhere
the struct is used - this is exactly why `vector` and `Option` values could be called with the dot
syntax as soon as we had them. If the type of the first argument is defined in another module, the
function is not associated with the struct by default and must be called with the standard function
call syntax - unless an _alias_ is declared, as shown below.

```move file=packages/samples/sources/move-basics/struct-methods.move anchor=hero

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

```move file=packages/samples/sources/move-basics/struct-methods-2.move anchor=hero_and_villain

```

In the test function, the `health` method is called directly on the `Hero` and `Villain` instances
without the prefix, as the compiler automatically associates the methods with their respective
structs.

> Note: In the test function, `hero.health()` is calling the aliased method, not directly accessing
> the private `health` field. While the `Hero` and `Villain` structs are public, their fields remain
> private to the module. The method call `hero.health()` uses the public alias defined by
> `public use fun hero_health as Hero.health`, which provides controlled access to the private
> field.

## Aliasing a Method of an External Type

Aliases are not limited to the module's own structs: a local (non-public) alias can attach a method
name to a type from another module. Here we give the standard `String` type an extra method name,
`num_bytes` - a more precise name for what its `length` function actually counts:

```move file=packages/samples/sources/move-basics/struct-methods-3.move anchor=string_alias

```

The alias only exists within the module that declares it - which is exactly why it cannot be
`public`: the module does not own the `String` type, so it cannot extend its interface for everyone
else.

## Further Reading

- [Method Syntax](./../../reference/method-syntax) in the Move Reference.
