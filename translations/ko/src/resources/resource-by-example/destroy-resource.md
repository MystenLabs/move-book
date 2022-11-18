# 리소스 이전 및 파괴

Final function of this section is `move_from` which takes resource from account. We'll implement `destroy` function which will move collection resource *from* account and will destroy its contents.

이 장에서 다룰 마지막 함수는 `move_from` 으로, 계좌에서 리소스를 이전한다. `destroy` 함수는 계좌*에서* 컬렉션 리소스를 옮기고 그 내용을 파괴합니다.

```Move
// modules/Collection.move
module Collection {

    // ... skipped ...

    public fun destroy(account: &signer) acquires Collection {

        // account no longer has resource attached
        let collection = move_from<Collection>(Signer::address_of(account));

        // now we must use resource value - we'll destructure it
        // look carefully - Items must have drop ability
        let Collection { items: _ } = collection;

        // done. resource destroyed
    }
}
```

리소스 값은 사용되어야 합니다. 따라서 계좌로부터 가져온 리소스는 분해하거나 반환값으로 전달해야 합니다. 염두해야 할 점은 값을 외부로 전달하여 스크립트에 포함하더라도 할 수 있는 행동은 제한되는데, 스크립트는 구조체나 리소스를 다른 곳으로 전달하는 것 외에는 다른 작업을 허용하지 않습니다. 이를 염두에 두고 모듈을 적절하게 설계하여 사용자들이 반환된 리소스로 할 수 있는 선택지를 주어야 합니다. 

마지막 시그니처는 다음과 같습니다.

```Move

native fun move_from<T: key>(addr: address): T;

```
