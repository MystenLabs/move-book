# 리소스 생성 및 이동

먼저 모듈을 생성합니다.

```Move
// modules/Collection.move
module Collection {


    struct Item has store {
        // we'll think of the properties later
    }

    struct Collection has key {
        items: vector<Item>
    }
}
```

> 모듈 다음의 모듈에서 주 리소스를 호출하기 위한 규칙이 있습니다(e.g. Collection::Collection). 규칙을 따른다면 여러분의 모듈을 다른 사람들이 쉽게 읽고 사용할 수 있습니다.

### 생성 및 이동

*키* 기능을 갖는 `컬렉션` 구조체를 정의했으며, `Collection` 은 유형 `Item` 의 벡터를 담습니다. 신규 컬렉션을 시작하고 *계좌에 리소스를 저장하는지* 살펴봅니다. 여기서 저장되는 리소스는 전송자의 주소에 영원히 남아있습니다. 그 소유자로부터 리소스를 변조하거나 탈취할 수 없습니다.

```Move
// modules/Collection.move
module Collection {

    use 0x1::Vector;

    struct Item has store {}

    struct Collection has key {
        items: vector<Item>
    }

    /// note that &signer type is passed here!
    public fun start_collection(account: &signer) {
        move_to<Collection>(account, Collection {
            items: Vector::empty<Collection>()
        })
    }
}
```

Remember [signer](/resources/signer-type.md)? Now you see how it in action! To *move* resource to account you have built-in function *move_to* which takes `signer` as a first argument and `Collection` as second. Signature of `move_to` function can be represented like:

[signer](/resources/signer-type.md)를 기억 하시나요? 이제 실전에서 사용해볼 때가 되었습니다. 계좌에 리소스를 *이동*시키려면 내장 함수인 *move_to* 를 사용하여 `signer` 를 첫 인자로, `Collection` 을 두 번째로 사용합니다. `move_to` 함수의 시그니처는 다음과 같이 표현될 수 있습니다:

```Move

native fun move_to<T: key>(account: &signer, value: T);

```

이는 두 가지 결론으로 귀결됩니다.

1. 본인의 계좌에만 리소스를 넣을 수 있으며, 타인 계좌의 `signer` 값에 접근할 수 없기에 리소스를 넣을 수 없습니다다.
2. 하나의 계좌에는 하나의 유형을 갖는 하나의 리소스만을 저장할 수 있습니다. 동일한 작업을 두 번 하는 경우 기존 리소스를 파기하게 되고, 이는 발생해서는 안 됩니다. (코인이 저장되어 있는데 부주의로 인해 잔고 없음을 입력하여 저장된 모든 코인을 잃는 것을 생각해보면 됩니다!). 존재하는 리소스를 생성하려는 두 번째 시도는 에러와 함께 실패할 것입니다. 

### 주소에서 존재 확인하기

To check if resource exists at given address Move has `exists` function, which signature looks similar to this.

특정 주소에서 리소스가 존재하는지 확인하기 위해서는 `exists` 함수를 사용하며, 시그니쳐는 다음과 같습니다. 

```Move

native fun exists<T: key>(addr: address): bool;
    
```

제네릭 유형을 사용했기에 해당 함수는 유형에 독립적이며, 주소에 존재하는지 확인하기 위해 그 어떠한 리소스도 사용할 수 있습니다. 실제로 특정 주소에 리소스가 존재하는지 확인하는 것은 누구나 할 수 있습니다. 하지만 존재를 확인하는 것은 저장된 값에 접근하는 것을 의미하지 않습니다!

사용자가 이미 컬렉션을 갖고 있는지 확인하는 함수를 작성해 봅시다.

```Move
// modules/Collection.move
module Collection {

    struct Item has store, drop {}

    struct Collection has store, key {
        items: Item
    }

    // ... skipped ...

    /// this function will check if resource exists at address
    public fun exists_at(at: address): bool {
        exists<Collection>(at)
    }
}
````

---

리소스를 생성하고, 전송자에게 이동하며, 리소스가 이미 존재하는지 확인할 수 있습니다. 이제는 리소스를 읽고 수정하는 방법을 배울 시간입니다!