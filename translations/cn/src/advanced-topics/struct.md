# 结构体

结构体是自定义类型，它可以包含复杂数据，也可以不包含任何数据。结构体由字段组成，可以简单地理解成"key-value"存储，其中 key 是字段的名称，而 value 是存储的内容。结构体使用关键字 struct 定义。

> 结构体是在 Move 中创建自定义类型的唯一方法。

### 定义

结构体只能在模块内部定义，并且以关键字 `struct` 开头：
```Move
struct NAME {
    FIELD1: TYPE1,
    FIELD2: TYPE2,
    ...
}
```
我们来看一些例子：

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
*一个结构体最多可以有 65535 个字段。*

被定义的结构体会成为新的类型，可以通过定义它的模块访问此类型：

```
M::MyStruct;
// or
M::Example;
```

### 定义递归结构体

> *定义递归结构体* 是不允许的。

Move 允许使用其它结构作为成员，但不能递归使用相同的结构体。Move 编译器会检查递归定义，不允许下面这样的代码：

```Move
module M {
    struct MyStruct {

        // WON'T COMPILE
        field: MyStruct
    }
}
```

### 创建结构体实例

> 要使用某结构体类型，需要先创建其实例。

可以用结构体的定义来创建实例，不同的是传入具体的值而不是类型。

```Move
module Country {
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

还可以通过传递与结构体的字段名匹配的变量名来简化创建新实例的代码。下面的 new_country() 函数中使用了这个简化方法：

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

要创建一个空结构体（没有字段），只需使用花括号：

```Move
public fun empty(): Empty {
    Empty {}
}
```

### 访问结构体成员字段

如果我们没有办法访问结构体的字段，那么它几乎是无用的。

> 只有在模块内才可以访问其结构体的字段。在模块之外，该结构体字段是不可见的。

结构字段仅在其模块内部可见。在此模块之外（在脚本或其他模块中），它只是一种类型。要访问结构的字段，请使用"."符号：

```Move
// ...
public fun get_country_population(country: Country): u64 {
    country.population // <struct>.<property>
}
```
如果在同一模块中定义了嵌套结构类型，则可以用类似的方式对其进行访问，通常可以将其描述为：

```Move
<struct>.<field>
// and field can be another struct so
<struct>.<field>.<nested_struct_field>...
```

### 为结构体字段实现 getter 方法

为了使结构体字段在外部可读，需要实现一些方法，这些方法将读取这些字段并将它们作为返回值传递。通常，getter 方法的调用方式与结构体的字段相同，但是如果你的模块定义了多个结构体，则 getter 方法可能会带来不便。

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

    // don't mind ampersand here for now. you'll learn why it's 
    // put here in references chapter 
    public fun population(country: &Country): u64 {
        country.population
    }

    // ... fun destroy ... 
}
```

通过 getter 方法，我们允许模块的使用者访问结构体的字段：

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

### 回收结构体

解构、或者销毁结构体需要使用语法 `let <STRUCT DEF> = <STRUCT>`：

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

请注意，Move 中禁止定义不会被使用的变量，有时你可能需要在不使用其字段的情况下销毁该结构体。对于未使用的结构体字段，请使用下划线"_"表示：

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

销毁结构体并不是必需的，但是，我们即将介绍的 Resource 结构体则必需被销毁。
