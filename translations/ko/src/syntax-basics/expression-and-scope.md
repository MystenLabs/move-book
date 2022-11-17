# 표현식과 스코프

프로그래밍 언어에서 표현식은 값을 반환하는 코드 뭉치입니다. 반환 값을 가지는 함수 호출은 표현식입니다. 이 함수가 반환하는 정수(또는 부울값이나 주소) 또한 표현식입니다. 반환 값은 정수 유형의 값을 가집니다.

> 표현식은 세미콜론을 사용하여 반드시 분할해 줘야 합니다*

*\* 세미콜론을 입력하는 경우 ‘내부적으로는‘ `; (empty_expression)`으로 취급됩니다. 세미콜론 이후에 표현식을 배치하는 경우 공백란을 대체할 것입니다.*

### 공백 표현식

이 표현식을 직접 사용할 일은 아마 없을 것이지만 Move에서 공백 표현식은 (Rust와 유사한 방식에 해당하는) 빈 괄호로 표기합니다.

```Move
script {
    fun empty() {
        () // this is an empty expression
    }
}
```

공백 표현식은 VM이 자동으로 입력하므로 제외해도 무방합니다.

### 리터럴 표현식

아래의 코드를 살펴보시면 각 라인에 세미콜론으로 끝나는 표현식이 있는 것을 확인하실 수 있습니다. 마지막 라인에는 세미콜론으로 분리된 표현식이 3개 있습니다.


```Move
script {
    fun main() {
        10;
        10 + 5;
        true;
        true != false;
        0x1;
        1; 2; 3
    }
}
```

좋습니다. 이제 가장 단순한 형태의 표현식들을 배워 보셨는데, 이것들이 필요한 이유는 무엇일까요? 그리고 어떻게 사용할 수 있을까요? `let` 키워드에 대해 알아볼 시간입니다.

### 변수와 'let' 키워드 

(다른 곳으로 값을 전달하기 위해) 변수에 표현식의 값을 저장하려면 `let`이라는 키워드가 필요합니다(이미 [기본형을 설명하는 장](/syntax-basics/primitives.md)에서 보셨을 것입니다). 이 키워드는 공백(undefined)이거나 표현식의 값이 반영된 새로운 변수를 생성합니다.

```Move
script {
    fun main() {
        let a;
        let b = true;
        let c = 10;
        let d = 0x1;
        a = c;
    }
}
```

> `let` 키워드는 *현재 스코프* 내부에 새로운 변수를 생성하며 부가적으로 값을 반영하여 해당 변수를 *초기 설정*합니다. 이 표현식에 대응하는 구문은 `let <VARIABLE> : <TYPE>;` 또는 `let <VARIABLE> = <EXPRESSION>` 입니다.

변수를 생성하여 초기 설정을 완료한 뒤에는 변수 이름을 사용하여 값을 *변경*하거나 *접근*할 수 있습니다. 상기 예시에서 변수 `a`는 함수 끝부분에서 초기 설정이 이루어졌으며 변수 `c`의 값을 *할당* 받았습니다.

After you've created and initialized variable you're able to *modify* or *access* its value by using a variable name. In example above variable `a` was initialized in the end of function and was *assigned* a value of variable `c`.

> 등호 `=`는 할당 연산자입니다. 우측 표현식을 좌측 변수에 할당하게 됩니다. 예를 들면 `a = 10` 이라는 식에서 변수 `a`는 `10`이라는 정수가 할당되었습니다

### 정수형 대응 연산자

Move에는 정수 값을 변형할 수 있는 다양한 종류의 연산자가 아래와 같이 있습니다.
| Operator | Op     | Types |                                 |
|----------|--------|-------|---------------------------------|
| +        | sum    | uint  | Sum LHS and RHS                 |
| -        | sub    | uint  | Subtract RHS from LHS           |
| /        | div    | uint  | Divide LHS by RHS               |
| *        | mul    | uint  | Multiply LHS times RHS          |
| %        | mod    | uint  | Division remainder (LHS by RHS) |
| <<       | lshift | uint  | Left bit shift LHS by RHS       |
| >>       | rshift | uint  | Right bit shift LHS by RHS      |
| &        | and    | uint  | Bitwise AND                     |
| ^        | xor    | uint  | Bitwise XOR                     |
| \|       | or     | uint  | Bitwise OR                      |

*LHS - 좌측 표현식, RHS - 우측표현식; uint: u8, u64, u128.*

<!--

### Comparison and boolean operators

To build a bool condition by comparing values you have these operators. All of them return `bool` value and require LHS and RHS types match.

| Operator | Op     | Types |                                |
|----------|--------|-------|--------------------------------|
| ==       | equal  | any   | Check if LHS equals RHS        |
|----------|--------|-------|--------------------------------|
| =<       | equal  | any   | Check if LHS equals RHS        |
|----------|--------|-------|--------------------------------|

-->

### 밑줄 "`_`" 로 사용되지 않음을 표기

Move에서는 입력된 모든 변수가 사용되어야 합니다(그렇지 않으면 코드가 컴파일되지 않습니다). 따라서 초기 설정(initialize)을 한 변수를 방치해서는 안 되는데, 밑줄 `_`을 사용하면 의도적으로 *사용되지 않은 상태*로 표시할 수 있습니다.

이 스크립트를 컴파일하려고 시도하는 경우 오류가 발생할 것입니다.

```Move
script {
    fun main() {
        let a = 1;
    }
}
```

에러 내용:
```

    ┌── /scripts/script.move:3:13 ───
    │
 33 │         let a = 1;
    │             ^ Unused assignment or binding for local 'a'. Consider removing or replacing it with '_'
    │
```

