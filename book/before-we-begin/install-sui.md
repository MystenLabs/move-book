---
description: >-
  Install the Sui binary and Move compiler using suiup, Homebrew, or Chocolatey
  to start developing Move smart contracts.
title: Install Sui
keywords:
  - Move
  - Sui
  - Move tutorial
  - install
  - sui
questions:
  - How do I install the Sui CLI?
  - How do I set up Sui for Move development?
answer: >-
  Install the Sui CLI using the official installer, then verify with sui
  --version to begin compiling and testing Move code.
goal:
  description: Reader has the Sui CLI installed and can run sui move commands
  requires:
    - has_frontmatter:
        - title
        - description
        - keywords
      label: Has required frontmatter fields
    - min_words: 50
      label: Needs content depth
    - has_questions: true
      label: Needs questions for AI search visibility
    - has_answer: true
      label: Needs answer summary for AI citation
---

# Install Sui

Move is a compiled language, so you need to install a compiler to be able to write and run Move
programs. The compiler is included into the Sui binary, which can be installed or downloaded using
one of the methods below.

## Installing via suiup

The best way to install Sui is by using [`suiup`](https://github.com/MystenLabs/suiup). It provides a simple way to install binaries and to manage different versions of binaries for
different environments (e.g. `testnet` and `mainnet`).

Installation instructions for `suiup` can be found
[in the repository README](https://github.com/MystenLabs/suiup).

To install Sui, run the following command:

```bash
suiup install sui
```

## Download Binary

You can download the latest Sui binary from the
[releases page](https://github.com/MystenLabs/sui/releases). The binary is available for macOS,
Linux and Windows. For education purposes and development, we recommend using the `mainnet` version.

## Install Using Homebrew (MacOS)

You can install Sui using the [Homebrew](https://brew.sh/) package manager.

```bash
brew install sui
```

## Install Using Chocolatey (Windows)

You can install Sui using the [Chocolatey](https://chocolatey.org/install) package manager for
Windows.

```bash
choco install sui
```

## Build Using Cargo (MacOS, Linux)

You can install and build Sui locally by using the Cargo package manager (requires Rust)

```bash
cargo install --git https://github.com/MystenLabs/sui.git sui --branch mainnet
```

Change the branch target here to `testnet` or `devnet` if you are targeting one of those.

Make sure that your system has the latest Rust versions with the command below.

```bash
rustup update stable
```

## Troubleshooting

For troubleshooting the installation process, please refer to the
[Install Sui](https://docs.sui.io/guides/developer/getting-started/sui-install) Guide.
