// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[allow(unused_use)]
// ANCHOR: module_one
module book::module_one {
    /// Struct defined in the same module.
    public struct Character has drop {}

    /// Simple function that creates a new `Character` instance.
    public fun new(): Character { Character {} }
}
// ANCHOR_END: module_one

#[allow(unused_use)]
// ANCHOR: module_two
module book::module_two {
    use book::module_one; // importing module_one from the same package

    /// Calls the `new` function from the `module_one` module.
    public fun create_and_ignore() {
        let _ = module_one::new();
    }
}
// ANCHOR_END: module_two

#[allow(unused_use)]
// ANCHOR: members
module book::more_imports {
    use book::module_one::new;       // imports the `new` function from the `module_one` module
    use book::module_one::Character; // importing the `Character` struct from the `module_one` module

    /// Calls the `new` function from the `module_one` module.
    public fun create_character(): Character {
        new()
    }
}
// ANCHOR_END: members

#[allow(unused_use)]
// ANCHOR: grouped
module book::grouped_imports {
    // imports the `new` function and the `Character` struct from
    /// the `module_one` module
    use book::module_one::{new, Character};

    /// Calls the `new` function from the `module_one` module.
    public fun create_character(): Character {
        new()
    }
}
// ANCHOR_END: grouped

#[allow(unused_use)]
// ANCHOR: self
module book::self_imports {
    // imports the `Character` struct, and the `module_one` module
    use book::module_one::{Self, Character};

    /// Calls the `new` function from the `module_one` module.
    public fun create_character(): Character {
        module_one::new()
    }
}
// ANCHOR_END: self

#[allow(unused_use)]
// ANCHOR: conflict
module book::conflict_resolution {
    // `as` can be placed after any import, including group imports
    use book::module_one::{Self as mod, Character as Char};

    /// Calls the `new` function from the `module_one` module.
    public fun create(): Char {
        mod::new()
    }
}
// ANCHOR_END: conflict

#[allow(unused_use)]
// ANCHOR: external
module book::imports {
    use std::string; // std = 0x1, string is a module in the standard library
    use sui::coin;   // sui = 0x2, coin is a module in the Sui Framework
}
// ANCHOR_END: external
