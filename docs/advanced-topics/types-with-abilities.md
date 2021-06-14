# Types with Abilities

Move has unique type system which is very flexible and customizable. Each type can have up to 4 abilities which define how values of this type can be used, dropped or stored.

> There are 4 type abilities: Copy, Drop, Store and Key.

Simply described:

- **Copy** - value can be *copied* (or cloned by value). 
- **Drop** - value can be *dropped* by the end of scope.
- **Key** - value can be *used as a key* for global storage operations
- **Store** - value can be *stored* inside global storage 

On this page we will go through `Copy` and `Drop` abilities in detail; more context over `Key` and `Store` abilities will be given when we get to [Resources](/resources/index.html) chapter. 

## Abilities syntax

> Primitive and built-in types' abilities are pre-defined and unchangeable: integers, vector, addresses and boolean values have *copy*, *drop* and *store* abilities

However when defining structs you can specify any set of abilities using this syntax:

```Move
struct <name> has <ability> [, <ability>] { [<field definition>...] }
```

Or by example:

```Move
module Library {
    
    // each ability has matching keyword
    // multiple abilities are listed with comma
    struct Book has store, copy, drop {
        name: vector<u8>
    }

    // single ability is also possible
    struct Storage has key {
        books: vector<Book>
    }

    // this one has no abilities 
    struct Empty {}
}
```

### Struct with no Abilities

First, let's define struct without abilities.

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000);
    }   
}
```

If you try to run this code, you'll get the following error:
```
error: 
   ┌── scripts/main.move:5:9 ───
   │
 5 │     Country::new_country(1, 1000000);
   │     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

Method `Country::new_country()` creates a value; this value is not passed anywhere and automatically dropped when function ends; but Country type doesn't have *Drop* ability, and it fails. Now let's change our struct definition and add **Drop** Ability.

### Drop

Using abilities syntax we add `has drop` specifying `drop` ability for this struct. All of the instances of this struct will have drop ability and hence will be *droppable*. 

```Move
module Country {
    struct Country has drop { // has <ability>
        id: u8,
        population: u64
    }
    // ...
}
```

Now, when struct `Country` can be dropped, our script can be run.

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000); // value is dropped
    }   
}
```

> **Note:** Drop ability only defines *drop* behavior. [*Destructuring*](/advanced-topics/struct.html#destructing-structures) does not require Drop.

### Copy

We learned how to create new instances of struct `Country` and drop them. But what if we wanted to create a *copy*? By default, structs are passed by value; and to create a copy of this struct we will use keyword `copy` (you will learn more about this behavior [in the next chapter](/advanced-topics/ownership-and-references.html)):

```Move
script {
    use {{sender}}::Country;

    fun main() {
        let country = Country::new_country(1, 1000000);
        let _ = copy country;
    }   
}
```

```
   ┌── scripts/main.move:6:17 ───
   │
 6 │         let _ = copy country;
   │                 ^^^^^^^^^^^^ Invalid 'copy' of owned value without the 'copy' ability
   │
```

As you could expect, making a copy of type without copy ability failed. Compiler message is clear:

```Move
module Country {
    struct Country has drop, copy { // see comma here!
        id: u8,
        population: u64
    }
    // ...
}
```

With that change code above would compile and run.

### Further reading

- [Move Abilities Description](https://github.com/diem/diem/blob/main/language/changes/3-abilities.md)
