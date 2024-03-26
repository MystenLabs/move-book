# Install Sui

Move is a compiled language, so you need to install a compiler to be able to write and run Move programs. The compiler is included into the Sui binary, which can be installed or downloaded using one of the methods below.

## Download Binary

You can download the latest Sui binary from the [releases page](https://github.com/MystenLabs/sui/releases). The binary is available for macOS, Linux and Windows. For education purposes and development, we recommend using the `mainnet` version.

## Install using Homebrew (MacOS)

You can install Sui using the [Homebrew](https://brew.sh/) package manager.

```bash
brew install sui
```

## Build using Cargo (MacOS, Linux)

You can install and build Sui locally by using the Cargo package manager (requires Rust)

```bash
cargo install --git https://github.com/MystenLabs/sui.git --bin sui --branch mainnet
```

## Troubleshooting

For troubleshooting the installation process, please refer to the [Install Sui](https://docs.sui.io/guides/developer/getting-started/sui-install) Guide.
