Publish fails - unused value. With the addition of package upgrades, publish transaction returns an `UpgradeCap`. The reason for why this value is not a return value of the init function is that this object is always created by the system and can not be constructed manually in Move. For the transaction to be executed, the value must be used (eg by transfering to sender).

Input kinds: ObjectRef, Pure, SharedObjectRef. These are the only types of inputs that can be used in a Transaction Block. ObjectRef - a single owned object - the reference always includes the objectId, version and digest. SharedObjectRef - a shared object - includes initial version and objectId. Pure - stands for all the other types of _non-object_ inputs: String, `vector<T>`, ID, address, integers and the bool type. Vector in `Pure` argument type can only be a vector of "pure" - non-object - values.

How do I make a vector of Coin or any object? For that, there's a special call - `tx.makeMoveVec([...])` which is used to construct a vector of objects. The return value of this call is a vector of `T` depending on what was passed initially.

```
let [coin_vec] = tx.makeMoveVec([tx.object(...), tx.object(...)]);
```


- Option::some() for T
- transfer vec?
- pure vs object
- Option(T)
- Reuse input multiple times (explicit input)
- reuse versions of objects

- detailed guide on TxBlock; 