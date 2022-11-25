# 제어 흐름

Move는 명령성을 지니는 언어이며, 그러한 언어 특성상 *제어 흐름*이라는 요소를 구비함으로써 코드 블록을 구동할지 또는 이를 건너뛰거나 다른 블록을 대신 실행할지를 선택할 수 있습니다.

<!-- In Move you have two statme to control flow: by using loops (`while` and `loop`) or `if` expressions. -->

Move에서는 루프 (`while` 및 `loop`)와 `if`표현식을 사용할 수 있습니다.

## `if` 표현식

`if`표현식을 사용하면 일부 조건이 참인 경우 특정 코드 블록을 실행하고, 조건이 거짓인 경우 다른 블록을 실행할 수 있습니다.

```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        if (a) {
            Debug::print<u8>(&0);
        } else {
            Debug::print<u8>(&99);
        };
    }
}
```

이 예시에서는 `if` + `block` 을 사용하여 `a == true` 인 경우 `0`을 출력하고 `a`가 `false` 인 경우 `99` 를 출력하도록 했습니다.

```
if (<bool_expression>) <expression> else <expression>;
```

`if` 구문은 이처럼 간단하며, 표현식임과 동시에 세미콜론으로 끝나야 합니다. 이는 또한 `let` 명령문과 함께 사용해야 하는 이유이기도 합니다!

```Move
script {
    use 0x1::Debug;

    fun main() {

        // try switching to false
        let a = true;
        let b = if (a) { // 1st branch
            10
        } else { // 2nd branch
            20
        };

        Debug::print<u8>(&b);
    }
}
```

이제 변수 `b`는 표현식에 따라 다른 값을 할당 받게 됩니다. 그러나 `if`의 두 분기점은 모두 동일한 유형을 반환해야 합니다! 그렇지 않은 경우 변수 `b`는 다른 유형(또는 미정의)이 될 가능성이 있으며 이는 통계적으로 입력된 언어에서는 불가능합니다. 컴파일러 용어로는 *분기 호환성* 이라고 하며, 양 분기가 모두 호환 가능한(동일한) 유형을 반환해야 함을 뜻합니다.

`if`는 `else` 없이 단독으로 사용될 수도 있습니다.

```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        // only one optional branch
        // if a = false, debug won't be called
        if (a) {
            Debug::print<u8>(&10);
        };
    }
}
```

그러나 `else` 분기가 없는 `if` 표현식은 조건이 충족되지 않은 경우 할당에 사용될 수 없으며 변수가 정의되지 않을 가능성이 존재하게 되는데, 다시 말하지만 이는 불가능합니다.

## 루프를 사용한 반복

Move에서는 루프를 정의하는 방식이 두 가지 있습니다.

1.  `while` 을 사용한 조건부 루프
2.  무한 `loop`

### `while`을 사용한 조건부 루프

`while`은 루프를 정의할 수 있는 방법으로, 루프는 일부 조건이 참일 때 실행되는 표현식입니다. 즉 조건이 `참` 일 때 코드가 계속해서 반복된다는 것입니다. 어느 조건을 구현하려는 경우 주로 외부 변수(또는 집계기)를 사용합니다.

```Move
script {
    fun main() {

        let i = 0; // define counter

        // iterate while i < 5
        // on every iteration increase i
        // when i is 5, condition fails and loop exits
        while (i < 5) {
            i = i + 1;
        };
    }
}
```

또한 알아 두면 좋은 점으로, `while`은 `if`와 마찬가지로 표현식이므로 끝에 세미콜론이 들어와야 합니다. While 루프의 일반 구문은 다음과 같습니다.

```Move
while (<bool_expression>) <expression>;
```

`if`와는 달리 `while`은 값을 반환할 수 없으므로 (`if` 표현식에서 진행했던) 변수 할당은 실시할 수 없습니다.

### 접근 불가능한 코드

Move의 신뢰도는 보안성 확보와 직결되어 있습니다. 그렇기 때문에 모든 변수를 사용하는 것이 의무화되어 있으며 동일한 이유에서 접근 불가능한 코드를 사용하는 것을 금지합니다. 디지털 자산들은 프로그래밍이 가능하므로 코드 형태로 사용될 수 있고(이후 [자원 장](/chapters/resource.md) 에서 배울 예정입니다), 접근 불가능한 영역에 이들을 두는 경우 불편과 궁극적으로는 이들의 손실까지도 이어질 수 있습니다.

