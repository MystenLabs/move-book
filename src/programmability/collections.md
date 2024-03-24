# Collections

Collection types are a fundamental part of any programming language. They are used to store a collection of data, such as a list of items. The `vector` type has already been covered in the [vector section](./../basic-syntax/vector.md), and in this chapter we will cover the collection types offered by the [Sui Framework](./sui-framework.md).

- [vector](#vector)
- [VecSet](#VecSet)
- [VecMap](#VecMap)

## Vector

While we have previously covered the `vector` type in the [vector section](./../basic-syntax/vector.md), it is worth going over it again in a new context. This time we will cover the usage of the `vector` type in objects and how it can be used in an application.

```move
// >insert collection vector code here<
```

## VecSet

`VecSet` is a collection type that stores a set of unique items. It is similar to a `vector`, but it does not allow duplicate items. This makes it useful for storing a collection of unique items, such as a list of unique IDs or addresses.

```move
{{#include ../../packages/samples/sources/programmability/collections.move:vec_set}}
```

## VecMap

`VecMap` is a collection type that stores a map of key-value pairs. It is similar to a `VecSet`, but it allows you to associate a value with each item in the set. This makes it useful for storing a collection of key-value pairs, such as a list of addresses and their balances, or a list of user IDs and their associated data.

Keys in a `VecMap` are unique, and each key can only be associated with a single value. If you try to insert a key-value pair with a key that already exists in the map, the old value will be replaced with the new value.

```move
{{#include ../../packages/samples/sources/programmability/collections.move:vec_map}}
```
