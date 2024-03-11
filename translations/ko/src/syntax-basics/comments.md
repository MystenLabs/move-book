# 주석

코드 중간에 추가 설명이 필요할 것 같다면 *주석*을 사용합니다. 주석 기능은 코드의 일부를 설명하는 것을 목적으로 하며, 해당 텍스트 구간 또는 문장은 실행되지 않습니다.

### 라인 주석

```Move
script {
    fun main() {
        // this is a comment line
    }
}
```

라인 주석을 작성하려면 이중 사선 “*//*”을 사용합니다. 사용법은 매우 간단한데, “*//*” **뒤에 오는 모든 내용**은 해당 라인 끝부분에 추가된 주석으로 간주됩니다. 라인 주석을 사용하면 다른 개발자들에게 짧은 참고사항을 남겨두거나 실행 체인에서 일부 코드를 주석 처리하여 제외시킬 수 있습니다.

```Move
script {
    // let's add a note to everything!
    fun main() {
        let a = 10;
        // let b = 10 this line is commented and won't be executed
        let b = 5; // here comment is placed after code
        a + b // result is 15, not 10!
    }
}
```

### 블록 주석

모든 라인 내용에 주석을 달 의향이 없거나 하나 이상의 라인을 주석 처리하여 제외하려는 경우 블록 주석을 사용합니다.

블록 주석은 사선 별표 */\** 로 시작하며 첫 번째 별표 사선 *\*/* 표시 전까지 들어오는 모든 텍스트를 포함합니다. 블록 주석은 라인 1개에 한정되지 않으며 코드 중 모든 장소에 참고사항을 작성할 수 있는 장점이 있습니다.

```Move
script {
    fun /* you can comment everywhere */ main() {
        /* here
           there
           everywhere */ let a = 10;
        let b = /* even here */ 10; /* and again */
        a + b
    }
    /* you can use it to remove certain expressions or definitions
    fun empty_commented_out() {

    }
    */
}
```

물론 이 예시는 말도 안 되는 내용이지만, 블록 주석의 위력을 잘 보여주고 있습니다. 어느 곳에나 주석 처리를 할 수 있다는 점 명심하세요!

<!-- ### Documentation comments -->
