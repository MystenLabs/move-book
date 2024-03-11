# 상수

*모듈* 또는 *스크립트 수준*의 상수를 정의할 수 있습니다. 일단 정의된 뒤에는 상수를 변경할 수 없으며, 특정 모듈 (예를 들면 역할 식별자 또는 체결 가격) 내지는 스크립트에 대해 *상수* 값을 정의하기 위해 사용합니다. 

상수는 기본형(정수, 논리형 및 주소)이나 `벡터`로 정의될 수 있습니다. 상수는 부여된 이름을 사용하여 접근할 수 있으며 정의된 스크립트/모듈 상 로컬 위치에 존재하게 됩니다.

> 상수가 속한 모듈 외부로부터 상수에 접근하는 것은 불가능합니다.

```Move
script {

    use 0x1::Debug;

    const RECEIVER : address = 0x999;

    fun main(account: &signer) {
        Debug::print<address>(&RECEIVER);

        // they can also be assigned to a variable

        let _ = RECEIVER;

        // but this code leads to compile error
        // RECEIVER = 0x800;
    }
}
```

모듈에서도 동일한 용도입니다.

```Move
module M {

    const MAX : u64 = 100;

    // however you can pass constant outside using a function
    public fun get_max(): u64 {
        MAX
    }

    // or using
    public fun is_max(num: u64): bool {
        num == MAX
    }
}
```

### 요약

상수에 관하여 알아야 할 중요한 내용은 다음과 같습니다.

1.  정의된 뒤에는 변경이 불가능합니다
2.  모듈 또는 스크립트에 로컬적으로 존재하며 외부에서는 사용할 수 없습니다
3.  일반적으로 실용적 목적을 지닌 모듈 수준 상수 값을 정의할 때 사용합니다
4.  또한 중괄호를 사용하여 상수를 표현식으로 정의하는 것도 가능하나 해당 표현식의 구문은 매우 제한적입니다.

### 추가 참고 자료

- [상수 구문을 담은 PR](https://github.com/diem/diem/pull/4653)
