# Abstract Class

<!-- Walk through a Coin example -->

Some of the language features combined together can create patterns that are similar to other programming languages. The simplest example would be "getters and setters" - functions that get and set the value of a field. This pattern is possible, because struct fields are private by default, and can only be accessed through functions.

However, there are more advanced patterns, such as the abstract class. An abstract class is a class that cannot be instantiated, but can be inherited from. While Move does not have inheritance, it has generic structs, which can be instantiated with different types. This allows us to create a generic struct that can be used as an abstract class. Combined with a set of Witness-gated functions, this allows us to create a generic struct with a generic implementation.

Some of the methods in this approach will be shared and available to all implementations, while others will be abstract and will need to be implemented by the concrete implementations.

## Generic Struct

<!--

Talk through Generic Struct and how it can be instantiated with a witness.

 -->


## Common methods

<!--

Showcase how common methods can be implemented for a generic struct.

 -->

## Witness-gated Functions

<!--

Showcase how witness-gated functions can be used to implement abstract methods.

 -->

## Differences from OOP

While this approach imitates the abstract class pattern well, it is not the same as the abstract class in OOP. The main difference is that the abstract class in OOP and its implementors have different type. In Move, the base type stays the same, and the implementors set a generic type parameter. Another notable difference is that due to lack of dynamic dispatch and interfaces, the implemented methods are not available through the base type and can even be missing.

## Usage in Sui Framework

The Sui Framework uses this pattern to implement the `Coin` type and the underlying `Balance`. Its variation is also used in the Closed Loop Token implementation, however, the latter is a bit more complex, because it uses the Request pattern to dynamically implement the interface.
