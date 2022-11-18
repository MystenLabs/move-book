# 제네릭 이해하기

제네릭은 블록체인 세계에서 Move 언어가 독특성을 지니게 하며 Move의 유연성의 근원으로 작용하기 때문에 Move에 필수불가결한 요소입니다.

우선 [Rust Book](https://doc.rust-lang.org/stable/book/ch10-00-generics.html) 에서 인용하자면 제네릭은 구체적인 유형 또는 기타 속성을 대신하는 추상적인 대역입니다. 실제적인 측면에서 이야기하자면 제네릭은 단일 함수를 작성할 때 사용되는 방법으로, 어떠한 유형에도 사용할 수 있으며 이렇게 작성한 함수는 모든 유형의 견본 취급자로 사용될 수 있기 때문에 견본이라고 칭하기도 합니다.

Move에서 제네릭은 `struct`와 `function`의 서명에 적용될 수 있습니다.

### 구조체 내부에서의 정의

우선 `u64` 값을 저장하는 상자인 Box를 생성합시다. 이미 진행해 본 작업이므로 주석은 생략하겠습니다.

```Move
module Storage {
    struct Box {
        value: u64
    }
}
```

이 상자는 `u64` 유형의 값만 저장할 수 있다는 건 자명한 사실입니다. 그러나 동일한 상자를 `u8` 유형이나 `bool`형에 대응하도록 생성하고 싶다면 어떻게 할까요? `Box1`과 `Box2`를 생성하는 게 좋을까요? 아니면 다른 모듈을 발행해야 할까요? 둘 다 오답입니다. 제네릭을 사용하면 되니까요.

```Move
module Storage {
    struct Box<T> {
        value: T
    }
}
```

구조체 이름 옆에 `<T>`를 입력했습니다. 부등호 기호 `<..>`들은 제네릭의 유형을 정의하기 위해 사용하며, `T`는 이 구조체에서 우리가 견본으로 삼은 유형에 해당합니다. 구조체 바디 정의 내부에서는 `T`를 일반 유형으로 사용했습니다. `T`라는 유형은 실존하는 것이 아니라, *모든 유형*이 들어올 수 있도록 하는 문자입니다.

### 함수 내 서명

이제 `u64` 유형을 우선 값으로 사용할 이 구조체에 생성자를 생성하겠습니다.

```Move
module Storage {
    struct Box<T> {
        value: T
    }

    // type u64 is put into angle brackets meaning
    // that we're using Box with type u64
    public fun create_box(value: u64): Box<u64> {
        Box<u64>{ value }
    }
}
```

제네릭은 명시된 유형 매개 변수를 가져야 하기 때문에 약간 더 복잡한 정의를 지니는데, 따라서 일반 구조체 `Box`는 `Box<u64>`가 됩니다. 제네릭의 부등호 기호 안에는 모든 유형을 전달할 수 있습니다. `create_box`메서드를 더욱 일반성을 띠도록 하여 사용자들이 유형을 명시할 수 있게 처리해 줍시다. 다른 제네릭을 함수 서명에 활용함으로써 말입니다

```Move
module Storage {
    // ...
    public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }

    // we'll get to this a bit later, trust me
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }
}
```

### 함수 호출에서의 사용

우리는 방금 구조체에서 진행했던 방식과 동일하게, 부등호들을 함수 서명에서 함수의 이름 바로 뒤에 추가했습니다. 이제 이 함수를 어떻게 사용하면 좋을까요? 함수 호출 상에서 유형을 명시해 주면 됩니다.

```Move
script {
    use {{sender}}::Storage;
    use 0x1::Debug;

    fun main() {
        // value will be of type Storage::Box<bool>
        let bool_box = Storage::create_box<bool>(true);
        let bool_val = Storage::value(&bool_box);

        assert(bool_val, 0);

        // we can do the same with integer
        let u64_box = Storage::create_box<u64>(1000000);
        let _ = Storage::value(&u64_box);

        // let's do the same with another box!
        let u64_box_in_box = Storage::create_box<Storage::Box<u64>>(u64_box);

        // accessing value of this box in box will be tricky :)
        // Box<u64> is a type and Box<Box<u64>> is also a type
        let value: u64 = Storage::value<u64>(
            &Storage::value<Storage::Box<u64>>( // Box<u64> type
                &u64_box_in_box // Box<Box<u64>> type
            )
        );

        // you've already seen Debug::print<T> method
        // which also uses generics to print any type
        Debug::print<u64>(&value);
    }
}
```

여기에서는 3가지 유형, 즉 `bool`형, `u64` 그리고 `Box<u64>`를 토대로 Box 구조체를 사용했습니다. 마지막 유형은 굉장히 복잡해 보이겠지만 작동 방식을 이해하고 좀 더 친숙해 진 다음에는 루틴의 일부가 될 것입니다.

<!-- , Move opens in new way - the way you probably could never imagine in blockchains. -->

더 진행하기에 앞서 잠시 되돌아갑시다. `Box` 구조체에 제네릭을 추가함으로써 이 상자는 *추상적*인 성격을 지니게 되었는데, 우리가 활용할 수 있는 용량에 비해 정의는 상당히 간단한 편입니다. 이제는 `u64`, `address`, 심지어 다른 `box`나 구조체를 아우르는 모든 유형을 가지는 Box를 생성할 수 있습니다.

### 능력 확인의 제약 사항

[능력](/advanced-topics/abilities/README.md) 에 대해 앞서 배웠는데, 제네릭에서는 능력을 “확인” 하거나 *제약*하게 됩니다. 제약의 경우 대응하는 능력에 따라 이름이 결정됩니다.

```Move
fun name<T: copy>() {} // allow only values that can be copied
fun name<T: copy + drop>() {} // values can be copied and dropped
fun name<T: key + store + drop + copy>() {} // all 4 abilities are present
```

...또는 구조체의 경우

```Move
struct name<T: copy + drop> { value: T } // T can be copied and dropped
struct name<T: store> { value: T } // T can be stored in global storage
```

> 다음 구문을 숙지 바랍니다. `+`(plus)부호는 처음부터 직관적이지 않을 수 있으나, Move의 키워드 목록에서 유일하게 `+`를 사용하는 곳입니다.

제약이 걸린 시스템의 예시입니다.

```Move
module Storage {

    // contents of the box can be stored
    struct Box<T: store> has key, store {
        content: T
    }
}
```

또한 내부 유형(또는 제네릭 유형)은 반드시 컨테이너의 능력(`key`를 제외한 모든 능력이 해당)을 가져야 한다는 점도 숙지해 두십시오. 조금만 생각해 보면 모든 부분은 상식적이고 직관적입니다. **copy(복사)** 능력이 있는 구조체라면 내용 또한 복사 능력을 가져야 합니다. 그렇지 않다면 컨테이너 객체가 복사가능한 것으로 간주될 수 없을 것입니다. Move 컴파일러는 이 논리를 따르지 않는 코드도 컴파일하도록 허용하겠지만 해당 능력들은 사용할 수 없게 될 것입니다. 다음의 예시를 참조하십시오.

```Move
module Storage {
    // non-copyable or droppable struct
    struct Error {}
    
    // constraints are not specified
    struct Box<T> has copy, drop {
        contents: T
    }

    // this method creates box with non-copyable or droppable contents
    public fun create_box(): Box<Error> {
        Box { contents: Error {} }
    }
}
```

이 코드는 성공적으로 컴파일 및 발행이 진행되었습니다. 그러나 실행해 보게 되면…

```Move
script {
    fun main() {
        {{sender}}::Storage::create_box() // value is created and dropped
    }   
}
```

Box가 제외할 수 없다는 오류가 출력됩니다.
```
   ┌── scripts/main.move:5:9 ───
   │
 5 │   Storage::create_box();
   │   ^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

이런 일이 발생하는 이유는 내부 값에 제외 능력이 없기 때문입니다. 컨테이너의 능력은 내용에 의해 자동으로 제한이 되므로, 예를 들어 복사, 제외 및 저장 능력을 가진 컨테이너 구조체가 있고 내부 구조체에는 제외 능력밖에 없다면 해당 컨테이너를 복사하거나 저장하는 것은 불가능할 것입니다. 또 다른 관점에서 볼 때 이 컨테이너는 내부 유형에 대한 제약 사항을 가질 필요가 없이, 내부에 어떤 유형이 들어있든지 사용될 수 있는 유연성을 확보하는 것도 가능합니다.

> 그러나 실수를 피하기 위해 항상 점검을 게을리하지 말고, 필요하다면 함수와 구조체에서 제네릭 관련 제약사항을 명시하는 것이 좋습니다.

아래 구조체가 보다 안전한 예시가 되겠습니다.

```Move
// we add parent's constraints
// now inner type MUST be copyable and droppable
struct Box<T: copy + drop> has copy, drop {
    contents: T
}
```

### 제네릭에서의 여러 유형

유형은 한 개에서 그치지 않고 여러 개를 사용하는 것도 가능합니다. 제네릭 유형들은 부등호 기호 내부에 입력되며 쉼표로 분리합니다. 2가지 다른 유형을 가지는 상자 2개를 포함하는 새로운 유형인 `Shelf`를 추가해 봅시다.

```Move
module Storage {

    struct Box<T> {
        value: T
    }

    struct Shelf<T1, T2> {
        box_1: Box<T1>,
        box_2: Box<T2>
    }

    public fun create_shelf<Type1, Type2>(
        box_1: Box<Type1>,
        box_2: Box<Type2>
    ): Shelf<Type1, Type2> {
        Shelf {
            box_1,
            box_2
        }
    }
}
```

`Shelf`에 대응하는 유형 매개 변수를 수록하여 구조체의 필드 정의에 대응시켰습니다. 또한 여기에서 볼 수 있듯 제네릭 내부에 위치한 유형 매개 변수의 이름은 관계없습니다. 적절한 이름만 선택해 주면 되겠고, 각 유형 매개 변수는 정의 내부에서만 유효하기 때문에 `T1`이나 `T2`를 `T`와 대응시킬 필요는 없습니다.

다수의 제네릭 유형 매개 변수를 사용하는 것은 단일 변수의 사용 때와 크게 다르지 않습니다.

```Move
script {
    use {{sender}}::Storage;

    fun main() {
        let b1 = Storage::create_box<u64>(100);
        let b2 = Storage::create_box<u64>(200);

        // you can use any types - so same ones are also valid
        let _ = Storage::create_shelf<u64, u64>(b1, b2);
    }
}
```

*하나의 정의에서는 최대 18,446,744,073,709,551,615 (u64 크기) 개의 제네릭을 사용할 수 있습니다. 물론 이런 제한에 도달할 일은 전혀 없으니, 제한 받을 염려 없이 마음껏 필요한 만큼 사용하시면 됩니다.*

### 사용되지 않은 유형의 매개 변수

제네릭에서 명시된 모든 유형이 사용될 필요는 없습니다. 다음의 예시를 참고해 주십시오.

```Move
module Storage {

    // these two types will be used to mark
    // where box will be sent when it's taken from shelf
    struct Abroad {}
    struct Local {}

    // modified Box will have target property
    struct Box<T, Destination> {
        value: T
    }

    public fun create_box<T, Dest>(value: T): Box<T, Dest> {
        Box { value }
    }
}
```

때로는 작업에 제네릭을 제약 또는 상수로 사용하는 것도 적절한 선택입니다. 스크립트에서의 사용법을 함께 보도록 합시다.

```Move

script {
    use {{sender}}::Storage;

    fun main() {
        // value will be of type Storage::Box<bool>
        let _ = Storage::create_box<bool, Storage::Abroad>(true);
        let _ = Storage::create_box<u64, Storage::Abroad>(1000);

        let _ = Storage::create_box<u128, Storage::Local>(1000);
        let _ = Storage::create_box<address, Storage::Local>(0x1);

        // or even u64 destination!
        let _ = Storage::create_box<address, u64>(0x1);
    }
}
```

여기에서는 제네릭을 사용하여 유형을 표시했지만, 실제로 사용하지는 않습니다. 왜 이러한 정의가 중요한지는 자원 개념을 배울 때 함께 습득하시게 될 것입니다. 우선 지금은 제네릭의 또 다른 사용법이라고만 이해하셔도 무방합니다.

<!-- ### Copyable

*Copyable kind* - is a kind of types, value of which can be copied. `struct`, `vector` and primitive types - are three main groups of types fitting into this kind.

To understand why Move needs this constraint let's see this example:

```Move
module M {
    public fun deref<T>(t: &T): T {
        *t
    }
}
```

By using *dereference* on a reference you can *copy* the original value and return it as a regular. But what if we've tried to use `resource` in this example? Resource can't be copied, hence this code would fail. Hopefully compiler won't let you compile this type, and kinds exist to manage cases like this.

```Move
module M {
    public fun deref<T: copyable>(t: &T): T {
        *t
    }
}
```

We've added `: copyable` constraint into generic definition, and now type `T` must be of kind *copyable*. So now function accepts only `struct`, `vector` and primitives as type parameters. This code compiles as constraint provides safety over used types and passing non-copyable value here is impossible.

### Resource

Another kind has only one type inside is a `resource` kind. It is used in the same manner:

```Move
module M {
    public fun smth<T: resource>(t: &T) {
        // do smth
    }
}
```

This example here is only needed to show syntax, we'll get to resources soon and you'll learn actual use cases for this constraint. -->
