---
description:
  'Use Move Registry (MVR) to add external dependencies to your Move package: search for packages,
  add them to the manifest, and call them in your code.'
---

# Using Move Registry

Every package published on Sui is identified by its address. Addresses are precise but hard to
work with: they are not memorable, they differ between networks, and they say nothing about what
the package does or who published it. [Move Registry (MVR)](https://www.moveregistry.com) solves
this by mapping human-readable names, like `@potatoes/date`, to published package addresses. With
MVR, adding an external dependency to your package is a single command, and the toolchain resolves
the name to the right address for the network you are building against.

This guide walks through the full cycle of using an external package: finding it in the registry,
adding it to the manifest, calling it in code, and testing the result. It assumes you have the MVR
CLI installed - if you don't, refer to the
[Install MVR](./../before-we-begin/install-move-registry-cli) section.

## Package Names

MVR names follow the `@organization/package-name` pattern: the organization part is backed by a
[SuiNS](https://suins.io) name, and the package name is registered under it by the organization's
owner. A name points to a published package on a specific network, so the same name can resolve to
different addresses on _mainnet_ and _testnet_. Additionally, since packages on Sui are versioned,
a name can also carry a version suffix, such as `@potatoes/date/1`; without it, the name resolves
to the latest version.

In this guide we use the [`@potatoes/date`](https://www.moveregistry.com/package/@potatoes/date)
package - a small library that converts a timestamp into a `Date` structure and prints it in
ISO 8601, UTC (RFC 7231), or a custom format.

## Finding a Package

Packages can be discovered on the [MVR website](https://www.moveregistry.com) or directly from the
terminal with the `mvr search` command. The query can be a part of a package name or description,
or an `@organization/` prefix to list everything published by one organization:

```bash
$ mvr search "@potatoes/"
```

```plaintext
- @potatoes/codec
# High performant encoding library for Sui, features: base64, base64url, urlencode, hex (base16)
Networks: mainnet, testnet

- @potatoes/date
# Date and time printing / formatting tool, which supports RFC 7231 (UTC), ISO-8601 and custom
# formats, as well as constructing the date from string
Networks: mainnet, testnet
```

The `Networks` line is important: a name can only be resolved on a network where the package is
published. If a dependency is only available on _mainnet_, a build against _testnet_ will fail to
resolve it.

## Adding a Dependency

To add a package to your project, run the `mvr add` command in the directory containing the package
manifest:

```bash
$ mvr add @potatoes/date
```

The command inserts a new record into the `[dependencies]` section of the `Move.toml`:

```toml
[dependencies]
date = { r.mvr = "@potatoes/date" }
```

Unlike a git dependency, which points to a repository and revision, this record contains only the
registry name. The `r.` prefix stands for _external resolver_ - a plugin that the Sui CLI calls
during build to turn the name into a concrete package address and source location. The `mvr`
binary is that resolver, which is why it must be installed and available in the `PATH`.

To pin the dependency to a specific version, add the version suffix to the name:

```toml
[dependencies]
date = { r.mvr = "@potatoes/date/1" }
```

## Building the Package

The dependency is fetched and resolved as a part of the regular build. During `sui move build`,
the CLI calls the MVR resolver for each `r.mvr` record, using the currently active environment to
pick the network:

```plaintext
Output from mvr:
  │ [mvr] resolving: "@potatoes/date" on network: testnet

Output from mvr:
  │ [mvr] resolving: "@potatoes/ascii/1" on network: testnet

INCLUDING DEPENDENCY MoveStdlib
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY ascii
INCLUDING DEPENDENCY date
BUILDING postcard
```

Note the second resolver call: `@potatoes/date` itself depends on `@potatoes/ascii`, and the
resolver fetches it automatically. Transitive MVR dependencies require no extra records in your
manifest.

The result of the resolution is recorded in the `Move.lock` file, pinning each dependency to an
exact source revision per network. The lock file should be checked into version control, so that
every build of your package uses the same dependency versions.

## Using the Dependency

Once the dependency is added, its modules can be imported with a regular `use` statement. The
address part of the path is the named address declared by the dependency itself - for
`@potatoes/date` it is `date`, so the `date` module in it is imported as `date::date`.

The example below defines a `Postcard` object which stores a human-readable timestamp of its
creation, using the `Date` type from the dependency and the `Clock` object to get the current
time:

```move
/// Module: postcard
module postcard::postcard;

use date::date;
use std::string::String;
use sui::clock::Clock;

/// A postcard which prints the date and time of its creation.
public struct Postcard has key, store {
    id: UID,
    message: String,
    sent_at: String,
}

/// Create a new `Postcard` with a message and a human-readable timestamp.
public fun new(message: String, clock: &Clock, ctx: &mut TxContext): Postcard {
    let date = date::from_clock(clock);

    Postcard {
        id: object::new(ctx),
        message,
        sent_at: date.to_utc_string(),
    }
}
```

The `date::from_clock` function reads the timestamp from the `Clock` object (see
[Epoch and Time](./../programmability/epoch-and-time)) and converts it into a `Date` value, which
is then printed as a UTC string. The package also provides `to_iso_string` for ISO 8601 output and
`format` for custom formats:

```move
// Jan 1, 2025, 12:30:00 UTC
let date = date::new(1735734600000);

assert!(date.to_utc_string() == "Wed, 01 Jan 2025 12:30:00 GMT");
assert!(date.to_iso_string() == "2025-01-01T12:30:00.000Z");
assert!(date.format("DD MMM YYYY, HH:mm") == "01 Jan 2025, 12:30");
```

## Testing

External dependencies take part in tests like any other code. The test below creates a `Clock`
with a known timestamp and checks that the `Postcard` prints it correctly:

```move
#[test]
fun test_postcard() {
    let ctx = &mut tx_context::dummy();
    let mut clock = sui::clock::create_for_testing(ctx);

    // set time to Jan 1, 2025, 12:30:00 UTC
    clock.set_for_testing(1735734600000);

    let postcard = new("Hello from Move!", &clock, ctx);

    assert!(postcard.sent_at == "Wed, 01 Jan 2025 12:30:00 GMT");

    transfer::public_transfer(postcard, ctx.sender());
    clock.destroy_for_testing();
}
```

Running `sui move test` resolves the dependencies, builds the package, and executes the test:

```plaintext
Running Move unit tests
[ PASS    ] postcard::postcard::test_postcard
Test result: OK. Total tests: 1; passed: 1; failed: 0
```

## Summary

- Move Registry (MVR) maps human-readable names, like `@potatoes/date`, to published package
  addresses, per network.
- The `mvr search` command (or the [MVR website](https://www.moveregistry.com)) helps discover
  packages and shows which networks they are published on.
- The `mvr add` command adds a dependency record to the `Move.toml`; the name is resolved during
  build by the `mvr` binary, based on the active environment.
- Resolved dependencies are pinned in the `Move.lock` file, which should be checked into version
  control.
- Modules of the dependency are imported using the named address declared by the dependency
  itself.

## Further Reading

- [Move Registry documentation](https://docs.suins.io/move-registry) - including how to publish
  and register your own package.
- [Package Manifest](./../concepts/manifest) section of this book.
