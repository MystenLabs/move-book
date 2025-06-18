# Code Quality Checklist

The rapid evolution of the Move language and its ecosystem has rendered many older practices
outdated. This guide serves as a checklist for developers to review their code and ensure it aligns
with current best practices in Move development. Please read carefully and apply as many
recommendations as possible to your code.

## Code Organization

Some of the issues mentioned in this guide can be fixed by using
[Move Formatter](https://www.npmjs.com/package/@mysten/prettier-plugin-move) either as a CLI tool,
or [as a CI check](https://github.com/marketplace/actions/move-formatter), or
[as a plugin for VSCode (Cursor)](https://marketplace.visualstudio.com/items?itemName=mysten.prettier-move).

## Package Manifest

### Use Right Edition

All of the features in this guide require Move 2024 Edition, and it has to be specified in the
package manifest.

```toml
[package]
name = "my_package"
edition = "2024.beta" # or (just) "2024"
```

### Implicit Framework Dependency

Starting with Sui 1.45 you no longer need to specify framework dependency in the `Move.toml`:

```toml
# old, pre 1.45
[dependencies]
Sui = { ... }

# modern day, Sui, Bridge, MoveStdlib and SuiSystem are imported implicitly!
[dependencies]
```

### Prefix Named Addresses

If your package has a generic name (e.g., `token`) – especially if your project includes multiple
packages – make sure to add a prefix to the named address:

```toml
# bad! not indicative of anything, and can conflict
[addresses]
math = "0x0"

# good! clearly states project, unlikely to conflict
[addresses]
my_protocol_math = "0x0"
```

## Imports, Module and Constants

### Using Module Label

```move
// bad: increases indentation, legacy style
module my_package::my_module {
    public struct A {}
}

// good!
module my_package::my_module;

public struct A {}
```

### No Single `Self` in `use` Statements

```move
// correct, member + self import
use my_package::other::{Self, OtherMember};

// bad! `{Self}` is redundant
use my_package::my_module::{Self};

// good!
use my_package::my_module;
```

### Group `use` Statements with `Self`

```move
// bad!
use my_package::my_module;
use my_package::my_module::OtherMember;

// good!
use my_package::my_module::{Self, OtherMember};
```

### Error Constants are in `EPascalCase`

```move
// bad! all-caps are used for regular constants
const NOT_AUTHORIZED: u64 = 0;

// good! clear indication it's an error constant
const ENotAuthorized: u64 = 0;
```

### Regular Constant are `ALL_CAPS`

```move
// bad! PascalCase is associated with error consts
const MyConstant: vector<u8> = b"my const";

// good! clear indication that it's a constant value
const MY_CONSTANT: vector<u8> = b"my const";
```

## Structs

### Capabilities are Suffixed with `Cap`

```move
// bad! if it's a capability, add a `Cap` suffix
public struct Admin has key, store {
    id: UID,
}

// good! reviewer knows what to expect from type
public struct AdminCap has key, store {
    id: UID,
}
```

### No `Potato` in Names

```move
// bad! it has no abilities, we already know it's a Hot-Potato type
public struct PromisePotato {}

// good!
public struct Promise {}
```

### Events Should Be Named in Past Tense

```move
// bad! not clear what this struct does
public struct RegisterUser has copy, drop { user: address }

// good! clear, it's an event
public struct UserRegistered has copy, drop { user: address }
```

### Use Positional Structs for Dynamic Field Keys + `Key` Suffix

```move
// not as bad, but goes against canonical style
public struct DynamicField has copy, drop, store {}

// good! canonical style, Key suffix
public struct DynamicFieldKey() has copy, drop, store;
```

## Functions

### No `public entry`, Only `public` or `entry`

```move
// bad! entry is not required for a function to be callable in a transaction
public entry fun do_something() { /* ... */ }

// good! public functions are more permissive, can return value
public fun do_something_2(): T { /* ... */ }
```

### Write Composable Functions for PTBs

```move
// bad! not composable, harder to test!
public fun mint_and_transfer(ctx: &mut TxContext) {
    /* ... */
    transfer::transfer(nft, ctx.sender());
}

// good! composable!
public fun mint(ctx: &mut TxContext): NFT { /* ... */ }

// good! intentionally not composable
entry fun mint_and_keep(ctx: &mut TxContext) { /* ... */ }
```

### Objects Go First (Except for Clock)

```move
// bad! hard to read!
public fun call_app(
    value: u8,
    app: &mut App,
    is_smth: bool,
    cap: &AppCap,
    clock: &Clock,
    ctx: &mut TxContext,
) { /* ... */ }

// good!
public fun call_app(
    app: &mut App,
    cap: &AppCap,
    value: u8,
    is_smth: bool,
    clock: &Clock,
    ctx: &mut TxContext,
) { /* ... */ }
```

### Capabilities Go Second

```move
// bad! breaks method associativity
public fun authorize_action(cap: &AdminCap, app: &mut App) { /* ... */ }

// good! keeps Cap visible in the signature and maintains `.calls()`
public fun authorize_action(app: &mut App, cap: &AdminCap) { /* ... */ }
```

### Getters Named After Field + `_mut`

```move
// bad! unnecessary `get_`
public fun get_name(u: &User): String { /* ... */ }

// good! clear that it accesses field `name`
public fun name(u: &User): String { /* ... */ }

// good! for mutable references use `_mut`
public fun details_mut(u: &mut User): &mut Details { /* ... */ }
```

## Function Body: Struct Methods

### Common Coin Operations

```move
// bad! legacy code, hard to read!
let paid = coin::split(&mut payment, amount, ctx);
let balance = coin::into_balance(paid);

// good! struct methods make it easier!
let balance = payment.split(amount, ctx).into_balance();

// even better (in this example - no need to create temporary coin)
let balance = payment.balance_mut().split(amount);

// also can do this!
let coin = balance.into_coin(ctx);
```

### Do Not Import `std::string::utf8`

```move
// bad! unfortunately, very common!
use std::string::utf8;

let str = utf8(b"hello, world!");

// good!
let str = b"hello, world!".to_string();

// also, for ASCII string
let ascii = b"hello, world!".to_ascii_string();
```

### UID has `delete`

```move
// bad!
object::delete(id);

// good!
id.delete();
```

### `ctx` has `sender()`

```move
// bad!
tx_context::sender(ctx);

// good!
ctx.sender()
```

### Vector Has a Literal. And Associated Functions

```move
// bad!
let mut my_vec = vector::empty();
vector::push_back(&mut my_vec, 10);
let first_el = vector::borrow(&my_vec);
assert!(vector::length(&my_vec) == 1);

// good!
let mut my_vec = vector[10];
let first_el = my_vec[0];
assert!(my_vec.length() == 1);
```

### Collections Support Index Syntax

```move
let x: VecMap<u8, String> = /* ... */;

// bad!
x.get(&10);
x.get_mut(&10);

// good!
&x[&10];
&mut x[&10];
```

## Option -> Macros

### Destroy And Call Function

```move
// bad!
if (opt.is_some()) {
    let inner = opt.destroy_some();
    call_function(inner);
};

// good! there's a macro for it!
opt.do!(|value| call_function(value));
```

### Destroy Some With Default

```move
let opt = option::none();

// bad!
let value = if (opt.is_some()) {
    opt.destroy_some()
} else {
    abort EError
};

// good! there's a macro!
let value = opt.destroy_or!(default_value);

// you can even do abort on `none`
let value = opt.destroy_or!(abort ECannotBeEmpty);
```

## Loops -> Macros

### Do Operation N Times

```move
// bad! hard to read!
let mut i = 0;
while (i < 32) {
    do_action();
    i = i + 1;
};

// good! any uint has this macro!
32u8.do!(|_| do_action());
```

### New Vector From Iteration

```move
// harder to read!
let mut i = 0;
let mut elements = vector[];
while (i < 32) {
    elements.push_back(i);
    i = i + 1;
};

// easy to read!
vector::tabulate!(32, |i| i);
```

### Do Operation on Every Element of a Vector

```move
// bad!
let mut i = 0;
while (i < vec.length()) {
    call_function(&vec[i]);
    i = i + 1;
};

// good!
vec.do_ref!(|e| call_function(e));
```

### Destroy a Vector and Call a Function on Each Element

```move
// bad!
while (!vec.is_empty()) {
    call(vec.pop_back());
};

// good!
vec.destroy!(|e| call(e));
```

### Fold Vector Into a Single Value

```move
// bad!
let mut aggregate = 0;
let mut i = 0;

while (i < source.length()) {
    aggregate = aggregate + source[i];
    i = i + 1;
};

// good!
let aggregate = source.fold!(0, |acc, v| {
    acc + v
});
```

### Filter Elements of the Vector

> Note: `T: drop` in the `source` vector

```move
// bad!
let mut filtered = [];
let mut i = 0;
while (i < source.length()) {
    if (source[i] > 10) {
        filtered.push_back(source[i]);
    };
    i = i + 1;
};

// good!
let filtered = source.filter!(|e| e > 10);
```

## Other

### Ignored Values In Unpack Can Be Ignored Altogether

```move
// bad! very sparse!
let MyStruct { id, field_1: _, field_2: _, field_3: _ } = value;
id.delete();

// good! 2024 syntax
let MyStruct { id, .. } = value;
id.delete();
```

## Testing

### Merge `#[test]` and `#[expected_failure(...)]`

```move
// bad!
#[test]
#[expected_failure]
fun value_passes_check() {
    abort
}

// good!
#[test, expected_failure]
fun value_passes_check() {
    abort
}
```

### Do Not Clean Up `expected_failure` Tests

```move
// bad! clean up is not necessary
#[test, expected_failure(abort_code = my_app::EIncorrectValue)]
fun try_take_missing_object_fail() {
    let mut test = test_scenario::begin(@0);
    my_app::call_function(test.ctx());
    test.end();
}

// good! easy to see where test is expected to fail
#[test, expected_failure(abort_code = my_app::EIncorrectValue)]
fun try_take_missing_object_fail() {
    let mut test = test_scenario::begin(@0);
    my_app::call_function(test.ctx());

    abort // will differ from EIncorrectValue
}
```

### Do Not Prefix Tests With `test_` in Testing Modules

```move
// bad! the module is already called _tests
module my_package::my_module_tests;

#[test]
fun test_this_feature() { /* ... */ }

// good! better function name as the result
#[test]
fun this_feature_works() { /* ... */ }
```

### Do Not Use `TestScenario` Where Not Necessary

```move
// bad! no need, only using ctx
let mut test = test_scenario::begin(@0);
let nft = app::mint(test.ctx());
app::destroy(nft);
test.end();

// good! there's a dummy context for simple cases
let ctx = &mut tx_context::dummy();
app::mint(ctx).destroy();
```

### Do Not Use Abort Codes in `assert!` in Tests

```move
// bad! may match application error codes by accident
assert!(is_success, 0);

// good!
assert!(is_success);
```

### Use `assert_eq!` Whenever Possible

```move
// bad! old-style code
assert!(result == b"expected_value", 0);

// good! will print both values if fails
use std::unit_test::assert_eq;

assert_eq!(result, expected_value);
```

### Use "Black Hole" `destroy` Function

```move
// bad!
nft.destroy_for_testing();
app.destroy_for_testing();

// good! - no need to define special functions for cleanup
use sui::test_utils::destroy;

destroy(nft);
destroy(app);
```

## Comments

### Doc Comments Start With `///`

```move
// bad! tooling does't support JavaDoc-style comments
/**
 * Cool method
 * @param ...
 */
public fun do_something() { /* ... */ }

// good! will be rendered as a doc comment in docgen and IDE's
/// Cool method!
public fun do_something() { /* ... */ }
```

### Complex Logic? Leave a Comment `//`

Being friendly and helping reviewers understand the code!

```move
// good!
// Note: can underflow if a value is smaller than 10.
// TODO: add an `assert!` here
let value = external_call(value, ctx);
```