바로 그러한 이유에서 접근 불가능한 코드는 중대한 문제인 것입니다. 이제 이 부분을 분명히 했으니 다음으로 넘어가겠습니다.

### 무한 `loop`

무한 루프를 정의하는 방법이 하나 있습니다. 비조건적이며 실제로 강제로 멈추지 않는 한 무한대로 진행됩니다. 아쉽게도 컴파일러는 대부분의 상황에서 루프의 유/무한 여부를 정의할 수 없으며 코드 발행을 막지 못합니다. 자칫 이를 실행하게 되는 경우 모든 확보 자원(블록체인 용어로는 가스)을 소모하게 되므로, 무한 루프를 사용할 때는 코드를 적절하게 테스트해 볼 필요가 있으며 조건부(`while`) 루프로 바꾸는 편이 훨씬 더 안전합니다.

무한 루프는 `loop` 키워드로 정의됩니다.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;
        };

        // UNREACHABLE CODE
        let _ = i;
    }
}
```

그러나 컴파일러는 허용하더라도 이 키워드는 불가능합니다.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            if (i == 1) { // i never changed
                break // this statement breaks loop
            }
        };

        // actually unreachable
        0x1::Debug::print<u8>(&i);
    }
}
```

어느 루프가 실제로 무한인지를 이해하는 것은 컴파일러에게 있어서는 매우 복잡한 작업이기 때문에, 루프 오류를 피하는 것은 전적으로 코드 작성자인 여러분 본인에게 달려 있습니다. 앞서 말씀드렸듯이, 자산 손실로 이어질 수 있는 부분입니다.

### `continue` 와 `break` 로 루프 제어하기

`continue` 및 `break` 키워드를 사용하면 각각 반복을 한 라운드 건너뛰거나 정지할 수 있습니다. 두 키워드 모두 각 유형의 루프에서 자유롭게 사용할 수 있습니다. 

예를 들어 `loop`에 두 가지 조건을 추가해 보겠습니다. 만약 `i`가 짝수라면 `continue`를 사용함으로써 해당 키워드를 호출한 뒤 코드를 진행하는 일 없이 다음 번 반복으로 넘어 가겠습니다.

`break` 키워드를 사용하면 반복을 멈추고 루프를 끝내게 됩니다.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i / 2 == 0) continue;
            if (i == 5) break;

            // assume we do something here
         };

        0x1::Debug::print<u8>(&i);
    }
}
```

세미콜론 이야기를 하자면 `break`와 `continue`가 블록 내부의 마지막 키워드라면, 이 뒤에 오는 다른 코드가 실행될 일이 없으므로 세미콜론을 붙일 수 없습니다. Semi 조차도 사용할 수 없는데, 아래 내용을 참조해 주십시오.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i == 5) {
                break; // will result in compiler error. correct is `break` without semi
                       // Error: Unreachable code
            };

            // same with continue here: no semi, never;
            if (true) {
                continue
            };

            // however you can put semi like this, because continue and break here
            // are single expressions, hence they "end their own scope"
            if (true) continue;
            if (i == 5) break;
        }
    }
}
```

### 조건부 중단(`abort`)

어떤 조건이 실패한 경우 트랜잭션의 실행을 중단해야 할 필요가 간혹 발생합니다. 그러한 경우 `abort` 키워드를 사용할 수 있습니다.

```Move
script {
    fun main(a: u8) {

        if (a != 10) {
            abort 0;
        }

        // code here won't be executed if a != 10
        // transaction aborted
    }
}
```

`abort` 키워드를 사용하면 바로 뒤에 오는 에러 코드를 출력하며 작업을 중단시키게 됩니다.

### 내장된 `assert` 사용하기

내장되어 있는 `assert(<condition>, <code>)` 메서드는 `abort` + 조건을 포괄하며 코드 상에서 위치를 불문하고 접근할 수 있습니다.

```Move
script {

    fun main(a: u8) {
        assert(a == 10, 0);

        // code here will be executed if (a == 10)
    }
}
```

`assert()`는 조건이 충족되지 않은 경우 실행을 중단하게 되며, 반대의 경우에는 아무 기능도 발휘하지 않습니다.
