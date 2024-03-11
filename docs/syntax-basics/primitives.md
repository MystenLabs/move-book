# Primitive Types

Move has few built-in primitive types to represent numbers, addresses and boolean values: integers (u8, u64, u128), `boolean` and `address`.

Move does not have string type or floating point numbers.

## Integer types

Integers are represented by `u8`, `u64` and `u128`; Possible integer notations are:

```Move
script {
    fun main() {
        // define empty variable, set value later
        let a: u8;
        a = 10;

        // define variable, set type
        let a: u64 = 10;

        // finally simple assignment
        let a = 10;

        // simple assignment with defined value type
        let a = 10u128;

        // in function calls or expressions you can use ints as constant values
        if (a < 10) {};

        // or like this, with type
        if (a < 10u8) {}; // usually you don't need to specify type
    }
}
```

### Operator `as`

When you need to compare values or when function argument requires integer of different size you can cast your integer variable to another size by using operator `as`:

```Move
script {
    fun main() {
        let a: u8 = 10;
        let b: u64 = 100;

        // we can only compare same size integers
        if (a == (b as u8)) abort 11;
        if ((a as u64) == b) abort 11;
    }
}
```

## Boolean

Boolean type is just the one you're used to. Two constant values: `false` and `true` - both can only mean one thing - a value of `bool` type.

```Move
script {
    fun main() {
        // these are all the ways to do it
        let b : bool; b = true;
        let b : bool = true;
        let b = true;
        let b = false; // here's an example with false
    }
}
```

## Address

Address is an identifier of sender (or wallet) in blockchain. The very basic operations which require address type are sending coins and importing modules.

```Move
script {
    fun main() {
        let addr: address; // type identifier

        // in this book I'll use {{sender}} notation;
        // always replace `{{sender}}` in examples with VM specific address!!!
        addr = {{sender}};

        // in Diem's Move VM and Starcoin - 16-byte address in HEX
        addr = 0x...;

        // in dfinance's DVM - bech32 encoded address with `wallet1` prefix
        addr = wallet1....;
    }
}
```
