# Install MVR

[Move Registry (MVR)](https://moveregistry.com) is a package manager for Move. It allows anyone to
publish and use published packages in new applications written in Move. Local binary allows
searching packages in the registry as well as installing them as a part of the Sui CLI build
process.

## Installing via suiup

The best way to install MVR is by using [`suiup`](https://github.com/MystenLabs/suiup). Suiup
provides an easy way to update and manage different versions of binaries.

Installation instructions for `suiup` can be found
[in the repository README](https://github.com/MystenLabs/suiup).

To install Move Registry CLI, run the following command:

```bash
suiup install mvr
```

After installation, Move Registry will be available as `mvr`.

## Download Binary

You can download the latest MVR binary from the
[releases page](https://github.com/MystenLabs/mvr/releases). The binary is available for macOS,
Linux and Windows. Unlike [Sui](./install-sui.md), the MVR binary is not changing between
environments and supports both `testnet` and `mainnet`.

## Install Using Cargo

You can install and build MVR locally by using Cargo (requires Rust)

```bash
cargo install --locked --git https://github.com/mystenlabs/mvr --branch release mvr
```

## Troubleshooting

For troubleshooting the installation process, please refer to the
[Install MVR](https://docs.suins.io/move-registry/tooling/mvr-cli#installation) Guide.
