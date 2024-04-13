# Hello, Sui!

In the [previous section](./hello-world.md) we created a new package and demonstrated the basic flow
of creating, building, and testing a Move package. In this section, we will write a simple
application that uses the storage model and can be interacted with. To do this, we will create a
simple todo list application.

## Create a New Package

Following the same flow as in [Hello, World!](./hello-world.md), we will create a new package called
`todo_list`.

```bash
$ sui move new todo_list
```

## Add the code

To speed things up and focus on the application logic, we will provide the code for the todo list
application. Replace the contents of the _sources/todo_list.move_ file with the following code:

> Note: while the contents may seem overwhelming at first, we will break it down in the following
> sections. Try to focus on what's at hand right now.

```move
{{#include ../../../packages/todo_list/sources/todo_list.move:all}}
```

## Build the package

To make sure that we did everything correctly, let's build the package by running the
`sui move build` command. If everything is correct, you should see the output similar to the
following:

```bash
$ sui move build
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING todo_list
```

If there are no errors following this output, you have successfully built the package. If there are
errors, make sure that:

- The code is copied correctly
- The file name and the package name is correct

There are not many other reasons for the code to fail at this stage. But if you are still having
issues, try looking up the structure of the package in
[this location](https://github.com/MystenLabs/move-book/tree/main/packages/todo_list).

## Set up an account

To publish and interact with the package, we need to set up an account. For the sake of simplicity
and demonstration purposes, we will use _sui devnet_ environment.

> If you already have an account set up, you can skip this step.

If you are doing it for the first time, you will need to create a new account. To do this, run the
`sui client` command, then the CLI will prompt with you multiple questions, the answers are marked
below with `>`:

```bash
$ sui client
Config file ["/path/to/home/.sui/sui_config/client.yaml"] doesn't exist, do you want to connect to a Sui Full node server [y/N]?
> y
Sui Full node server URL (Defaults to Sui Devnet if not specified) :
>
Select key scheme to generate keypair (0 for ed25519, 1 for secp256k1, 2: for secp256r1):
> 0
```

After you have answered the questions, the CLI will generate a new keypair and save it to the
configuration file. You can now use this account to interact with the network.

To check that we have the account set up correctly, run the `sui client active-address` command:

```bash
$ sui client active-address
0x....
```

The command will output the address of your account, it starts with `0x` followed by 64 characters.

## Requesting Coins

In _devnet_ and _testnet_ environments, the CLI provides a way to request coins to your account, so
you can interact with the network. To request coins, run the `sui client faucet` command:

```bash
$ sui client faucet
Request successful. It can take up to 1 minute to get the coin. Run sui client gas to check your gas coins.
```

After waiting a little bit, you can check that the Coin object was sent to your account by running
the `sui client balance` command:

```bash
$ sui client balance
╭────────────────────────────────────────╮
│ Balance of coins owned by this address │
├────────────────────────────────────────┤
│ ╭──────────────────────────────────╮   │
│ │ coin  balance (raw)  balance     │   │
│ ├──────────────────────────────────┤   │
│ │ Sui   10000000000    10.00 SUI   │   │
│ ╰──────────────────────────────────╯   │
╰────────────────────────────────────────╯
```

Alternatively, you can query _objects_ owned by your account, by running the `sui client objects`
command. The actual output will be different, because the object ID is unique, and so is digest, but
the structure will be similar:

```bash
$ sui client objects
╭───────────────────────────────────────────────────────────────────────────────────────╮
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x4ea1303e4f5e2f65fc3709bc0fb70a3035fdd2d53dbcff33e026a50a742ce0de  │ │
│ │ version    │  4                                                                   │ │
│ │ digest     │  nA68oa8gab/CdIRw+240wze8u0P+sRe4vcisbENcR4U=                        │ │
│ │ objectType │  0x0000..0002::coin::Coin                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
╰───────────────────────────────────────────────────────────────────────────────────────╯
```

Now that we have the account set up and the coins in the account, we can interact with the network.
We will start by publishing the package to the network.

## Publish

To publish the package to the network, we will use the `sui client publish` command. The command
will automatically build the package and use its bytecode to publish in a single transaction.

> We are using the `--gas-budget` argument during publishing. It specifies how much gas we are
> willing to spend on the transaction. We won't touch on this topic in this section, but it's
> important to know that every transaction in Sui costs gas, and the gas is paid in SUI coins.

The `gas-budget` is specified in _MISTs_. 1 SUI equals 10^9 MISTs. For the sake of demonstration, we
will use 100,000,000 MISTs, which is 0.1 SUI.

```bash
# run this from the `todo_list` folder
$ sui client publish --gas-budget 100000000

# alternatively, you can specify path to the package
$ sui client publish --gas-budget 100000000 todo_list
```

The output of the publish command is rather lengthy, so we will show and explain it in parts.

```bash
$ sui client publish --gas-budget 100000000
UPDATING GIT DEPENDENCY https://github.com/MystenLabs/sui.git
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING todo_list
Successfully verified dependencies on-chain against source.
Transaction Digest: GpcDV6JjjGQMRwHpEz582qsd5MpCYgSwrDAq1JXcpFjW
```

As you can see, when we run the `publish` command, the CLI first builds the package, then verifies
the dependencies on-chain, and finally publishes the package. The output of the command is the
transaction digest, which is a unique identifier of the transaction and can be used to query the
transaction status.

### Transaction Data

Next section is `TransactionData` which contains the information about the transaction we just sent.
It features fields like `sender` which is your address, the `gas_budget` that we set, as well as the
Coin we used for payment. It also prints the Commands that were run by the CLI, in our case it's
`Publish` and `TransferObject` - the latter transfers a special object `UpgradeCap` to the sender.

The section titled `TransactionData` contains the information about the transaction we just sent. It
features fields like `sender`, which is your address, the `gas_budget` set with the `--gas-budget`
argument, and the Coin we used for payment. It also prints the Commands that were run by the CLI. In
this example, the commands `Publish` and `TransferObject` were run - the latter transfers a special
object `UpgradeCap` to the sender.

```plaintext
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                             │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1                                   │
│ Gas Owner: 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1                                │
│ Gas Budget: 100000000 MIST                                                                                   │
│ Gas Price: 1000 MIST                                                                                         │
│ Gas Payment:                                                                                                 │
│  ┌──                                                                                                         │
│  │ ID: 0x4ea1303e4f5e2f65fc3709bc0fb70a3035fdd2d53dbcff33e026a50a742ce0de                                    │
│  │ Version: 7                                                                                                │
│  │ Digest: AXYPnups8A5J6pkvLa6RekX2ye3qur66EZ88mEbaUDQ1                                                      │
│  └──                                                                                                         │
│                                                                                                              │
│ Transaction Kind: Programmable                                                                               │
│ ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                                            │ │
│ ├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Pure Arg: Type: address, Value: "0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1" │ │
│ ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭─────────────────────────────────────────────────────────────────────────╮                                  │
│ │ Commands                                                                │                                  │
│ ├─────────────────────────────────────────────────────────────────────────┤                                  │
│ │ 0  Publish:                                                             │                                  │
│ │  ┌                                                                      │                                  │
│ │  │ Dependencies:                                                        │                                  │
│ │  │   0x0000000000000000000000000000000000000000000000000000000000000001 │                                  │
│ │  │   0x0000000000000000000000000000000000000000000000000000000000000002 │                                  │
│ │  └                                                                      │                                  │
│ │                                                                         │                                  │
│ │ 1  TransferObjects:                                                     │                                  │
│ │  ┌                                                                      │                                  │
│ │  │ Arguments:                                                           │                                  │
│ │  │   Result 0                                                           │                                  │
│ │  │ Address: Input  0                                                    │                                  │
│ │  └                                                                      │                                  │
│ ╰─────────────────────────────────────────────────────────────────────────╯                                  │
│                                                                                                              │
│ Signatures:                                                                                                  │
│    gebjSbVwZwTkizfYg2XIuzdx+d66VxFz8EmVaisVFiV3GkDay6L+hQG3n2CQ1hrWphP6ZLc7bd1WRq4ss+hQAQ==                  │
│                                                                                                              │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Transaction Effects

Transaction Effects contains the status of the transaction, the changes that the transaction made to
the state of the network and the objects involved in the transaction.

```plaintext
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: GpcDV6JjjGQMRwHpEz582qsd5MpCYgSwrDAq1JXcpFjW                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 411                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x160f7856e13b27e5a025112f361370f4efc2c2659cb0023f1e99a8a84d1652f3                         │
│  │ Owner: Account Address ( 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1 )  │
│  │ Version: 8                                                                                     │
│  │ Digest: 8y6bhwvQrGJHDckUZmj2HDAjfkyVqHohhvY1Fvzyj7ec                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x468daa33dfcb3e17162bbc8928f6ec73744bb08d838d1b6eb94eac99269b29fe                         │
│  │ Owner: Immutable                                                                               │
│  │ Version: 1                                                                                     │
│  │ Digest: Ein91NF2hc3qC4XYoMUFMfin9U23xQmDAdEMSHLae7MK                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x4ea1303e4f5e2f65fc3709bc0fb70a3035fdd2d53dbcff33e026a50a742ce0de                         │
│  │ Owner: Account Address ( 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1 )  │
│  │ Version: 8                                                                                     │
│  │ Digest: 7ydahjaM47Gyb33PB4qnW2ZAGqZvDuWScV6sWPiv7LTc                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0x4ea1303e4f5e2f65fc3709bc0fb70a3035fdd2d53dbcff33e026a50a742ce0de                         │
│  │ Owner: Account Address ( 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1 )  │
│  │ Version: 8                                                                                     │
│  │ Digest: 7ydahjaM47Gyb33PB4qnW2ZAGqZvDuWScV6sWPiv7LTc                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 10404400 MIST                                                                    │
│    Computation Cost: 1000000 MIST                                                                 │
│    Storage Rebate: 978120 MIST                                                                    │
│    Non-refundable Storage Fee: 9880 MIST                                                          │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    7Ukrc5GqdFqTA41wvWgreCdHn2vRLfgQ3YMFkdks72Vk                                                   │
│    7d4amuHGhjtYKujEs9YkJARzNEn4mRbWWv3fn4cdKdyh                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Events

If there were any _events_ emitted, you would see them in this section. Our package does not use
events, so the section is empty.

```plaintext
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯
```

### Object Changes

These are the changes to _objects_ that transaction has made. In our case, we have _created_ a new
`UpgradeCap` object which is a special object that allows the sender to upgrade the package in the
future, _mutated_ the Gas object, and _published_ a new package. Packages are also objects on Sui.

These are the changes to _objects_ that the transaction has made. In our case, we have _created_ a
new `UpgradeCap` object which is a special object that allows the sender to upgrade the package in
the future, _mutate_ the Gas object, and _published_ a new package. Packages are also objects on
Sui.

```plaintext
╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x160f7856e13b27e5a025112f361370f4efc2c2659cb0023f1e99a8a84d1652f3                  │
│  │ Sender: 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1                    │
│  │ Owner: Account Address ( 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1 ) │
│  │ ObjectType: 0x2::package::UpgradeCap                                                          │
│  │ Version: 8                                                                                    │
│  │ Digest: 8y6bhwvQrGJHDckUZmj2HDAjfkyVqHohhvY1Fvzyj7ec                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x4ea1303e4f5e2f65fc3709bc0fb70a3035fdd2d53dbcff33e026a50a742ce0de                  │
│  │ Sender: 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1                    │
│  │ Owner: Account Address ( 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 8                                                                                    │
│  │ Digest: 7ydahjaM47Gyb33PB4qnW2ZAGqZvDuWScV6sWPiv7LTc                                          │
│  └──                                                                                             │
│ Published Objects:                                                                               │
│  ┌──                                                                                             │
│  │ PackageID: 0x468daa33dfcb3e17162bbc8928f6ec73744bb08d838d1b6eb94eac99269b29fe                 │
│  │ Version: 1                                                                                    │
│  │ Digest: Ein91NF2hc3qC4XYoMUFMfin9U23xQmDAdEMSHLae7MK                                          │
│  │ Modules: todo_list                                                                            │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Balance Changes

This last section contains changes to SUI Coins, in our case, we have _spent_ around 0.015 SUI,
which in MIST is 10,500,000. You can see it under the _amount_ field in the output.

```plaintext
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x091ef55506ad814920adcef32045f9078f2f6e9a72f4cf253a1e6274157380a1 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -10426280                                                                              │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Alternative Output

It is possible to specify the `--json` flag during publishing to get the output in JSON format. This
is useful if you want to parse the output programmatically or store it for later use.

```bash
$ sui client publish --gas-budget 100000000 --json
```

### Using the Results

After the package is published on chain, we can interact with it. To do this, we need to find the
address (object ID) of the package. It's under the `Published Objects` section of the
`Object Changes` output. The address is unique for each package, so you will need to copy it from
the output.

In this example, the address is:

```plaintext
0x468daa33dfcb3e17162bbc8928f6ec73744bb08d838d1b6eb94eac99269b29fe
```

Now that we have the address, we can interact with the package. In the next section, we will show
how to interact with the package by sending transactions.

## Sending Transactions

To demonstrate the interaction with the `todo_list` package, we will send a transaction to create a
new list and add an item to it. Transactions are sent via the `sui client call` command.
