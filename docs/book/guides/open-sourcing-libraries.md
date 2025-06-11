# Open Sourcing Libraries

Open sourcing libraries is a great way to contribute to the Move ecosystem. This guide will help you
understand how to open source a library, how to write tests, and how to document your library.

## README

TODO: readme

## Named Addresses

TODO: named address

## Generating Documentation

TODO: docgen

## Adding Examples

When publishing a package that is intended to be used (an NFT protocol or a library), it is
important to showcase how this package can be used. This is where examples come in handy. There's no
special functionality for examples in Move, however, there are some conventions that are used to
mark examples. First of all, only sources are included into the package bytecode, so any code placed
in a different directory will not be included, but will be tested!

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

## Tags and Releases (Git)

TODO: tags and releases

## Tricks to allow compatibility with closed source

TODO: compatibility via empty functions with signatures
