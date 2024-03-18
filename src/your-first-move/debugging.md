# Debugging

<!--
- Debugging
    - describe what Move Compiler can do for debugging
    - debug is only available in test mode
    - copy-paste the example
    - explain the imported `std::debug` module
    - give a hint on how to do an inline call
    - pretty-print for strings / vectors
    - other debug functions: print, print_stack_trace

 -->

Now that we have a package with a module and a test, let's take a slight detour and learn how to debug Move programs. Move Compiler has a built-in debugging tool that allows you to print intermediate values to the console. This is especially useful when you are writing tests and want to see what's going on inside the program.

## New import

To use the `debug` module, we need to import it in our module. Imports are usually grouped together for readability and they are placed at the top of the module. Let's add the import statement to the `hello_world` module:

```Move
{{#include ../../samples/sources/your-first-move/hello_world.move:4:5}}
    use std::debug; // the added import!
```

Having imported the `std::debug` module, we can now use its functions. Let's add a `debug::print` function call to the `hello_world` function. To achieve that we need to change the function body. Instead of returning the value right away we will assign it to a variable, print it to the console and then return it:

```Move
{{#include ../../samples/sources/your-first-move/hello_world_debug.move:8:12}}
```

First, run the build command:
```bash
$ sui move build
```
The output does not contain anything unusual, because our code was never executed. But running `build` is an important part of the routine - this way we make sure that the changes we added can compile. Let's run the test command now:

```bash
$ sui move test
```

The output of the test command now contains the "Hello, World!" string:

```bash
INCLUDING DEPENDENCY MoveNursery
INCLUDING DEPENDENCY MoveStdlib
BUILDING Book Samples
Running Move unit tests
[debug] "Hello, World!"
[ PASS    ] 0x0::hello_world::test_is_hello_world
Test result: OK. Total tests: 1; passed: 1; failed: 0
```

Now every time the `hello_world` function is run in tests, you'll see the "Hello, World!" string in the output.

## Correct usage

Debug should only be used in local environment and never published on-chain. Usually, during the publish, the `debug` module is either removed from the package or the publishing fails with an error. There's no way to use this functionality on-chain.

## Hint

There's one trick that allows you to save some time while debugging. Instead of adding a module-level import, use a fully qualified function name. This way you don't need to add an import statement to the module, but you can still use the `debug::print` function:

```Move
    std::debug::print(&my_variable);
```

Be mindful that the value passed into debug should be a reference (the `&` symbol in front of the variable name). If you pass a value, the compiler will emit an error.
