# Appendix C: Transfer Functions

## Transfer Functions Comparison

| Function         | Public Function         | End State     | Permissions          |
| ---------------- | ----------------------- | ------------- | -------------------- |
| `transfer`       | `public_transfer`       | Address Owned | Full                 |
| `share_object    | `public_share_object`   | Shared        | Ref, Mut Ref, Delete |
| `freeze_object   | `public_freeze_object`  | Frozen        | Ref                  |
| `party_transfer` | `public_party_transfer` | Party         | See Party table      |

## States Comparison

| State         | Description                                               |
| ------------- | --------------------------------------------------------- |
| Address Owned | Object can be accessed fully by an address (or an object) |
| Shared        | Object can be referenced and deleted by anyone            |
| Frozen        | Object can be accessed via immutable reference            |
| Party         | Depends on the Party settings (see Party table)           |

## Party

| Function       | Description                                  |
| -------------- | -------------------------------------------- |
| `single_owner` | Object has same permissions as Address Owned |
