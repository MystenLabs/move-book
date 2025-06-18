---
title: 'Macro Functions | Reference'
description: ''
---

# Macro Functions

Macro functions are a way of defining functions that are expanded during compilation at each call
site. The arguments of the macro are not evaluated eagerly like a normal function, and instead are
substituted by expression. In addition, the caller can supply code to the macro via
[lambdas](#lambdas).

These expression substitution mechanics make `macro` functions similar
[to macros found in other programming languages](<https://en.wikipedia.org/wiki/Macro_(computer_science)>);
however, they are more constrained in Move than you might expect from other languages. The
parameters and return values of `macro` functions are still typed--though this can be partially
relaxed with the [`_` type](./../generics#_-type). The upside of this restriction however, is that
`macro` functions can be used anywhere a normal function can be used, which is notably helpful with
[method syntax](./../method-syntax).

A more extensive
[syntactic macro](<https://en.wikipedia.org/wiki/Macro_(computer_science)#Syntactic_macros>) system
may come in the future.

## Syntax

`macro` functions have a similar syntax to normal functions. However, all type parameter names and
all parameter names must start with a `$`. Note that `_` can still be used by itself, but not as a
prefix, and `$_` must be used instead.

```text
<visibility>? macro fun <identifier><[$type_parameters: constraint],*>([$identifier: type],*): <return_type> <function_body>
```

For example, the following `macro` function takes a vector and a lambda, and applies the lambda to
each element of the vector to construct a new vector.

```move
macro fun map<$T, $U>($v: vector<$T>, $f: |$T| -> $U): vector<$U> {
    let mut v = $v;
    v.reverse();
    let mut i = 0;
    let mut result = vector[];
    while (!v.is_empty()) {
        result.push_back($f(v.pop_back()));
        i = i + 1;
    };
    result
}
```

The `$` is there to indicate that the parameters (both type and value parameters) do not behave like
their normal, non-macro counterparts. For type parameters, they can be instantiated with any type
(even a reference type `&` or `&mut`), and they will satisfy any constraint. Similarly for
parameters, they will not be evaluated eagerly, and instead the argument expression will be
substituted at each usage.

## Lambdas

Lambdas are a new type of expression that can only be used with `macro`s. These are used to pass
code from the caller into the body of the `macro`. While the substitution is done at compile time,
they are used similarly to [anonymous functions](https://en.wikipedia.org/wiki/Anonymous_function),
[lambdas](https://en.wikipedia.org/wiki/Lambda_calculus), or
[closures](<https://en.wikipedia.org/wiki/Closure_(computer_programming)>) in other languages.

As seen in the example above (`$f: |$T| -> $U`), lambda types are defined with the syntax

```text
|<type>,*| (-> <type>)?
```

A few examples

```move
|u64, u64| -> u128 // a lambda that takes two u64s and returns a u128
|&mut vector<u8>| -> &mut u8 // a lambda that takes a &mut vector<u8> and returns a &mut u8
```

If the return type is not annotated, it is unit `()` by default.

```move
// the following are equivalent
|&mut vector<u8>, u64|
|&mut vector<u8>, u64| -> ()
```

Lambda expressions are then defined at the call site of the `macro` with the syntax

```text
|(<identifier> (: <type>)?),*| <expression>
|(<identifier> (: <type>)?),*| -> <type> { <expression> }
```

Note that if the return type is annotated, the body of the lambda must be enclosed in `{}`.

Using the `map` macro defined above

```move
let v = vector[1, 2, 3];
let doubled: vector<u64> = map!(v, |x| 2 * x);
let bytes: vector<vector<u8>> = map!(v, |x| std::bcs::to_bytes(&x));
```

And with type annotations

```move
let doubled: vector<u64> = map!(v, |x: u64| 2 * x); // return type annotation optional
let bytes: vector<vector<u8>> = map!(v, |x: u64| -> vector<u8> { std::bcs::to_bytes(&x) });
```

### Capturing

Lambda expressions can also refer to variables in the scope where the lambda is defined. This is
sometimes called "capturing".

```move
let res = foo();
let incremented = map!(vector[1, 2, 3], |x| x + res);
```

Any variable can be captured, including mutable and immutable references.

See the [Examples](#iterating-over-a-vector) section for more complicated usages.

### Limitations

Currently, lambdas can only be used directly in the call of a `macro` function. They cannot be bound
to a variable. For example, the following is code will produce an error:

```move
let f = |x| 2 * x;
//      ^^^^^^^^^ Error! Lambdas must be used directly in 'macro' calls
let doubled: vector<u64> = map!(vector[1, 2, 3], f);
```

## Typing

Like normal functions, `macro` functions are typed--the types of the parameters and return value
must be annotated. However, the body of the function is not type checked until the macro is
expanded. This means that not all usages of a given macro may be valid. For example

```move
macro fun add_one<$T>($x: $T): $T {
    $x + 1
}
```

The above macro will not type check if `$T` is not a primitive integer type.

This can be particularly useful in conjunction with [method syntax](./../method-syntax), where the
function is not resolved until after the macro is expanded.

```move
macro fun call_foo<$T, $U>($x: $T): &$U {
    $x.foo()
}
```

This macro will only expand successfully if `$T` has a method `foo` that returns a reference `&$U`.
As described in the [hygiene](#hygiene) section, `foo` will be resolved based on the scope where
`call_foo` was defined--not where it was expanded.

### Type Parameters

Type parameters can be instantiated with any type, including reference types `&` and `&mut`. They
can also be instantiated with [tuple types](./../primitive-types/tuples), though the utility of this
is limited currently since tuples cannot be bound to a variable.

This relaxation forces the constraints of a type parameter to be satisfied at the call site in a way
that does not normally occur. It is generally recommended however to add all necessary constraints
to a type parameter. For example

```move
public struct NoAbilities()
public struct CopyBox<T: copy> has copy, drop { value: T }
macro fun make_box<$T>($x: $T): CopyBox<$T> {
    CopyBox { value: $x }
}
```

This macro will expand only if `$T` is instantiated with a type with the `copy` ability.

```move
make_box!(1); // Valid!
make_box!(NoAbilities()); // Error! 'NoAbilities' does not have the copy ability
```

The suggested declaration of `make_box` would be to add the `copy` constraint to the type parameter.
This then communicates to the caller that the type must have the `copy` ability.

```move
macro fun make_box<$T: copy>($x: $T): CopyBox<$T> {
    CopyBox { value: $x }
}
```

One might reasonably ask then, why have this relaxation if the recommendation is not to use it? The
constraints on type parameters simply cannot be enforced in all cases because the bodies are not
checked until expansion. In the following example, the `copy` constraint on `$T` is not necessary in
the signature, but is necessary in the body.

```move
macro fun read_ref<$T>($r: &$T): $T {
    *$r
}
```

If however, you want to have an extremely relaxed type signature, it is instead recommended to use
the [`_` type](#_-type).

### `_` Type

Normally, the [`_` placeholder type](./../generics#_-type) is used in expressions to allow for
partial annotations of type arguments. However, with `macro` functions, the `_` type can be used in
place of type parameters to relax the signature for any type. This should increase the ergonomics of
declaring "generic" `macro` functions.

For example, we could take any combination of integers and add them together.

```move
macro fun add($x: _, $y: _, $z: _): u256 {
    ($x as u256) + ($y as u256) + ($z as u256)
}
```

Additionally, the `_` type can be instantiated _multiple_ times with different types. For example

```move
public struct Box<T> has copy, drop, store { value: T }
macro fun create_two($f: |_| -> Box<_>): (Box<u8>, Box<u16>) {
    ($f(0u8), $f(0u16))
}
```

If we declared the function with type parameters instead, the types would have to unify to a common
type, which is not possible in this case.

```move
macro fun create_two<$T>($f: |$T| -> Box<$T>): (Box<u8>, Box<u16>) {
    ($f(0u8), $f(0u16))
    //           ^^^^ Error! expected `u8` but found `u16`
}
...
let (a, b) = create_two!(|value| Box { value });
```

In this case, `$T` must be instantiated with a single type, but inference finds that `$T` must be
bound to both `u8` and `u16`.

There is a tradeoff however, as the `_` type conveys less meaning and intention for the caller.
Consider `map` macro from above re-declared with `_` instead of `$T` and `$U`.

```move
macro fun map($v: vector<_>, $f: |_| -> _): vector<_> {
```

There is no longer any indication of behavior of `$f` at the type level. The caller must gain
understanding from comments or the body of the macro.

## Expansion and Substitution

The body of the `macro` is substituted into the call site at compile time. Each parameter is
replaced by the _expression_, not the value, of its argument. For lambdas, additional local
variables can have values bound within the context of the `macro` body.

Taking a very simple example

```move
macro fun apply($f: |u64| -> u64, $x: u64): u64 {
    $f($x)
}
```

With the call site

```move
let incremented = apply!(|x| x + 1, 5);
```

This will roughly be expanded to

```move
let incremented = {
    let x = { 5 };
    { x + 1 }
};
```

Again, the value of `x` is not substituted, but the expression `5` is. This might mean that an
argument is evaluated multiple times, or not at all, depending on the body of the `macro`.

```move
macro fun dup($f: |u64, u64| -> u64, $x: u64): u64 {
    $f($x, $x)
}
```

```move
let sum = dup!(|x, y| x + y, foo());
```

is expanded to

```move
let sum = {
    let x = { foo() };
    let y = { foo() };
    { x + y }
};
```

Note that `foo()` will be called twice. Which would not happen if `dup` were a normal function.

It is often recommended to create predictable evaluation behavior by binding arguments to local
variables.

```move
macro fun dup($f: |u64, u64| -> u64, $x: u64): u64 {
    let a = $x;
    $f(a, a)
}
```

Now that same call site will expand to

```move
let sum = {
    let a = { foo() };
    {
        let x = { a };
        let y = { a };
        { x + y }
    }
};
```

### Hygiene

In the example above, the `dup` macro had a local variable `a` that was used to bind the argument
`$x`. You might ask, what would happen if the variable was instead named `x`? Would that conflict
with the `x` in the lambda?

The short answer is, no. `macro` functions are
[hygienic](https://en.wikipedia.org/wiki/Hygienic_macro), meaning that the expansion of `macro`s and
lambdas will not accidentally capture variables from another scope.

The compiler does this by associating a unique number with each scope. When the `macro` is expanded,
the macro body gets its own scope. Additionally, the arguments are re-scoped on each usage.

Modifying the `dup` macro to use `x` instead of `a`

```move
macro fun dup($f: |u64, u64| -> u64, $x: u64): u64 {
    let a = $x;
    $f(a, a)
}
```

The expansion of the call site

```move
// let sum = dup!(|x, y| x + y, foo());
let sum = {
    let x#1 = { foo() };
    {
        let x#2 = { x#1 };
        let y#2 = { x#1 };
        { x#2 + y#2 }
    }
};
```

This is an approximation of the compiler's internal representation, some details are omitted for the
simplicity of this example.

And each usage of an argument is re-scoped so that the different usages do not conflict.

```move
macro fun apply_twice($f: |u64| -> u64, $x: u64): u64 {
    $f($x) + $f($x)
}
```

```move
let result = apply_twice!(|x| x + 1, { let x = 5; x });
```

Expands to

```move
let result = {
    {
        let x#1 = { let x#2 = { 5 }; x#2 };
        { x#1 + x#1 }
    }
    +
    {
        let x#3 = { let x#4 = { 5 }; x#4 };
        { x#3 + x#3 }
    }
};
```

Similar to variable hygiene, [method resolution](./../method-syntax) is also scoped to the macro
definition. For example

```move
public struct S { f: u64, g: u64 }

fun f(s: &S): u64 {
    s.f
}
fun g(s: &S): u64 {
    s.g
}

use fun f as foo;
macro fun call_foo($s: &S): u64 {
    let s = $s;
    s.foo()
}
```

The method call `foo` will in this case always resolve to the function `f`, even if `call_foo` is
used in a scope where `foo` is bound to a different function, such as `g`.

```move
fun example(s: &S): u64 {
    use fun g as foo;
    call_foo!(s) // expands to 'f(s)', not 'g(s)'
}
```

Due to this though, unused `use fun` declarations might not get warnings in modules with `macro`
functions.

### Control Flow

Similar to variable hygiene, control flow constructs are also always scoped to where they are
defined, not to where they are expanded.

```move
macro fun maybe_div($x: u64, $y: u64): u64 {
    let x = $x;
    let y = $y;
    if (y == 0) return 0;
    x / y
}
```

At the call site, `return` will always return from the `macro` body, not from the caller.

```move
let result: vector<u64> = vector[maybe_div!(10, 0)];
```

Will expand to

```move
let result: vector<u64> = vector['a: {
    let x = { 10 };
    let y = { 0 };
    if (y == 0) return 'a 0;
    x / y
}];
```

Where `return 'a 0` will return to the block `'a: { ... }` and not to the caller's body. See the
section on [labeled control flow](./../control-flow/labeled-control-flow) for more details.

Similarly, `return` in a lambda will return from the lambda, not from the `macro` body and not from
the outer function.

```move
macro fun apply($f: |u64| -> u64, $x: u64): u64 {
    $f($x)
}
```

and

```move
let result = apply!(|x| { if (x == 0) return 0; x + 1 }, 100);
```

will expand to

```move
let result = {
    let x = { 100 };
    'a: {
        if (x == 0) return 'a 0;
        x + 1
    }
};
```

In addition to returning from the lambda, a label can be used to return to the outer function. In
the `vector::any` macro, a `return` with a label is used to return from the entire `macro` early

```move
public macro fun any<$T>($v: &vector<$T>, $f: |&$T| -> bool): bool {
    let v = $v;
    'any: {
        v.do_ref!(|e| if ($f(e)) return 'any true);
        false
    }
}
```

The `return 'any true` exits from the "loop" early when the condition is met. Otherwise, the macro
"returns" `false`.

### Method Syntax

When applicable, `macro` functions can be called using [method syntax](./../method-syntax). When
using method syntax, the evaluation of the arguments will change in that the first argument (the
"receiver" of the method) will be evaluated outside of the macro expansion. This example is
contrived, but will concisely demonstrate the behavior.

```move
public struct S() has copy, drop;
public fun foo(): S { abort 0 }
public macro fun maybe_s($s: S, $cond: bool): S {
    if ($cond) $s
    else S()
}
```

Even though `foo()` will abort, its return type can be used to start a method call.

`$s` will not be evaluated if `$cond` is `false`, and under a normal non-method call, an argument of
`foo()` would not be evaluated and would not abort. The following example demonstrates `$s` not
being evaluated with an argument of `foo()`.

```move
maybe_s!(foo(), false) // does not abort
```

It becomes more clear as to why it does not abort when looking at the expanded form

```move
if (false) foo()
else S()
```

However, when using method syntax, the first argument is evaluated before the macro is expanded. So
the same argument of `foo()` for `$s` will now be evaluated and will abort.

```move
foo().maybe_s!(false) // aborts
```

We can see this more clearly when looking the expanded form

```move
let tmp = foo(); // aborts
if (false) tmp
else S()
```

Conceptually, the receiver for a method call is bound to a temporary variable before the macro is
expanded, which forces the evaluation and thus the abort.

### Parameter Limitations

The parameters of a `macro` function must always be used as expressions. They cannot be used in
situations where the argument might be re-interpreted. For example, the following is not allowed

```move
macro fun no($x: _): _ {
    $x.f
}
```

The reason is that if the argument `$x` was not a reference, it would be borrowed first, which would
could re-interpret the argument. To get around this limitation, you should bind the argument to a
local variable.

```move
macro fun yes($x: _): _ {
    let x = $x;
    x.f
}
```

## Examples

### Lazy arguments: assert_eq

```move
macro fun assert_eq<$T>($left: $T, $right: $T, $code: u64) {
    let left = $left;
    let right = $right;
    if (left != right) {
        std::debug::print(&b"assertion failed.\n left: ");
        std::debug::print(&left);
        std::debug::print(&b"\n does not equal right: ");
        std::debug::print(&right);
        abort $code;
    }
}
```

In this case the argument to `$code` is not evaluated unless the assertion fails.

```move
assert_eq!(vector[true, false], vector[true, false], 1 / 0); // division by zero is not evaluated
```

### Any integer square root

This macro calculates the integer square root for any integer type, besides `u256`.

`$T` is the type of the input and `$bitsize` is the number of bits in that type, for example `u8`
has 8 bits. `$U` should be set to the next larger integer type, for example `u16` for `u8`.

In this `macro`, the type of the integer literals are `1` and `0` are annotated, e.g. `(1: $U)`
allowing for the type of the literal to differ with each call. Similarly, `as` can be used with the
type parameters `$T` and `$U`. This macro will then only successfully expand if `$T` and `$U` are
instantiated with the integer types.

```move
macro fun num_sqrt<$T, $U>($x: $T, $bitsize: u8): $T {
    let x = $x;
    let mut bit = (1: $U) << $bitsize;
    let mut res = (0: $U);
    let mut x = x as $U;

    while (bit != 0) {
        if (x >= res + bit) {
            x = x - (res + bit);
            res = (res >> 1) + bit;
        } else {
            res = res >> 1;
        };
        bit = bit >> 2;
    };

    res as $T
}
```

### Iterating over a vector

The two `macro`s iterate over a vector, immutably and mutably respectively.

```move
macro fun for_imm<$T>($v: &vector<$T>, $f: |&$T|) {
    let v = $v;
    let n = v.length();
    let mut i = 0;
    while (i < n) {
        $f(&v[i]);
        i = i + 1;
    }
}

macro fun for_mut<$T>($v: &mut vector<$T>, $f: |&mut $T|) {
    let v = $v;
    let n = v.length();
    let mut i = 0;
    while (i < n) {
        $f(&mut v[i]);
        i = i + 1;
    }
}
```

A few examples of usage

```move
fun imm_examples(v: &vector<u64>) {
    // print all elements
    for_imm!(v, |x| std::debug::print(x));

    // sum all elements
    let mut sum = 0;
    for_imm!(v, |x| sum = sum + x);

    // find the max element
    let mut max = 0;
    for_imm!(v, |x| if (x > max) max = x);
}

fun mut_examples(v: &mut vector<u64>) {
    // increment each element
    for_mut!(v, |x| *x = *x + 1);

    // set each element to the previous value, and the first to last value
    let mut prev = v[v.length() - 1];
    for_mut!(v, |x| {
        let tmp = *x;
        *x = prev;
        prev = tmp;
    });

    // set the max element to 0
    let mut max = &mut 0;
    for_mut!(v, |x| if (*x > *max) max = x);
    *max = 0;
}
```

### Non-loop lambda usage

Lambdas do not need to be used in loops, and are often useful for conditionally applying code.

```move
macro fun inspect<$T>($opt: &Option<$T>, $f: |&$T|) {
    let opt = $opt;
    if (opt.is_some()) $f(opt.borrow())
}

macro fun is_some_and<$T>($opt: &Option<$T>, $f: |&$T| -> bool): bool {
    let opt = $opt;
    if (opt.is_some()) $f(opt.borrow())
    else false
}

macro fun map<$T, $U>($opt: Option<$T>, $f: |$T| -> $U): Option<$U> {
    let opt = $opt;
    if (opt.is_some()) {
        option::some($f(opt.destroy_some()))
    } else {
        opt.destroy_none();
        option::none()
    }
}
```

And some examples of usage

```move
fun examples(opt: Option<u64>) {
    // print the value if it exists
    inspect!(&opt, |x| std::debug::print(x));

    // check if the value is 0
    let is_zero = is_some_and!(&opt, |x| *x == 0);

    // upcast the u64 to a u256
    let str_opt = map!(opt, |x| x as u256);
}
```
