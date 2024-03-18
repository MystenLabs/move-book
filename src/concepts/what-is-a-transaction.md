# Transaction

Transaction is a fundamental concept in the blockchain world. It is a way to interact with a blockchain. Transactions are used to change the state of the blockchain, and they are the only way to do so. In Move, transactions are used to call functions in a package, deploy new packages, and upgrade existing ones.


<!--

- how user interacts with a program
    - mention public functions
    - give a concept of an entry / public function without getting into details
    - mention that functions are called in transactions
    - mention that transactions are sent by accounts
    - every transaction specifies object it operates on

 -->

## Transaction Structure

Transactions consist of:

- a sender - the account that *signs* the transaction
- a list (or a chain) of commands - the operations to be executed
- command inputs - the arguments for the commands
- a gas object - the object used to pay for the transaction
- gas price and budget - the cost of the transaction
