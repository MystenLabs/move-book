> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)

# Address

Address is a unique identifier of a location on the blockchain. It is used to identify
[packages](./packages), [accounts](./what-is-an-account), and [objects](./../object/object-model).
Address has a fixed size of 32 bytes and is usually represented as a hexadecimal string prefixed
with `0x`. Addresses are case insensitive.

```move
0xe51ff5cd221a81c3d6e22b9e670ddf99004d71de4f769b0312b68c7c4872e2f1
```

The address above is an example of a valid address. It is 64 characters long (32 bytes) and prefixed
with `0x`.

Sui also has reserved addresses that are used to identify standard packages and objects. Reserved
addresses are typically simple values that are easy to remember and type. For example, the address
of the Standard Library is `0x1`. Addresses, shorter than 32 bytes, are padded with zeros to the
left.

```move
0x1 = 0x0000000000000000000000000000000000000000000000000000000000000001
```

Here are some examples of reserved addresses:

- `0x1` - address of the Sui Standard Library (alias `std`)
- `0x2` - address of the Sui Framework (alias `sui`)
- `0x6` - address of the system `Clock` object

> You can find all reserved addresses in the [Appendix B](../appendix/reserved-addresses).

## Further Reading

- [Address type](../move-basics/address) in Move
- [sui::address module](https://docs.sui.io/references/framework/sui/address)
