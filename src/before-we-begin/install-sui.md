# Install Sui

Move is a compiled language, so you need to install a compiler before you can run Move programs that you write. The compiler is included with the Sui binary, which you can install or download using one of the following methods.

## Download Binary

You can download the latest Sui binary from the [releases page](https://github.com/MystenLabs/sui/releases). The binary is available for macOS, Linux and Windows. For education purposes and development, we recommend using the `mainnet` version.

## Install Using Homebrew (MacOS)

You can install Sui using the [Homebrew](https://brew.sh/) package manager.

```bash
brew install sui
```

## Build Using Cargo (MacOS, Linux)

You can install and build Sui locally by using the Cargo package manager (requires Rust)

```bash
cargo install --git https://github.com/MystenLabs/sui.git --bin sui --branch mainnet
```

## Install Using Chocolatey (Windows)

You can install Sui using the [Chocolatey]() package manager for Windows.

```bash
choco install sui
```

## Troubleshooting

For troubleshooting the installation process, refer to the [Install Sui](https://docs.sui.io/guides/developer/getting-started/sui-install) guide.
