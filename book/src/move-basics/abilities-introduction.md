# Abilities: Introduction

Move has a unique type system which allows customizing _type abilities_. [In the previous section](./struct.md), we introduced the `struct` definition and how to use it. However, the instances of the `Artist` and `Record` structs had to be unpacked for the code to compile. This is default behavior of a struct without _abilities_.

## What are Abilities?

Abilities are a way to allow certain behavious for a type. In Move, abilities are set on a struct declaration and define which behaviours are allowed for the instances of the struct.

## Abilities syntax

Abilities are set in the struct definition using the `has` keyword followed by a list of abilities. The abilities are separated by commas. Move supports 4 abilities: `copy`, `drop`, `key`, and `store`. In this section, we cover the first two abilities: `copy` and `drop`. The last two abilities are covered [in the programmability chapter](./../programmability/README.md), when we introduce Objects and storage operations.

```move
/// This struct has the `copy` and `drop` abilities.
struct VeryAble has copy, drop {
    // field: Type1,
    // field2: Type2,
    // ...
}
```

## No abilities

A struct without abilities cannot be discarded, or copied, or stored in the storage. We call such a struct a _Hot Potato_. It is a joke, but it is also a good way to remember that a struct without abilities is like a hot potato - it needs to be passed around and handled properly. Hot Potato is one of the most powerful patterns in Move, we go in detail about it in the [TODO: authorization patterns](./../programmability/authorization-patterns.md) chapter.

## Further reading

- [Type Abilities](/reference/type-abilities.html) in the Move Language Reference.