컴파일러 메시지가 명확함으로 이런 경우에는 대신 밑줄만 추가하면 되겠습니다.

```Move
script {
    fun main() {
        let _ = 1;
    }
}
```

### 섀도잉

Move에서는 동일한 변수를 두 번 정의하는 것이 가능한데, 한 가지 제한사항이 있습니다. 바로 계속 사용되어야 하는 상태여야 한다는 것입니다. 상기 예시에서는 두 번째 `a`변수만 사용되고 있으며, 첫 번째 변수 `let a = 1`은 사용되지 않은 상태입니다. 바로 다음 라인에서는 첫 번째 변수가 사용되지 않은 그 상태에서 `a`를 *재정의*하고 있습니다.

```Move
script {
    fun main() {
        let a = 1;
        let a = 2;
        let _ = a;
    }
}
```

그러나 첫 번째 변수를 사용해 줌으로써 정상적으로 진행되도록 할 수 있습니다.

```Move
script {
    fun main() {
        let a = 1;
        let a = a + 2; // though let here is unnecessary
        let _ = a;
    }
}
```

## 블록 표현식

블록은 표현식이며, *중괄호* `{}`로 표시되어 있습니다. 블록에는 다른 표현식(및 다른 블록) 이 들어올 수도 있습니다. 약간의 제한은 있으나, 친숙한 중괄호가 등장하는 것에서 짐작할 수 있듯 함수 바디 또한 블록으로 분류할 수 있습니다.

```Move
script {
    fun block() {
        { };
        { { }; };
        true;
        {
            true;

            { 10; };
        };
        { { { 10; }; }; };
    }
}
```

### 스코프 이해하기

Scope (as it's said in [Wikipedia](https://en.wikipedia.org/wiki/Scope_(computer_science))) is a region of code where binding is valid. In other words - it's a part of code in which variable exists. In Move scope is a block of code surrounded by curly braces - basically a block.

> 블록의 정의는 실제로 스코프를 정의하는 것입니다.

```Move
script {
    fun scope_sample() {
        // this is a function scope
        {
            // this is a block scope inside function scope
            {
                // and this is a scope inside scope
                // inside functions scope... etc
            };
        };

        {
            // this is another block inside function scope
        };
    }
}
```

이 샘플에 등장하는 주석에서 볼 수 있듯이 스코프는 블록(또는 함수)을 통해 정의되며, 중첩시키는 것도 가능하며 정의할 수 있는 스코프의 개수에는 제한이 없습니다. 

### 변수의 지속시간과 가시성

Let 키워드는 변수를 생성한다는 점은 이미 알고 있지만, 정의된 변수는 해당 정의가 이루어진스코프 내부(즉 중첩된 스코프 내부)에서만 존속한다는 사실은 모르고 계셨을 것입니다. 요약하자면 소속된 스코프 외부에서는 접근할 수 없으며, 해당 스코프가 끝나는 지점에서 곧바로 변수도 수명을 다 합니다.

```Move
script {
    fun let_scope_sample() {
        let a = 1; // we've defined variable A inside function scope

        {
            let b = 2; // variable B is inside block scope

            {
                // variables A and B are accessible inside
                // nested scopes
                let c = a + b;

            }; // in here C dies

            // we can't write this line
            // let d = c + b;
            // as variable C died with its scope

            // but we can define another C
            let c = b - 1;

        }; // variable C dies, so does C

        // this is impossible
        // let d = b + c;

        // we can define any variables we want
        // no name reservation happened
        let b = a + 1;
        let c = b + 1;

    } // function scope ended - a, b and c are dropped and no longer accessible
}
```

> 변수는 정의된 스코프(또는 블록) 내부에만 존재합니다. 소속된 스코프가 끝나는 시점에 변수도 수명이 끝납니다.

### 블록 반환값

앞서 블록은 표현식이라는 점을 배워보았는데, 왜 그런지, 그리고 블록의 반환값은 무엇인지에 대해서는 아직 다루지 않았습니다.

> 블록은 값을 반환할 수 있는데, 이 때 반환되는 값은 세미콜론이 뒤에 붙지 않는다면 해당 블록 내부에 있는 마지막 표현식의 값에 해당합니다.

조금 어려울 수 있으니 예시를 몇 개 들도록 하겠습니다.

```Move
script {
    fun block_ret_sample() {

        // since block is an expression, we can
        // assign it's value to variable with let
        let a = {

            let c = 10;

            c * 1000  // no semicolon!
        }; // scope ended, variable a got value 10000

        let b = {
            a * 1000  // no semi!
        };

        // variable b got value 10000000

        {
            10; // see semi!
        }; // this block does not return a value

        let _ = a + b; // both a and b get their values from blocks
    }
}
```

> (세미콜론 없는) 스코프 내부의 마지막 표현식이 바로 해당 스코프의 반환값입니다.

### 요약

이 장의 핵심을 요약해 보겠습니다.

1. 각 표현식은 블록의 반환값인 경우를 제외하고는 반드시 세미콜론으로 끝나야 합니다;
2. `let` 키워드는 값을 지니는 변수를 새로 생성하거나, 자신이 포함된 스코프와 동일한 지속시간을 지니는 우측 표현식을 생성합니다.
3. 블록은 반환값을 가지거나 가지지 않는 표현식입니다.

다음으로 실행 흐름을 제어하는 방법과 논리 스위치에 블록을 사용하는 방법을 살펴보겠습니다.

### 추가 참고 자료

- [공백 표현식 및 세미콜론을 다룬 Diem 커뮤니티 게시글](https://community.diem.com/t/odd-error-when-semi-is-put-after-break-or-continue/2868)
