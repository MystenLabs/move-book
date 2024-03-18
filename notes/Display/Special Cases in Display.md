Learning from [[Sui Object Display Proposal]] and filling the gaps.

## Filling none for `Option<T>`

For the `sui::collectible::Collectible` we took the path of a smaller object with an 'option' to use what's necessary. To be more specific - most of the fields of the Collectible type are of type `Option<String>`. And unlike most of the display examples we had before, option needs some special handling. The only special something we can provide is a custom function. In this case, it should probably be "default()".

#### Example usage
```json
// JSON-like `Display<Collectible<T>>`
{
    "name": "{name.default('')}",
    "description": "{description.default('Ooh, this is lovely')}"
}
```

#### Generalized solution
```js
option_path.default("string")
```

## Dynamic fields

Dynamic field access was intended from the day 1. However the actual implementation seems to not avoid bulkiness. Since we encourage folks to use custom-type'd keys for the dynamic fields, writing full paths does not look good:
```json
{
	"name": "{df(0x0000000000000000000000000000000000000000000000000000::key::Field { id: \"0x0000000000000000000000000000000000000000000000000000\" }).name}",
}
```

On the one hand, it's relatively easy to hide behind a name service + a webpage (which will 100% be the case with Display eventually); on the other, storing 32-byte (64-char) addresses not only increases the chance to make a mistake but also increases the price of each consecutive rewrite.

Something to think about; yet if this operation is performed once (for most of the cases by default), may be worth the hassle.