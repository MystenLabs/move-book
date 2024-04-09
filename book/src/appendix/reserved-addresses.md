# Appendix B: Reserved Addresses

Reserved addresses are special addresses that have a specific purpose on Sui. They stay the same
between environments and are used for specific native operations.

- `0x1` - address of the [Standard Library](./../move-basics/standard-library.md) (alias `std`)
- `0x2` - address of the [Sui Framework](./../programmability/sui-framework.md) (alias `sui`)
- `0x5` - address of the `SuiSystem` object
- `0x6` - address of the system [`Clock` object](./../programmability/epoch-and-time.md)
- `0x8` - address of the system `Random` object
- `0x403` - address of the `DenyList` system object
