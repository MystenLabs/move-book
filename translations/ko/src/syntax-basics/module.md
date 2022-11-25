# 모듈과 불러오기

모듈은 개발자가 자신의 주소로 발행하게 되는 함수와 유형을 하나로 묶어 놓은 집합입니다. 앞서 우리는 스크립트만을 사용해 왔는데, 스크립트는 발행된 모듈이나 `0x1` 주소로 발행된 모듈의 집합인 표준 라이브러리만을 사용하여 작동할 수 있습니다.

> 모듈은 발신자의 주소로 발행됩니다. 표준 라이브러리는 `0x1` 주소로 발행됩니다.

> 모듈을 발행하는 경우 어떠한 함수도 실행되지 않습니다. 모듈을 사용하려면 스크립트를 사용하십시오.

모듈은 `module` 키워드로 시작해서, 모듈의 이름과 중괄호가 뒤를 잇는 형태로 구성되어 있습니다. 이 중괄호 안에는 모듈의 내용이 위치하게 됩니다.

```Move
module Math {

    // module contents

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
```

> 모듈은 다른 사람들이 접근할 수 있는 코드를 발행할 수 있는 유일한 방법입니다. 새로운 유형과 자원 또한 모듈 환경에서만 정의될 수 있습니다.

초기값을 기준으로 했을 때 여러분의 모듈은 여러분의 주소를 사용하여 컴파일 및 발행됩니다. 그러나 어떤 모듈을 테스트 내지는 개발 용도 등을 목적으로 로컬 상에서 사용할 필요가 있거나 모듈 파일 내부에 주소를 명시하고 싶다면 `address <ADDR> {}` 구문을 사용하십시오.

```Move
address 0x1 {
module Math {
    // module contents

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
}
```
*이 예시에서 보신 바와 같이, 모듈 라인에는 들여쓰기를 사용하지 않는 것이 가장 좋습니다.*

## 불러오기

Move의 초기값 환경은 비어 있습니다. 사용할 수 있는 유형은 기본형(정수형, 논리형 및 주소)이 유일하며, 공백 환경에서 진행할 수 있는 유일한 작업은 이러한 유형들과 변수를 작동시키는 것이지만 이것만으로는 의미있거나 유용한 작업을 진행할 수는 없습니다.

이러한 상황을 변경하려면 발행된 모듈(또는 표준 라이브러리)을 불러와야 합니다.

### 직접 불러오기

모듈에 해당하는 주소를 코드로 직접 불러오는 형식으로 사용할 수 있습니다.

```Move
script {
    fun main(a: u8) {
        0x1::Offer::create(a == 10, 1);
    }
}
```

이 예시에서는 표준 라이브러리인 `Offer` 모듈을 `0x1` 주소에서 불러온 뒤 메서드 `assert(expr: bool, code: u8)`를 사용했습니다. 

### Use 키워드

코드를 더욱 짧게 하고 (0x1 주소는 짧지만 다른 주소들은 꽤 길다는 점을 기억해 주세요!) 불러오기 내용을 정리하려면 `use` 키워드를 사용하십시오.

```Move
use <Address>::<ModuleName>;
```

여기에서 `<Address>`항목은 발행자의 주소이며 `<ModuleName>`은 모듈의 이름입니다. 단순한 내용인데, 여기에서도 `Vector` 모듈을 `0x1`에서 불러올 것입니다.

```Move
use 0x1::Vector;
```

### 모듈 내용에 접근하기

불러온 모듈의 메서드(또는 유형)에 접근하려면 `::` 기호를 사용하십시오. 모듈은 한 가지 수준의 정의만을 가질 수 있기 때문에 모듈에서 공개적으로 정의하는 모든 내용은 더블 콜론을 사용하여 접근할 수 있습니다.

```Move
script {
    use 0x1::Vector;

    fun main() {
        // here we use method empty() of module Vector
        // the same way we'd access any other method of any other module
        let _ = Vector::empty<u64>();
    }
}
```

### 스크립트로 불러오기

스크립트에서 불러온 내용은 반드시 `script {}` 블록 내부에 위치해야 합니다.

```Move
script {
    use 0x1::Vector;

    // in just the same way you can import any
    // other module(s). as many as you want!

    fun main() {
        let _ = Vector::empty<u64>();
    }
}
```

### 모듈로 불러오기

모듈로 불러온 내용은 반드시 `module {}` 블록 내부에 명시되어야 합니다.

```Move
module Math {
    use 0x1::Vector;

    // the same way as in scripts
    // you are free to import any number of modules

    public fun empty_vec(): vector<u64> {
        Vector::empty<u64>();
    }
}
```

### 멤버 불러오기

불러오기 명령문은 확장할 수 있습니다. 불러오고자 하는 모듈의 멤버를 명시하는 것도 가능합니다.

```Move
script {
    // single member import
    use 0x1::Signer::address_of;

    // multi member import (mind braces)
    use 0x1::Vector::{
        empty,
        push_back
    };

    fun main(acc: &signer) {
        // use functions without module access
        let vec = empty<u8>();
        push_back(&mut vec, 10);

        // same here
        let _ = address_of(acc);
    }
}
```

### `Self`를 사용하여 모듈과 멤버를 함께 불러오기

멤버 불러오기 구문에 작은 익스텐션을 적용해 주면 전체 모듈과 멤버를 불러올 수 있습니다. 모듈의 경우 `Self`를 사용하십시오.

```Move
script {
    use 0x1::Vector::{
        Self, // Self == Imported module
        empty
    };

    fun main() {
        // `empty` imported as `empty`
        let vec = empty<u8>();

        // Self means Vector
        Vector::push_back(&mut vec, 10);
    }
}
```

### `Use` 와 `as` 의 만남

(2개 이상의 모듈이 동일한 이름을 가졌을 때 발생할 수 있는) 이름 지정 관련 충돌을 해결하고 코드의 길이를 축약하려는 경우 `as`키워드를 사용하여 불러온 모듈의 이름을 변경하는 것도 좋습니다.

구문:

```Move
use <Address>::<ModuleName> as <Alias>;
```

스크립트 내:

```Move
script {
    use 0x1::Vector as V; // V now means Vector

    fun main() {
        V::empty<u64>();
    }
}
```

동일 모듈 내:

```Move
module Math {
    use 0x1::Vector as Vec;

    fun length(&v: vector<u8>): u64 {
        Vec::length(&v)
    }
}
```

자기 자신과 *멤버 불러오기*의 경우(모듈 및 스크립트에 적용 가능):

```Move
script {
    use 0x1::Vector::{
        Self as V,
        empty as empty_vec
    };

    fun main() {
        // `empty` imported as `empty_vec`
        let vec = empty_vec<u8>();

        // Self as V = Vector
        V::push_back(&mut vec, 10);
    }
}
```
