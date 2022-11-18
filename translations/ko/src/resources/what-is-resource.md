# 리소스란 무엇인가

리소스는 Move 백서에서 설명하는 개념입니다. 본래는 독자적인 유형으로 적용되었으나 이후 기능이 추가되면서 2개의 기능으로 대체되었습니다: `Key` 및 `Store`. 리소스는 디지털 자산을 저장하는데 있어 완벽한 유형을 목표로 하며, 복사불가하고 드롭이 불가능해야 합니다. 하지만 이와 동시에 저장 가능하고 계좌간 전송이 가능해야 합니다.

### 정의

리소스는 오직 `key` 및 `store` 기능만 갖는 구조체(struct)입니다.

```Move
module M {
    struct T has key, store {
        field: u8
    }
}
```

### 키 및 스토어 기능

Key ability allows struct to be used as a storage identifier. In other words, `key` is an ability to be stored as at top-level and be a storage; while `store` is the ability to be stored *under* key. You will see how it works in the next chapter. For now keep in mind that even primitive types have store ability - they can be stored, but yet they don't have `key` and cannot be used as a top-level containers.

Store ability allows value to be stored. That simple.

키 기능은 구조체를 스토어 식별자로 사용할 수 있게 합니다. 다시 말하면, `key` 는 톱-레벨로 저장하며 저장소로 작동하는 기능이고; `store`는 키 *아래*에 저장될 수 있는 기능입니다. 다음 장에서 해당 구조가 어떻게 작동하는지 알 수 있습니다. 현재로서는 기본 유형도 스토어 기능을 갖고 있다는 점을 기억해야 합니다. – 저장은 가능하지만 `key` 가 없으며 톱-레벨 컨테이너(container)로 사용할 수는 없습니다.

스토어 기능은 값을 저장할 수 있게 하여 그 정도로 간단합니다. 

### 리소스 개념

본래 리소스는 Move에서 자체적인 유형이 있었으나, 기능이 추가되면서 *키* 및/또는 *스토어* 기능으로 적용하는 보다 추상적인 개념이 되었습니다. 리소스에 대한 설명은 다음과 같습니다:

1. 리소스는 계좌(account)에 저장된다 – 따라서 계좌에 배정되었을 시에만 존재하며, 해당 계좌를 통해서만 접근할 수 있습니다;
2. 계좌는 *하나의 유형*을 갖는 *하나*의 리소스만 담을 수 있으며, 그 리소스는 key  기능을 가져야 합니다;
3.  리소스는 복사하거나 드롭 할 수 없지만 저장할 수는 있습니다.
4.  리소스 값은 *반드시 사용되어야* 합니다. 리소스를 생성하거나 계좌에서 가져왔을 경우 드롭할 수 없으며 저장하거나 분해해야 합니다.

이론은 이쯤으로 하고 실전으로 가보겠습니다!