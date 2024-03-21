# Collections

Collection types are a fundamental part of any programming language. They are used to store a collection of data, such as a list of items. The `vector` type has already been covered in the [vector section](../basic-syntax/standard-library.md), and in this chapter we will cover the collection types offered by the Sui Framework.

- [VecSet](#VecSet)
- [VecMap](#VecMap)

## VecSet

`VecSet` is a collection type that stores a set of unique items. It is similar to a `vector`, but it does not allow duplicate items. This makes it useful for storing a collection of unique items, such as a list of unique IDs or addresses.

```move
{{#include ../../samples/sources/programmability/collections.move:vec_set}}
```

## VecMap

`VecMap` is a collection type that stores a map of key-value pairs. It is similar to a `VecSet`, but it allows you to associate a value with each item in the set. This makes it useful for storing a collection of key-value pairs, such as a list of addresses and their balances, or a list of user IDs and their associated data.

Keys in a `VecMap` are unique, and each key can only be associated with a single value. If you try to insert a key-value pair with a key that already exists in the map, the old value will be replaced with the new value.

```move
{{#include ../../samples/sources/programmability/collections.move:vec_map}}
```
