# 서명자로서의 전송자

리소스 사용에 대해 설명하기에 앞서 `서명자(signer)` 유형에 및 그 존재 이유에 대해서 이해가 선행되어야 합니다.

> signer는 네이티브 복사불가능한 (유사 리소스) 유형으로, 거래에서 전송자의 주소를 담고 있습니다.

signer 유형은 전송 권한을 의미합니다. 다시 말하면, signer를 사용한다는 것은 전송자의 주소 및 리소스에 접근한다는 것을 의미합니다. 실제로 *서명*이나 *서명하는 행위*와는 관계가 없으며, Move VM에서는 단순히 전송자를 의미합니다. 

> signer 유형은 오직 하나의 기능을 갖습니다 – 드롭(Drop)

<!-- Important! `0x1::Transaction::sender()` may soon be deprecated [as mentioned here](https://community.libra.org/t/signer-type-and-move-to/2894). So in the future using `signer` will be the only way to get sender's address. -->

### 스크립트에서의 signer 

Signer는 네이티브 유형이기에 생성이 필요하다. 하지만 `vector` 와는 다르게 코드로 직접 생성할 수는 없으며, 스크립트 인자(script argument)로 받아야 합니다:

```Move
script {
    // signer is an owned value
    fun main(account: signer) {
        let _ = account;
    }
}
```

signer 인자는 VM이 자동적으로 스크립트에 추가되기에, 사용자가 직접 전송하거나 스크립트에 추가할 필요가 없으며 직접 추가할 방법도 없습니다. 나아가, signer 인자는 항상 *참조(reference)*입니다. 표준 라이브러리 (Diem의 경우 – [DiemAccount](https://github.com/diem/diem/blob/master/language/stdlib/modules/DiemAccount.move))는 실제 signer 값에 접근할 수 있지만, 해당 값을 사용하는 함수는 접근제한(private)이며, signer 값을 사용하거나 전송할 수 없습니다.

> 현재로써 signer 유형을 담고 있는 변수의 정규 명칭(canonical name)은 *어카운트(account)*입니다.

### 표준 라이브러리에서의 signer 모듈

네이티브 유형은 네이티브 함수를 필요로 하고, signer 유형의 경우에는 `0x1::Signer` 입니다. 해당 모듈은 비교적 단순합니다. ([Diem에서 원본 모듈에 대한 링크](https://github.com/diem/diem/blob/master/language/diem-framework/modules/Signer.move)):

```Move
module Signer {
    // Borrows the address of the signer
    // Conceptually, you can think of the `signer`
    // as being a resource struct wrapper arround an address
    // ```
    // resource struct Signer { addr: address }
    // ```
    // `borrow_address` borrows this inner field
    native public fun borrow_address(s: &signer): &address;

    // Copies the address of the signer
    public fun address_of(s: &signer): address {
        *borrow_address(s)
    }
}
```

보다시피 2개의 메소드가 있으며 그 중 하나는 네이티브이고, 다른 하나는 역참조 연산자를 사용하여 주소를 복사하기에 보다 간편합니다.

모듈을 사용하는 것 역시 이처럼 단순합니다.

```Move
script {
    fun main(account: signer) {
        let _ : address = 0x1::Signer::address_of(&account);
    }
}
```

### 모듈 내 signer

```Move
module M {
    use 0x1::Signer;

    // let's proxy Signer::address_of
    public fun get_address(account: signer): address {
        Signer::address_of(&account)
    }
}
```

> `&signer` 유형을 인자로 사용하는 메소드는 전송자의 주소를 사용한다는 점을 명시적으로 보여줍니다.

해당 유형을 사용한 이유 중 하나는 전송 권한을 요구하는 메소드와 요구하지 않는 메소드를 구분하기 위함입니다. 따라서 메소드가 사용자를 기망하여 리소스에 대해 권한 없는 접근을 허용하지 않습니다.  

<!--  MAYBE ADD HISTORY OF THIS TYPE? -->

### 추가 자료 및 PR

- [signer에 대한 Diem 커뮤니티 스레드](https://community.diem.com/t/signer-type-and-move-to/2894)
- [Diem 저장소의 논리를 포함한 Issue](https://github.com/diem/diem/issues/3679)
- [Diem 저장소의 PR](https://github.com/diem/diem/pull/3819)
