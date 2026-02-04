# Random Inputs and Seeds

Move Compiler has a built-in support for random inputs for tests. This feature is useful for testing
functions with random inputs. This is achieved by using the `#[random_test]` attribute.

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
