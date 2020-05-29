# Struct

Structure is a custom type which contains complex data (or no data). It can be described as a simple key-value storage where key is a name of property and value is what's stored. Defined using keyword `struct`.

> Struct (and resource struct) is the only way to create custom type in Move.

### Definition

Structs can be defined only inside module.

```Move
module M {

    // struct can be without fields
    // but it is a new type
    struct Empty {}

    struct MyStruct {
        field1: address,
        field2: bool,
        field3: Empty
    }

    struct Example {
        field1: u8,
        field2: address,
        field3: u64,
        field4: bool,
        field5: bool,

        // you can use another struct as type
        field6: MyStruct
    }
}
```
*Max number of fields in one struct is 65535*.

Every defined struct becomes new type. This type can be accessed through its module:
```
M::MyStruct;
// or
M::Example;
```

### Recursive definition

> *Recursive struct definition* is impossible.

You are allowed to use another struct as type but you can't recursively use the same struct. Move compiler checks recursive definitions and won't let you compile code like this:

```Move
module M {
    struct MyStruct {

        // WON'T COMPILE
        field: MyStruct
    }
}
```

### Create new struct

To use this type you need to create its *instance*.

>New instances can only be created inside module where they're defined.

To create new instance use it's definition, but instead of passing types pass values of these types:

```Move
module M {
    struct Country {
        id: u8,
        population: u64
    }

    // Contry is a return type of this function!
    public fun new_country(c_id: u8, c_population: u64): Country {
        // structure creation is an expression
        let country = Country {
            id: c_id,
            population: c_population
        };

        country
    }
}
```

Move also allows you to create new instances shorter - by passing variable name which matches struct's field (and type!). We can simplify our `new_country()` method using this rule:

```Move
// ...
public fun new_country(id: u8, population: u64): Country {
    // id matches id: u8 field
    // population matches population field
    Country {
        id,
        population
    }

    // or even in one line: Country { id, population }
}
```

To create an empty struct (with no fields) simply use curly braces:

```Move
public fun empty(): Empty {
    Empty {}
}
```

### Access struct fields

Structs would have been almost useless if we hadn't had a way to access their fields (though you can create struct without fields).

> Only module can access it's struct's fields. Outside of module struct fields are private.

Struct fields are only visible inside its module. Outside of this module (in script or another module) it's just a type. To access struct's fields use `.` dot notation:

```Move
// ...
public fun get_country_population(country: Country): u64 {
    country.population // <struct>.<property>
}
```

If nested struct type is defined in the same module it can be accessed in similar manner which can be generally described as:

```Move
<struct>.<field>
// and field can be another struct so
<struct>.<field>.<nested_struct_field>...
```

### Implementing getter-functions for struct fields

To make struct fields readable outside, you need to implement methods which will read these fields and pass them as return values. Usually getter method is called the same way as struct's field but it may cause inconvenience if you module defines more than one struct.

```Move
module Country {

    struct Country {
        id: u8,
        population: u64
    }

    public fun new_country(id: u8, population: u64): Country {
        Country {
            id, population
        }
    }

    // don't forget to make these methods public!
    public fun id(country: &Country): u8 {
        country.id
    }

    // don't mind ampersand here for now. you'll learn why it's put here
    // in references chapter in next part of the book
    public fun population(country: &Country): u64 {
        country.population
    }
}
```

By making getters we've allowed module users access fields of our struct:

```Move
script {
    use {{sender}}::Country as C;
    use 0x0::Debug;

    fun main() {
        // variable here is of type C::Country
        let country = C::new_country(1, 10000000);

        Debug::print<u8>(
            &C::id(&country)
        ); // print id

        Debug::print<u64>(
            &C::population(&country)
        );

        // however this is impossible and will lead to compile error
        // let id = country.id;
        // let population = country.population.
    }
}
```

### Destructing structures

To *destruct* a struct use `let <STRUCT DEF> = <STRUCT>` syntax:

```Move
module Country {

    // ...s

    // we'll return values of this struct outside to use
    public fun destroy(country: Country): (u8, u64) {

        // variables must match struct fields
        let Country { id, population } = country;

        // after destruction contry is dropped
        // but its fields can be used
        (id, population)
    }
}
```

You should remember that unused variables are prohibited in Move and sometimes you may need to destruct without using structs fields. For unused struct fields use `_` - underscore:

```Move
module Country {
    // ...

    public fun destroy(country: Country) {

        // this way you destroy struct and don't create unused variables
        let Country { id: _, population: _ } = country;
    }
}
```



## Definition and Usage

Again: `struct` can be defined only inside module context.

```Move
module RecordsCollection {

    // struct can contain no fields it's
    // initialization will be simple:
    // let d = Dummy {};
    struct Dummy {}

    struct Record {
        author_id: u64,
        label_id: u64,
        year: u64,
        is_new: bool
    }

    // we can create new Record in a method
    public fun add_new(author_id: u64, label_id: u64, year: u64): Record {
        // when creating new struct use pattern:
        // <key>: <value>
        Record {
            author_id: author_id,
            label_id: label_id,
            year: year,
            is_new: true
        };

        // you can could also use short notation when variable
        // name matches name of the property
        let record: Record = Record {
            author_id,
            label_id,
            year,
            is_new: true
        };

        record
    }

    // since struct fields can only be accessed within module, you
    // have to provide interface to read structs if you pass it
    // outside of the module
    public fun print_year(r: Record): u64 {

        // to access struct's fields use "." (dot) notation
        r.year
    }
}
```

Let's take a better look at `add_new(...)` function. Since struct is a new type, it can also be a return type, and you're able to see it in function definition:

```Move
public fun add_new(author_id: u64, label_id: u64, year: u64): Record { /* ... */ }
```

Okay. How can we use our `Record` struct after we published `VinylShop` module into network?

```Move
script {
    use {{sender}}::VinylShop;

    fun add_new_record() {
        // we can use type-binding but we can't construct it - Rule #3
        let record : VinylShop::Record = VinylShop::add_new(10, 10, 1999);

        // here we can pass record type but can't use `record.year` - Rule #4
        if (VinylShop::print_year(record) == 1999) abort 11;
    }
}
```

## Destruction

In some cases you may need to destroy your struct and get it's contents. This operation called destruction.

```Move
module LongLive {

    struct T { value: u8 }

    public fun create(value: u8): T {
        T { value }
    }

    public fun destroy(t: T) {
        let T { value: _ } = T;
    }
}
```

Syntax for destructuring is the opposite to creation:
```
let T { <field1>, <field...> } = T;
```
