---
description: "The Move.toml package manifest: package metadata, dependencies, named addresses, and dependency overrides explained."
---

# Package Manifest

The `Move.toml` is a manifest file that describes the [package](./packages) and its dependencies. It
is written in [TOML](https://toml.io/en/) format and contains multiple sections, the most important
of which are `[package]`, `[dependencies]` and `[addresses]`.

```toml
[package]
name = "my_project"
edition = "2024"

[dependencies]
example = { git = "https://github.com/example/example.git", subdir = "path/to/package", rev = "framework/testnet" }
```

## Sections

### Package

The `[package]` section is used to describe the package. None of the fields in this section are
published on chain, but they are used in tooling and release management; they also specify the Move
edition for the compiler.

- `name` - the name of the package when it is imported;
- `edition` - the edition of the Move language; currently, the only valid value is `2024`;
- `published-at` - the address the package was published at; set after publishing, it lets
  dependent packages and tooling resolve the on-chain address of this package.

### Dependencies

The `[dependencies]` section is used to specify the dependencies of the project. Each dependency is
specified as a key-value pair, where the key is the name of the dependency, and the value is the
dependency specification. The dependency specification can be a git repository URL or a path to the
local directory.

```toml
# git repository
example = { git = "https://github.com/example/example.git", subdir = "path/to/package", rev = "framework/testnet" }

# local directory
my_package = { local = "../my-package" }
```

Packages also import named addresses from their dependencies. For example, the Sui dependency adds
the `std` and `sui` addresses to the project, usable in the code in place of the full `0x1` and
`0x2` addresses.

Starting with version 1.45 of the Sui CLI, the Sui system packages (`std`, `sui`, `system`,
`bridge`, and `deepbook`) are automatically added as dependencies if none of them are explicitly
listed.

### Addresses

The `[addresses]` section declares _named addresses_: aliases that can be used in the code in place
of full addresses. The package's own name is conventionally declared here with the value `0x0`,
which is the placeholder used until the package is published:

```toml
[addresses]
my_project = "0x0"
alice = "0xA11CE"
```

### Resolving Version Conflicts with Override

Sometimes dependencies have conflicting versions of the same package. For example, if you have two
dependencies that use different versions of the Example package, you can override the dependency in
the `[dependencies]` section. To do so, add the `override` field to the dependency. The version of
the dependency specified in the `[dependencies]` section will be used instead of the one specified
in the dependency itself.

```toml
[dependencies]
example = { override = true, git = "https://github.com/example/example.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
```

## TOML Styles

The TOML format supports two styles for tables: inline and multiline. The examples above are using
the inline style, but it is also possible to use the multiline style. You wouldn't want to use it
for the `[package]` section, but it can be useful for the dependencies.

```toml
# Inline style
[dependencies]
example = { override = true, git = "https://github.com/example/example.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
MyPackage = { local = "../my-package" }
```

```toml
# Multiline style
[dependencies.example]
override = true
git = "https://github.com/example/example.git"
subdir = "crates/sui-framework/packages/sui-framework"
rev = "framework/testnet"

[dependencies.my_package]
local = "../my-package"
```

## Further Reading

- [Packages](./../../reference/packages) in the Move Reference.
