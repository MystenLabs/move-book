# 벡터로 집합 관리하기

본인만의 유형을 생성하고 복잡한 데이터를 저장하도록 하는 `struct` 유형은 이미 익숙하실 것입니다. 하지만 가끔은 좀 더 동적이고, 확장성과 관리성이 좋은 유형이 필요할 때가 있습니다. Move에서는 벡터가 그러한 기능을 담당합니다.

Vector is a built-in type for storing *collections* of data. It is a generic solution for collection of any type (but only one). As its functionality is given to you by the VM; the only way to work with it is by using the [Move standard library](https://github.com/diem/move/tree/main/language/move-stdlib/sources) and `native` functions.

벡터는 데이터 *집합*을 저장하는 역할을 맡는 내장된 유형입니다. 벡터는 모든 종류의 단일 유형에 대응하는 제네릭 솔루션입니다. 이 기능은 실제 Move 언어가 아니라 VM에서 제공하는 것이므로, [Move standard library](https://github.com/diem/move/tree/main/language/move-stdlib/sources)와 `native` 함수를 사용해야만 작업할 수 있습니다.

```Move
script {
    use 0x1::Vector;

    fun main() {
        // use generics to create an emtpy vector
        let a = Vector::empty<&u8>();
        let i = 0;

        // let's fill it with data
        while (i < 10) {
            Vector::push_back(&mut a, i);
            i = i + 1;
        }

        // now print vector length
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);

        // then remove 2 elements from it
        Vector::pop_back(&mut a);
        Vector::pop_back(&mut a);

        // and print length again
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);
    }
}
```

벡터는 단일 비참조 유형에 해당하는 값을 최대 `u64` 크기까지 저장할 수 있습니다. 대형 저장소를 관리함에 있어 벡터가 어떤 도움이 되는지를 살펴보기 위해 모듈을 작성해 보겠습니다.

```Move
module Shelf {

    use 0x1::Vector;

    struct Box<T> {
        value: T
    }

    struct Shelf<T> {
        boxes: vector<Box<T>>
    }

    public fun create_box<T>(value: T): Box<T> {
        Box { value }
    }

    // this method will be inaccessible for non-copyable contents
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }

    public fun create<T>(): Shelf<T> {
        Shelf {
            boxes: Vector::empty<Box<T>>()
        }
    }

    // box value is moved to the vector
    public fun put<T>(shelf: &mut Shelf<T>, box: Box<T>) {
        Vector::push_back<Box<T>>(&mut shelf.boxes, box);
    }

    public fun remove<T>(shelf: &mut Shelf<T>): Box<T> {
        Vector::pop_back<Box<T>>(&mut shelf.boxes)
    }

    public fun size<T>(shelf: &Shelf<T>): u64 {
        Vector::length<Box<T>>(&shelf.boxes)
    }
}
```

우선 shelf와 이에 대응하는 box 몇 개를 생성하고 모듈에 벡터를 반영하여 작업을 진행해 보겠습니다.

```Move
script {
    use {{sender}}::Shelf;

    fun main() {

        // create shelf and 2 boxes of type u64
        let shelf = Shelf::create<u64>();
        let box_1 = Shelf::create_box<u64>(99);
        let box_2 = Shelf::create_box<u64>(999);

        // put both boxes to shelf
        Shelf::put(&mut shelf, box_1);
        Shelf::put(&mut shelf, box_2);

        // prints size - 2
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));

        // then take one from shelf (last one pushed)
        let take_back = Shelf::remove(&mut shelf);
        let value     = Shelf::value<u64>(&take_back);

        // verify that the box we took back is one with 999
        assert(value == 999, 1);

        // and print size again - 1
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));
    }
}
```

Vectors are very powerful. They allow you to store huge amounts of data (max length is *18446744073709551615*) and to work with it inside indexed storage.

벡터는 아주 강력합니다. 최대 길이 *18446744073709551615* 에 해당하는 대규모의 데이터를 저장할 수 있도록 하며, 색인 처리된 저장소 내부에서 작업을 진행할 수 있습니다.

### 인라인 벡터 정의에 대응하는 Hex 및 Bytestring 리터럴

벡터는 또한 스트링을 대표하는 역할을 맡습니다. VM은 스크립트 상 `main` 함수에 `vector<u8>`을 인수로 전달하는 방법을 지원합니다.

그러나16진법 리터럴을 사용하여 스크립트나 모듈에서 `vector<u8>`을 정의할 수도 있습니다.

```Move
script {

    use 0x1::Vector;

    // this is the way to accept arguments in main
    fun main(name: vector<u8>) {
        let _ = name;

        // and this is how you use literals
        // this is a "hello world" string!
        let str = x"68656c6c6f20776f726c64";

        // hex literal gives you vector<u8> as well
        Vector::length<u8>(&str);
    }
}
```

Bytestring 리터럴을 사용하면 좀 더 단순하게 접근할 수 있습니다.

```Move
script {

    fun main() {
        let _ = b"hello world";
    }
}
```

ASCII 스트링으로 취급되며 마찬가지로 `vector<u8>`로 해석됩니다.

### 벡터 공략집

표준 라이브러리에서 제공하는 벡터 메서드 관련 공략집입니다.

- `<E>` 형 Empty 벡터 생성
```Move
Vector::empty<E>(): vector<E>;
```
- 벡터 길이 확인 
```Move
Vector::length<E>(v: &vector<E>): u64;
```
- 벡터 끝으로 element 밀기:
```Move
Vector::push_back<E>(v: &mut vector<E>, e: E);
```
- 벡터의 element에 대한 가변성 확보. 불변성 확인 필요 시 `Vector::borrow()` 사용
```
Vector::borrow_mut<E>(v: &mut vector<E>, i: u64): &E;
```
- 벡터 끝에서 element pop하기:
```
Vector::pop_back<E>(v: &mut vector<E>): E;
```

Move 라이브러리 내 벡터 모듈 관련 사항: [link](https://github.com/diem/move/blob/main/language/move-stdlib/sources/Vector.move)
