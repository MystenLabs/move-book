# 리소스 읽기 및 수정

To read and modify resource Move has two more built-in functions. Their names perfectly match their goals: `borrow_global` and `borrow_global_mut`.

리소스를 읽고 수정하기 위해 Move는 2개의 내재 함수를 갖고 있으며, 함수들의 명칭은 그 목적을 다음과 같이 정확히 명시합니다: `borrow_global` 과 `borrow_global_mut`.

## `borrow_global`를 사용한 불변형 대여

[소유 및 참조](/advanced-topics/ownership-and-references.md)에 대한 부분에서 변형 (&mut) 및 불변형 참조에 대해서 이미 학습하였습니다. 그 지식을 실전에 적용할 때입니다!

```Move
// modules/Collection.move
module Collection {

    // added a dependency here!
    use 0x1::Signer;
    use 0x1::Vector;

    struct Item has store, drop {}
    struct Collection has key, store {
        items: vector<Item>
    }

    // ... skipped ...

    /// get collection size
    /// mind keyword acquires!
    public fun size(account: &signer): u64 acquires Collection {
        let owner = Signer::address_of(account);
        let collection = borrow_global<Collection>(owner);

        Vector::length(&collection.items)
    }
}
```

많은 일들이 일어난 것 같습니다. 먼저 메소드 시그니처부터 다룰텐데요, 전역 함수 `borrow_global<T>` 는 리소스 T에 대해 불변 참조를 갖습니다. 그 시그니처는 다음과 같습니다.

```Move

native fun borrow_global<T: key>(addr: address): &T;

```

해당 함수를 사용하면 특정 주소에 저장된 리소스에 대해 *읽기 권한*을 얻습니다. 이는 해당 모듈은 그 어떠한 주소에 있는 리소스도 읽을 수 있다는 점을 의미합니다. (해당 기능을 적용할 경우)

추가 결론: 대여 검사로 인해 리소스나 그 내용으로 참조를 되돌릴 수 없습니다. (원본 리소스 참조는 스코프 범위에서 막합니다.)

> 리소스는 복사불가 유형이기에 역참조 연산자 `'*'` 를 사용하는 것은 불가능합니다.

### 키워드 확보

설명이 필요한 세부내용 하나가 더 있는데요, 바로 함수 반환값 이후에 넣는 키워드 `acquires` 입니다. 해당 키워드는 함수에서 *확보*한 모든 리소스를 명시적으로 정의합니다. 실제로는 중첩함수가 리소스를 확보하더라도 각 확보한 리소스를 구체화해야 합니다. 즉, 부모 스코프는 확보 목록에 리소스를 특정해야 합니다.

`acquires` 를 포함하는 함수에 대한 문법은 다음과 같습니다.

```Move

fun <name>(<args...>): <ret_type> acquires T, T1 ... {

```

## `borrow_global_mut`를 사용하는 변형 대여

리소스에 변형 참조를 하려면 `borrow_global` 에 add `_mut` 를 추가하면 된다. 컬렉션에 새로운 아이템 (현재는 비어 있는)을 추가하는 함수를 작성해봅시다.

```Move
module Collection {

    // ... skipped ...

    public fun add_item(account: &signer) acquires T {
        let collection = borrow_global_mut<T>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }
}
```

리소스에 대한 변형 참조는 그 내용에 변형 참조를 생성 가능하게 합니다. 따라서 예시 에서처럼 내부 벡터 `item`을 수정할 수 있습니다.

`borrow_global_mut` 의 시그니처는 다음과 같습니다:

```Move

native fun borrow_global_mut<T: key>(addr: address): &mut T;

```
