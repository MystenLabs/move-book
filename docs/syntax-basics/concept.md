# Concept

Unlike other blockchain languages (e.g. Solidity) Move proposes separation of *scripts* (or *transaction-as-script*) and *modules*. The former allows you to put more logic into your transactions and make them more flexible while saving your time and resources; and the latter allows developers to extend blockchain functionality or to implement custom *smart-contracts* with a variety of options.

In basics we'll start with scripts as they're pretty friendly for a newcomer, and then we'll get to modules.

### Note

Not all of the Move versions (dialects) support scripts, for example, in [Sui Move](https://docs.sui.io/) scripts are disabled, and only modules with callable "public" functions are allowed. If you're building on the building on a platform that does not support scripts, an easy replacement for the `script {}` blocks would be:


```Move
// Script syntax
script {
    fun main() {

    }
}

// Similar structure for languages not-supporting scripts
module example::script {
    public fun main() {
        // ...
    }
}
```
