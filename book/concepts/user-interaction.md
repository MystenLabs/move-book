# Interacting with a Package

Accounts interact with the blockchain by sending [transactions](./what-is-a-transaction.md). Transactions can call functions in a package, and can also deploy new packages. On Sui, a single transaction can contain multiple operations, we call them "commands". A command can be a call to a function, a deployment of a new package, upgrade of an existing one, or a combination of these. Commands can return values, which can be used in subsequent commands.

<!--
    Add an overview of types of transactions
    Give a schematic example of a transaction
-->
