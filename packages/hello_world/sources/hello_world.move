/// The module `hello_world` under named address `hello_world`.
/// The named address is set in the `Move.toml`.
module hello_world::hello_world;

// Imports the `String` type from the Standard Library
use std::string::String;

/// Returns the "Hello World!" as a `String`.
public fun hello_world(): String {
    b"Hello, World!".to_string()
}
