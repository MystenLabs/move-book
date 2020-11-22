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

Every defined struct becomes new a type. This type can be accessed through its module:
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

>New instances can only be created inside the module where they're defined.

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

> Only module can access its struct's fields. Outside of module struct fields are private.

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

To make struct fields readable outside, you need to implement methods which will read these fields and pass them as return values. Usually the getter method is called the same way as struct's field but it may cause inconvenience if you module defines more than one struct.

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
    use 0x1::Debug;

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

    // ...

    // we'll return values of this struct outside
    public fun destroy(country: Country): (u8, u64) {

        // variables must match struct fields
        // all struct fields must be specified
        let Country { id, population } = country;

        // after destruction country is dropped
        // but its fields are now variables and
        // can be used
        (id, population)
    }
}
```

You should remember that unused variables are prohibited in Move and sometimes you may need to destruct a structure without using its fields. For unused struct fields use `_` - underscore:

```Move
module Country {
    // ...

    public fun destroy(country: Country) {

        // this way you destroy struct and don't create unused variables
        let Country { id: _, population: _ } = country;

        // or take only id and don't init `population` variable
        // let Country { id, population: _ } = country;
    }
}
```

Destructuring may not be needed with structs. But remember it - it's going to play a huge part when we get to resources.
