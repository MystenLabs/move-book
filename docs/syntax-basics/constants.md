# Constants

You can define *module* or *script-level* constants. Once defined, constants cannot be changed, and they should be used to define some *constant* values for specific module (say, a role identifier or price for action) or script.

Constants can be defined as primitive types (integers, bool and address) and as a `vector`. They are accessed by their names and are local to script/module where they are defined.

> Accessing constant value from outside of its module is impossible

```Move
script {

    use 0x1::Debug;

    const RECEIVER : address = 0x999;

    fun main(account: &signer) {
        Debug::print<address>(&RECEIVER);

        // they can also be assigned to a variable

        let _ = RECEIVER;

        // but this code leads to compile error
        // RECEIVER = 0x800;
    }
}
```

Same usage in module:

```Move
module M {

    const MAX : u64 = 100;

    // however you can pass constant outside using a function
    public fun get_max(): u64 {
        MAX
    }

    // or using
    public fun is_max(num: u64): bool {
        num == MAX
    }
}
```

What is important to know about constants:

1. They are unchangeable once defined;
2. They are local to their module or script and cannot be used outside;
3. Usually they are used to define module-level constant value which serves some business purpose;
4. It is also possible to define constant as an expression (with curly braces) but syntax of this expression is very limited.

### Further reading

- [PR with constant syntax](https://github.com/libra/libra/pull/4653)
