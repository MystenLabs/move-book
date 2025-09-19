# Appendix C: Transfer Functions

## Transfer Functions Comparison

| Function                  | Public Function         | End State     | Permissions               |
| ------------------------- | ----------------------- | ------------- | ------------------------- |
| [`transfer`][transfer]    | `public_transfer`       | Address Owned | Full                      |
| [`share_object`][share]   | `public_share_object`   | Shared        | Ref, Mut Ref, Delete      |
| [`freeze_object`][freeze] | `public_freeze_object`  | Frozen        | Ref                       |
| [`party_transfer`][party] | `public_party_transfer` | Party         | [See Party table](#party) |

## States Comparison

| State         | Description                                               |
| ------------- | --------------------------------------------------------- |
| Address Owned | Object can be accessed fully by an address (or an object) |
| Shared        | Object can be referenced and deleted by anyone            |
| Frozen        | Object can be accessed via immutable reference            |
| Party         | Depends on the Party settings ([see Party table](#party)) |

## Party

| Function       | Description                                  |
| -------------- | -------------------------------------------- |
| `single_owner` | Object has same permissions as Address Owned |

[transfer]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_transfer
[share]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_share_object
[freeze]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_freeze_object
[party]: https://docs.sui.io/references/framework/sui_sui/transfer#sui_transfer_party_transfer
