
## Vector

Vector is a collection of any type with no fixed size (aka extendable). Let's start with vector of integers:

```Move
fun main() {
    let a : vector<u8>; // this one usually used to represent strings
}
```

You can define vector using `vector<type>` notation, though you can't access its methods as it has none. To unwrap vector's full potential you have `0x0::Vector` library which will be described in <SECTION>.

Let's just keep it that simple for now.

## Struct

Structures are complex types which may contain fields with different types. When defining a struct you're actually creating new type, and new types can only be defined inside module.

```Move
module CovidTracker {

    struct Covid19Report {
        country_id: u8,
        infected_count: u8,
    }
}
```

## Mixing types with generics

TODO: move somewhere else

Let's assume we have some module

```Move
module CovidTracker {
    struct NewsReport {
        news_source_id: u64,
        infected_count: u64,
    }

    resource struct CovidSituation {
        country_id: u8,
        reports: vector<NewsReport>
    }

    public fun how_many(country: u8): u64 {

    }
}
```

## Visibility modifiers

public | native | <none>
structs are public by default
methods are private unless public modifier is put

## Scope-based syntax and code block { }

## Control structures

Loops (while, loop, break, continue)

## Resources

What is a resource struct {}

How to work with resources

Keyword `acquires`

## Keywords

Strict keywords are reserved keywords which can only be used within certain context, here's a full list of them for Move language ([see full lexer here](https://github.com/libra/libra/blob/master/language/move-lang/src/parser/lexer.rs)):

```Move
"abort" => Tok::Abort,
"acquires" => Tok::Acquires,
"as" => Tok::As,
"break" => Tok::Break,
"continue" => Tok::Continue,
"copy" => Tok::Copy,
"copyable" => Tok::Copyable,
"define" => Tok::Define,
"else" => Tok::Else,
"false" => Tok::False,
"fun" => Tok::Fun,
"if" => Tok::If,
"invariant" => Tok::Invariant,
"let" => Tok::Let,
"loop" => Tok::Loop,
"module" => Tok::Module,
"move" => Tok::Move,
"native" => Tok::Native,
"public" => Tok::Public,
"resource" => Tok::Resource,
"return" => Tok::Return,
"spec" => Tok::Spec,
"struct" => Tok::Struct,
"true" => Tok::True,
"use" => Tok::Use,
"while" => Tok::While
```

## Variable types

Currently Mvir has these primitive types:

- Integer: `u8`, `u64`, `u128`
- Vector: `vector<u8>`
- Boolean: `bool`
- Address: `address`

And two complex types:

- Structure: `struct`
- Resource: `resource`
