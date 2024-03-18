# Adding Tests

<!--

- Adding Tests
    - describe what a test is
    - copy-paste the example into the code
    - explain the test
    - run sui move test
    - compare the output
    - try to break the test
    - check the output
    - leave a hint
    - anticipation for the next section

 -->

To run a Move program there needs to be an environment which stores packages and executes transactions. The best way to test a Move program is to write some tests and run them locally. Move has built-in testing functionality, and the tests are written in Move as well. In this section, we will learn how to write tests for our `hello_world` module.

First, let's try to run tests. All of the Move binaries support the `test` command, and this is the command we will use to run tests:

```bash
$ sui move test
```

If you see similar output, then everything is fine, and the test command has run successfully:

```bash
INCLUDING DEPENDENCY MoveStdlib
BUILDING Book Samples
Running Move unit tests
Test result: OK. Total tests: 0; passed: 0; failed: 0
```

As you can see, the test command has run successfully, but it didn't find any tests. Let's add some tests to our module.

## Your first test

When the test command runs, it looks for all tests in all files in the directory. Tests can be either placed separate modules or in the same module as the code they test. First, let's add a test function to the `hello_world` module:

```Move
{{#include ../../samples/sources/your-first-move/hello_world.move:4:}}
```

The test function is a function with a `#[test]` attribute. Normally it takes no arguments (but it can take arguments in some cases - you'll learn more about it closer to the end of this book) and returns nothing. Tests placed in the same module as the code they test are called "unit tests". They can access all functions and types in the module. We'll go through them in more detail in the [Test](../syntax-basics/test.md) section.

```Move
{{#include ../../samples/sources/your-first-move/hello_world.move:11:15}}
```

Inside the test function, we define the expected outcome by creating a String with the expected value and assign it to the `expected` variable. Then we use the special built-in `assert!()` which takes two arguments: a conditional expression and an error code. If the expression evaluates to `false`, then the test fails with the given error code. The equality operator `==` compares the `actual` and `expected` values and returns `true` if they are equal. We'll learn more about expressions in the [Expression and Scope](../syntax-basics/expression-and-scope.md) section.

Now let's run the test command again:

```bash
$ sui move test
```

You should see this output, which means that the test has run successfully:

```bash
...
Test result: OK. Total tests: 1; passed: 1; failed: 0
```

## Failed experiment

Try replacing the equality operator  `==` inside the `assert!` with the inequality operator `!=` and run the test command again.

```Move
    assert!(hello_world() != expected, 0)
```

You should see this output, which means that the test has failed:

```bash
Running Move unit tests
[ FAIL    ] 0x0::hello_world::test_is_hello_world

Test failures:

Failures in 0x0::hello_world:

┌── test_is_hello_world ──────
│ error[E11001]: test failure
│    ┌─ ./sources/your-first-move/hello_world.move:14:9
│    │
│ 12 │     fun test_is_hello_world() {
│    │         ------------------- In this function in 0x0::hello_world
│ 13 │         let expected = string::utf8(b"Hello, World!");
│ 14 │         assert!(hello_world() != expected, 0)
│    │         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Test was not expected to error, but it aborted with code 0 originating in the module 00000000000000000000000000000000::hello_world rooted here
│
│
└──────────────────

Test result: FAILED. Total tests: 1; passed: 0; failed: 1
```

Tests are used to verify the execution of the code. If the code is correct, the test should pass, otherwise it should fail. In this case, the test failed because we intentionally made a mistake in the test code. However, normally you should write tests that check the correctness of the code, not the other way around!

In the next section, we will learn how to debug Move programs and print intermediate values to the console.
