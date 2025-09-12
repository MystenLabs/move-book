# Type Reflection

In programming languages, _reflection_ is the ability of a program to examine and modify its own
structure and behavior. Move supports a limited form of reflection that lets you inspect the type of
a value at runtime. This is handy when you need to store type information in a homogeneous
collection, or when you want to check if a type comes from a particular package.

Type reflection is implemented in the [Standard Library](./standard-library) module
[`std::type_name`][type-name-stdlib]. It provides a set of functions, main of which are
`with_defining_ids` and `with_original_ids`.

```move
let defining_type_name: TypeName = type_name::with_defining_ids<T>();
let original_type_name: TypeName = type_name::with_original_ids<T>();

// Returns only "ID" of the package.
let defining_package: address = type_name::defining_id<T>();
let original_package: address = type_name::original_id<T>();
```

## Defining IDs vs. Original IDs

It is important to understand the difference between _defining ID_ and _original ID_.

- Original ID is the first published ID of the package (before the first upgrade).
- Defining ID is the package ID which introduced the reflected type, this property becomes crucial
  when new types are introduced in package upgrades.

For example, suppose the first version of a package was published at `0xA` and introduced the type
`Version1`. Later, in an upgrade, the package moved to address `0xB` and introduced a new type
`Version2`.

```move
// Note: values `0xA` and `0xB` are used for illustration purposes only!
// Don't attempt to run this code, as it will inevitably fail.
module book::upgrade;

// Introduced in initial version.
// Defining ID: 0xA
// Original ID: 0xA
//
// With Defining IDs: 0xA::upgrade::Version1
// With Original IDs: 0xA::upgrade::Version1
public struct Version1 has drop {}

// Introduced in a package upgrade.
// Defining ID: 0xB
// highlight-important
// Original ID: 0xA
//
// With Defining IDs: 0xB::upgrade::Version2
// highlight-important
// With Original IDs: 0xA::upgrade::Version2
public struct Version2 has drop {}
```

## In practice

The module is straightforward, and operations allowed on the result are limited to getting a string
representation and extracting the module and address of the type.

```move file=packages/samples/sources/move-basics/type-reflection.move anchor=main

```

## Further Reading

- [std::type_name][type-name-stdlib] module documentation.

[type-name-stdlib]: https://docs.sui.io/references/framework/std/type_name
