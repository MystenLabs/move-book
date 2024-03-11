# 능력을 지니는 유형

Move는 아주 유연하고 맞춤 설정이 가능한 독특한 유형 체계를 가지고 있습니다. 각 유형은 최대 4개의 능력을 지닐 수 있으며, 능력을 사용함으로써 해당 유형의 값들이 어떻게 사용, 제외 또는 저장되는지를 정의하게 됩니다.

> 능력에는 복사, 제외, 비축 및 키 저장에 해당하는 4가지 종류가 있습니다.

간략하게 설명하자면 다음과 같은데,

- **Copy (복사)** - 값이 *복사*(또는 어느 값에 의해 복제)될 수 있습니다.
- **Drop (제외)** - 스코프 끝 부분에서 값을 *제외*할 수 있습니다.
- **Key (키)** - 값을 전체 저장 작업에 *키*로 사용할 수 있습니다.
- **Store (저장)** - 값을 전체 저장소 내부에 *저장*할 수 있습니다.

이 페이지에서는 `copy`와 `drop` 능력을 자세하게 다루고, `key`와 `store` 능력에 대한 맥락은 [자원](/resources/index.html) 장으로 넘어가면 더욱 상세하게 제공될 것입니다.

### 능력 구문

> 기본형 및 내재된 유형의 능력들은 사전에 정의되어 있으며 변경할 수 없습니다. 정수, 벡터, 주소 및 논리값에는 *복사*, *제외* 및 *저장* 능력이 있습니다.

그러나 구조체를 정의하는 경우 이 구문을 사용하여 모든 조합의 능력을 자유롭게 명시할 수 있습니다.

```Move
struct NAME has ABILITY [, ABILITY] { [FIELDS] }
```

또는 예를 들자면 다음과 같습니다.

```Move
module Library {
    
    // each ability has matching keyword
    // multiple abilities are listed with comma
    struct Book has store, copy, drop {
        year: u64
    }

    // single ability is also possible
    struct Storage has key {
        books: vector<Book>
    }

    // this one has no abilities 
    struct Empty {}
}
```

### 능력이 없는 구조체

능력을 사용하는 방법이나 언어 상 불러오게 되는 요소들을 곧바로 살펴보기에 앞서, 능력이 없는 언어란 어떤 일이 일어나는지를 알아봅시다.

```Move
module Country {
    struct Country {
        id: u8,
        population: u64
    }
    
    public fun new_country(id: u8, population: u64): Country {
        Country { id, population }
    }
}
```

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

메서드 `Country::new_country()`는 값을 하나 생성하는데, 이 값이 어디에도 전달되지 않고 함수가 끝날 때 자동으로 제외됩니다. 그러나 Country 유형에는 제외 능력이 없기 때문에 실패하게 되는 것입니다. 구조체 정의를 변경하여 제외 능력을 추가해 봅시다.

### 제외

능력 구문을 사용하면 이 구조체에 특정적인 `drop` 능력을 추가하게 됩니다. 이 구조체에 대응하는 모든 인스턴스가 제외 능력을 가지게 되며 *제외*가 가능해 질 것입니다.

```Move
module Country {
    struct Country has drop { // has <ability>
        id: u8,
        population: u64
    }
    // ...
}
```

이제 `Country` 구조체가 제외될 수 있으므로 스크립트를 실행할 수 있게 됩니다.

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000); // value is dropped
    }   
}
```

> **비고:** 제외 능력은 제외 동작만을 정의합니다. [*분해*](/advanced-topics/struct.html#destructing-structures) 는 제외 기능을 필요로 하지 않습니다.

### 복사

`Country` 구조체의 신규 인스턴스를 생성하고 제외하는 방법을 알아보았는데, *사본*을 생성하려고 하면 어떻게 해야 할까요? 초기 설정 상 구조체들은 값을 통해 전달되며, 해당 구조체의 사본을 생성하려면 `copy` 키워드를 사용하면 됩니다. ([다음 장](/advanced-topics/ownership-and-references.html)에서 상세하게 다룰 예정)

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

예상하셨겠지만 복사 능력이 없는 채로 유형의 사본을 만드는 것은 불가능합니다. 컴파일러 메시지는 분명합니다.

```Move
module Country {
    struct Country has drop, copy { // see comma here!
        id: u8,
        population: u64
    }
    // ...
}
```

해당 변경 사항을 바탕으로 상기 코드는 컴파일과 실행이 이루어질 것입니다.

### 요약

-   기본형에는 저장, 복사 및 제외 능력이 있습니다.
-   초기 설정 상 구조체에는 능력이 없습니다.
-   복사 및 제외 능력은 어떤 값들이 복사 및 제외될지를 각각 결정합니다.
-   한 구조체는 최대 4개의 능력을 지닐 수 있습니다.

### 추가 참고 자료

- [Move 능력 관련 설명](https://github.com/diem/diem/blob/main/language/changes/3-abilities.md)
