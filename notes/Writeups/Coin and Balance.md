We have two main modules when it comes to "tokens" or "coins" - sui::balance and sui::coin. The former defines the basic primitive for balances - Balance that has only store ability; and the latter wraps it and gives an interface to "own" a balance by having it inside a Coin  with abilities key + store. It can be simplified and described as "low" level balance and "high" level coin.

Just like this Coin(Balance) relation, we have a TreasuryCap(Supply). Supply controls minting and burning Balances, and TreasuryCap does the same thing for Coin(s). 

The reason for why we have conversion TreasuryCap -> Supply is that the TreasuryCap comes with more guarantees - there can only be a single TreasuryCap<T> for T as it requires a One-Time-Witness and there will always be CoinMetadata - that's a requirement of the coin::create_currency method.

With Supply things are simpler and more flexible - one can create any number of Supply<T> for T because it only requires a simple Witness, metadata currently doesn't exist for Supply and won't be a requirement.

Now to the topic of conversion: turning TreasuryCap into a Supply is a **secure action** - all guarantees of the TreasuryCap are enforced on creation (uniqueness + metadata), so the resulting Supply will still be just as meaningful and useful as the TC, with one limitation - it now requires a container to be stored and can't be owned directly.
