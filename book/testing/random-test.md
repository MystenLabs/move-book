# Random Inputs and Seeds

Move Compiler has a built-in support for random inputs for tests. This feature is useful for testing
functions with random inputs. This is achieved by using the `#[random_test]` attribute.

- random tests are great for testing functions that are sensitive to random inputs
- random tests can be rerun with a seed
- random tests allow passing any primitive arguments to the test function
- usage of `vector` type (with loops) is discouraged as it can generate quite large vectors, slowing down tests and risking out of gas errors
- random tests should not be the only tests for a function, but an addition to the other tests
- if function expects a reasonably small `u64` value - use a smaller integer input and convert it
- random test attribute is independent from `sui::random` but can be used to test it too

## Usage

```move
#[test]
#[random_test]
fun test_with_random_inputs(a: u8, b: bool) {

}
```

## Limitations

- no way to limit the size or a range of a random input
- `vector<u8>` can generate quite large vectors, which can slow down tests involving loops
-

## Debugging with Seeds

- use `--seed` flag to set the seed for the random generator; especially useful for debugging
  failures or comparing gas profiles between test runs (given that tests use random inputs)
