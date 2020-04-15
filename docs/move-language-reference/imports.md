# Imports

Default context in Move is empty - you can't operate Vector, you can't access Transaction details and you can't do almost anything (with small exception of built-in functions which will also require some Account features). To make your module or a script more meaningful and useful you need imports.

Here we need to take a step back and go through concept again. As I've mentioned in previous part there're two types of code transactions: `module` and `script`. Module is `deployed` and can be imported and used in a script. Not only custom deployed modules can be imported. There's also the `Standard library` (accessible at `0x0`) which significantly extends language functionality.

## Sender's address

Every transaction on blockchain is sent and signed by its sender, hence every module you or someone else publish to blockchain has sender's address which can be used to access/import this module.

In modifications of Move VM any address format can be used, so not to misguide you and to make this book as basic and general as it can be, I will use `{sender}` pattern to mark sender's address.

## Keyword `use`

To import module from address use this pattern:
```Move
use {sender}::ModuleName;
```

In `module` context import MUST be placed inside module definition:
```Move
module Lebowski {
    use {sender}::TheRug;

    public fun get_the_rug_back() {
        TheRug::tie_the_room_together();
    }
}
```

In `script` context import MUST be placed before `main()`.
```Move
// script context
use {sender}::Lebowski;

fun main() {
    Lebowski::get_the_rug_back();
}
```

### `use` meets `as`

You can change name of the imported module in your code using keyword `as`.

```Move
use 0x0::Transaction as TX;

fun main() {
    TX::assert(true, 11);
}
```

This may be used to shorten-up some dependencies or to resolve name conflicts between modules.

## Importing Standard library

Standard library is always accessible via `0x0` address. It can be used in both `module` and `script`.
```Move
module Printer {
    use 0x0::Transaction;

    public fun print_sender(): address {
        Transaction::sender()
    }
}
```

There will be a huge part of this book devoted to Standard library. TBD.
