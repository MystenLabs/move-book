# Appendix A: Glossary

- Fast Path - term used to describe a transaction that does not involve shared objects, and can be
  executed without the need for consensus.
- Parallel Execution - term used to describe the ability of the Sui runtime to execute transactions
  in parallel, including the ones that involve shared objects.
- Internal Type - type that is defined within the module. Fields of this type can not be accessed
  from outside the module, and, in case of "key"-only abilities, can not be used in `public_*`
  transfer functions.

## Abilities

- key - ability that allows the struct to be used as a key in the storage. On Sui, the key ability
  marks an object and requires the first field to be a `id: UID`.
- store - ability that allows the struct to be stored inside other objects. This ability relaxes
  restrictions applied to internal structs, allowing `public_*` transfer functions to accept them as
  arguments. It also enables the object to be stored as a dynamic field.
- copy - ability that allows the struct to be copied. On Sui, the `copy` ability conflicts with the
  `key` ability, and can not be used together with it.
- drop - ability that allows the struct to be ignored or discarded. On Sui, the `drop` ability
  cannot be used together with the `key` ability, as objects are not allowed to be ignored.
