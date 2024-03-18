# Testing

## `#[test]` and `#[test_only]`

## Unit Testing with Dummy Context

## Utilizing the Test Scenario

## Adding Examples

When publishing a package that is intented to be used (an NFT protocol or a library), it is important to showcase how this package can be used. This is where examples come in handy. There's no special functionality for examples in Move, however, there are some conventions that are used to mark examples. First of all, only sources are included into the package bytecode, so any code placed in a different directory will not be included, but will be tested!

This is why placing examples into a separate `examples/` directory is a good idea.

```bash
sources/
    protocol.move
    library.move
tests/
    protocol_test.move
examples/
    my_example.move
Move.toml
```
