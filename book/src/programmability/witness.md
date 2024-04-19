# Pattern: Witness

Abilities system allows certain behaviours which wouldn't be possible otherwise. For example, it is
possible to define a struct with only `drop` ability: it can be passed around but never stored and
copied. This specific example is what is called a _Witness_ type.

## Background

<!--

Witness truly shines in generic implementations while acting as a proof of ownership of a single type. Unlike Capability, which can be considered a "dynamic authorization" mechanism, Witness can be described as a "static" authorization tool.

-->

## Definition

The very basic definition of the witness is a type that has a `drop` ability. On Sui, it
automatically conflicts with `key` ability, so using an Object as a witness is not possible, there
are other patterns involving objects such as Capability.

```move
/// A very basic Witness type. Can be used to initialize a generic type.
public struct Witness has drop {}
```

## Generic Instantiation

Witnesses are mainly used to instantiate a generic type with a specific type parameter - the witness
itself. For example, if there's a generic `Coin<T>`, where the `T` is a type parameter, a witness
may be used to create it.

## Further Reading

- Witness does provide a way to instantiate a generic type, however, it does not guarantee
  uniqueness of this action. To answer this need and provide more safety and guarantees for
  instantiation, Sui offers the [One Time Witness](./one-time-witness.md) feature.
- Most of the generic types in the Sui Framework require a witness (or a One Time Witness), we go in
  deeper in the topic in the [Balance & Coin](./balance-and-coin.md) section.
