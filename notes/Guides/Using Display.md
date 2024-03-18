A creator or a builder who owns a `Publisher` object created in their package can use the `sui::display` module to define display properties for their objects. To get a Publisher object check out the [[Setting up Publisher]] guide.

`Display<T>` is an object that specifies a template for the type `T` (for example, for a type `0x2::capy::Capy` the display would be `Display<0x2::capy::Capy>`). All objects of the type `T` will be processed in the Sui Full Node RPC through the matching `Display` template.

Display is created via the `display::new<T>` call, which can be performed either in a custom function (or a module initializer) or as a part of a programmable transaction.

```rust
module sui::display {
    /// Get a new Display object for the `T`.
    ///
    /// Publisher must be the publisher of the T, `from_package`
    /// check is performed.
    public fun new<T>(pub: &Publisher): Display<T> { /* ... */ }
}
```

Once acquired, it can be modified.
```rust
module sui::display {
    /// Sets multiple fields at once
    public fun add_multiple(
        self: &mut Display,
        keys: vector<String>,
        values: vector<String
    ) { /* ... */ }

    /// Edit a single field
    public fun edit(self: &mut Display, key: String, value: String) { /* ... */ }

    /// Remove a key from Display
    public fun remove(self: &mut Display, key: String ) { /* ... */ }
}
```

To apply changes and set the Display for the T, one last call is required. `update_version` publishes version by emitting an event which Full Node listens to and uses to get a template for the type.
```rust
module sui::display {
    ///
    public fun update_version(self: &mut Display) { /* ... */ }
}
```

For the client implementation guide see [[Implementing Display on Clients]]
