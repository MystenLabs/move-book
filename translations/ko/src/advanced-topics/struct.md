# 구조

Structure is a custom type which contains complex data (or no data). It can be described as a simple key-value storage where key is a name of property and value is what's stored. Defined using keyword `struct`. Struct can have up to 4 abilities, they are specified with type definition.

구조는 복잡한 데이터를 포함하는 맞춤설정형 유형입니다(데이터를 포함하지 않을 수도 있음). 이 개념은 키-값 저장소로 표현될 수도 있는데, 이 때 키는 어느 속성의 이름이며 값은 저장된 내용을 뜻합니다. `struct` 라는 키워드를 사용하여 정의되는데, 구조체는 유형 정의를 통해 명시되는 능력을 최대 4개까지 보유할 수 있습니다.

> `struct` 는 Move에서 맞춤설정형 유형을 생성할 수 있는 유일한 방법입니다.

## 정의

구조체의 정의는 모듈 내부에서만 허용됩니다. `struct` 키워드로 시작하여 이름과 중괄호가 뒤를 잇는데, 이 때 구조체의 필드는 다음과 같이 정의됩니다.

```Move
struct NAME {
    FIELD1: TYPE1,
    FIELD2: TYPE2,
    ...
}
```

구조체의 정의에 관한 예시들을 참고하십시오.

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
*단일 구조체의 최대 필드 수는 65535입니다.*

각각의 정의된 구조체는 새로운 유형이 됩니다. 이 유형은 모듈 함수를 접근할 때와 마찬가지로, 모듈을 통해 접근할 수 있습니다.

```
M::MyStruct;
// or
M::Example;
```

### 반복된 정의

never 처럼 짧을 수 있습니다.

> 반복적인 구조체 정의는 불가능합니다.

다른 구조체를 유형으로 사용하는 것도 가능하지만 동일한 구조체를 반복적으로 사용할 수는 없습니다. Move 컴파일러는 반복되는 정의들을 점검하여 이러한 방식으로 코드를 컴파일할 수 없도록 합니다.

```Move
module M {
    struct MyStruct {

        // WON'T COMPILE
        field: MyStruct
    }
}
```

## 새 구조체 생성하기

이 유형을 사용하려면 *인스턴스*를 생성해야 합니다.

> 신규 인스턴스는 정의된 모듈 내부에만 생성될 수 있습니다.

신규 인스턴스를 생성하는 경우 정의를 사용하되, 유형을 전달하는 대신 해당 유형의 값을 전달합니다.

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

Move also allows you to create new instances shorter - by passing variable name which matches struct's field (and type!). We can simplify our `new_country()` method using this rule:

Move에서는 또한 구조체의 영역(및 유형!)에 일치하는 변수 이름을 전달함을 통해 신규 인스턴스를 더욱 짧게 생성할 수 있습니다. 이 규칙을 사용하면 `new_country()` 메서드를 좀 더 간단하개 표현할 수 있습니다.

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

(필드가 없고) 비어 있는 구조체를 생성하려면 중괄호를 사용해 주면 간단하게 처리됩니다.

```Move
public fun empty(): Empty {
    Empty {}
}
```

## 구조체 필드에 접근하기

(필드 없는 구조체를 생성하는 것이 가능하긴 하지만) 필드에 접근할 방법이 없었다면 구조체는 사실상 쓸모 없었을 것입니다.

> 모듈만 해당 구조체의 필드에 접근할 수 있습니다. 모듈 필드 외부는 개인 영역입니다.

구조체 필드는 모듈 내부에서만 확인할 수 있습니다. 해당 모듈 외부에서는 그저 한 유형으로 간주될 뿐입니다. 구조체의 영역에 접근하려면 `.` (마침표) 기호를 사용하십시오.

```Move
// ...
public fun get_country_population(country: Country): u64 {
    country.population // <struct>.<property>
}
```

만약 중첩된 구조체 유형이 동일한 모듈에 정의되어 있다면, 다음과 같이 일반적으로 설명될 수 있는 유사한 방식을 통해 접근할 수 있습니다.

```Move
<struct>.<field>
// and field can be another struct so
<struct>.<field>.<nested_struct_field>...
```

## 구조의 분해

구조를 *분해*하려면 `let <STRUCT DEF> = <STRUCT>` 구문을 사용합니다.

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

사용되지 않은 변수는 Move 에서 금지하고 있으며 필드를 사용하지 않고 어느 구조를 분해해야 할 필요가 있다는 점에 유념하십시오. 사용되지 않는 구조체 필드의 경우 밑줄 `_` 기호를 사용하십시오.

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

분해가 현재로서는 그리 중요하게 다가오지 않을 수 있으나, 자원 부분으로 넘어가게 되면 아주 중요하니까 꼭 기억해 두십시오.

### 구조체 필드에 획득자 함수 구현하기

구조체 필드를 외부에서 읽을 수 있게 하려면 해당 필드를 읽을 메서드들을 구현해서 반환 값으로 전달해야 합니다. 일반적으로 획득자 메서드는 구조체 필드와 동일한 방식으로 호출되나, 모듈이 하나 이상의 구조체를 정의하고 있는 경우 불편함을 유발할 수 있습니다.

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

획득자를 생성함으로써 모듈 사용자로 하여금 구조체의 필드에 접근할 수 있도록 합니다.

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

        C::destroy(country);
    }
}
```

---

이제 맞춤설정 유형의 구조체를 정의하는 방법을 알게 되셨는데, 초기 설정 상 해당 기능은 제한되어 있습니다. 다음 장에서는 이 유형의 값들을 어떻게 통제 및 사용하게 될지를 정의하는 방식인 능력에 대해 배워보도록 하겠습니다.