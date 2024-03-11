# 기본형

Move에는 숫자, 주소 및 불리언(Boolean) 값을 나타낼 수 있도록 정수(u8, u64, u128), `boolean` 및 `address` 에 대응하는 기본형이 몇 가지 미리 탑재되어 있습니다.
Move에 스트링 또는 부동소수점 숫자는 없습니다.


## 정수형

정수는 `u8`, `u64` 및 `u128` 로 나타나며, 몇 가지 정수 표기법이 아래와 같이 기재되어 있습니다.

```Move
script {
    fun main() {
        // define empty variable, set value later
        let a: u8;
        a = 10;

        // define variable, set type
        let a: u64 = 10;

        // finally simple assignment
        let a = 10;

        // simple assignment with defined value type
        let a = 10u128;

        // in function calls or expressions you can use ints as constant values
        if (a < 10) {};

        // or like this, with type
        if (a < 10u8) {}; // usually you don't need to specify type
    }
}
```

### `as` 연산자

값을 비교하거나 함수 인수에서 다양한 크기의 정수를 필요로 한다면 `as` 연산자를 사용해서정수 변수를 다른 크기로 캐스팅할 수 있습니다. 

```Move
script {
    fun main() {
        let a: u8 = 10;
        let b: u64 = 100;

        // we can only compare same size integers
        if (a == (b as u8)) abort 11;
        if ((a as u64) == b) abort 11;
    }
}
```

## 불리언

모두에게 친숙한 불리언 유형은 `거짓`과 `참`에 해당하는 두 가지 상수가 존재하며 이 둘은 각각 논리형에 해당하는 한 가지 값만 의미할 수 있습니다.

```Move
script {
    fun main() {
        // these are all the ways to do it
        let b : bool; b = true;
        let b : bool = true;
        let b = true
        let b = false; // here's an example with false
    }
}
```

## 주소

주소는 블록체인에서 발신자 (또는 지갑)의 식별자에 해당합니다. 주소 유형을 필요로 하는 기초적인 작동으로는 코인 전송과 모듈 불러오기가 있습니다.

```Move
script {
    fun main() {
        let addr: address; // type identifier

        // in this book I'll use {{sender}} notation;
        // always replace `{{sender}}` in examples with VM specific address!!!
        addr = {{sender}};

        // in Diem's Move VM and Starcoin - 16-byte address in HEX
        addr = 0x...;

        // in dfinance's DVM - bech32 encoded address with `wallet1` prefix
        addr = wallet1....;
    }
}
```
