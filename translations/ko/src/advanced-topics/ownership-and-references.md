# 소유권과 참조

Move VM은 Rust와 유사한 소유권 체계를 구현합니다. 이를 가장 잘 설명하고 있는 자료가 바로 [Rust Book](https://doc.rust-lang.org/stable/book/ch04-01-what-is-ownership.html) 입니다.

Rust의 구문은 약간 다른 면도 있고 수록된 예시 중 일부를 이해하는 것도 쉽진 않지만, Rust Book에 수록된 소유권 장은 꼭 읽어 보시는 것을 추천 드립니다. 이 장에서도 핵심을 다룰 예정입니다.

> 각 변수는 하나의 소유자 스코프만을 가집니다. 소유자 스코프가 끝나는 시점에 소유했던 변수들은 제외됩니다.

이러한 행동 양상은 [표현식](/syntax-basics/expression-and-scope.md) 장에서 앞서 살펴본 적이 있습니다. 스코프와 변수의 수명은 동일하다는 점 기억하시나요? 지금이야말로 왜 그런 일이 일어나는가를 파고들어 볼 시간입니다.

소유자는 변수를 *갖고 있는* 스코프입니다. 변수는 해당 스코프 내부에서 정의되거나(예: 스크립트에서 `let`을 사용) 인수로서 스코프에 전달될 수 있습니다. Move에 존재하는 유일한 스코프는 함수이기 때문에, 변수를 스코프에 넣을 다른 방법은 존재하지 않습니다.

각 변수에는 단 하나의 소유자만 존재하며, 즉 어느 변수가 인수 형태로 함수에 전달되었다면 해당 함수가 *새로운 소유자* 가 되어, 변수가 더 이상 첫 번째 함수의 *소유*가 아닌 것입니다. 또는 변수의 *소유권을 해당 함수가 가져왔다*고 말해도 무방할 것입니다.

```Move
script {
    use {{sender}}::M;

    fun main() {
        // Module::T is a struct
        let a : Module::T = Module::create(10);

        // here variable `a` leaves scope of `main` function
        // and is being put into new scope of `M::value` function
        M::value(a);

        // variable a no longer exists in this scope
        // this code won't compile
        M::value(a);
    }
}
```

우리가 값을 내부로 전달했을 때 `value()`안에서 어떤 일이 일어나는지 알아봅시다.

```Move
module M {
    // create_fun skipped
    struct T { value: u8 }

    public fun create(value: u8): T {
        T { value }
    }

    // variable t of type M::T passed
    // `value()` function takes ownership
    public fun value(t: T): u8 {
        // we can use t as variable
        t.value
    }
    // function scope ends, t dropped, only u8 result returned
    // t no longer exists
}
```

물론 임시방편으로 원본 변수와 추가적인 결과를 가지는 튜플을 반환하는 것이겠지만(이 때 반환 값은 `(T, u8)`), Move에는 더 나은 해결책이 있습니다. 

### Move와 Copy

먼저 Move VM의 작동 방식, 그리고 함수에 값을 전달하면 어떤 일이 일어나는가를 이해해 둘 필요가 있습니다. VM에는 *MoveLoc과* *CopyLoc*이라는 바이트코드 지침이 2개 존재하는데, 둘다 각각 `move`와 `copy`키워드를 통해 수동으로 사용할 수 있습니다. 

어느 변수를 다른 함수로 전달하는 경우, 해당 변수는 *이동* 중인 상태이며 *MoveLoc* OpCode가 사용됩니다. `move` 키워드를 사용하면 코드가 어떤 형태가 될 지 살펴봅시다.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        M::value(move a); // variable a is moved

        // local a is dropped
    }
}
```

이 경우는 유효한 Move 코드이지만, 해당 값이 여전히 이동될 것이라는 걸 알고 있는 상태에서 굳이 명시적으로 *이동*시킬 필요는 없습니다. 숙지하셨으면 이제 *Copy*로 넘어가겠습니다.

This is a valid Move code, however, knowing that value will still be moved you don't need to explicitly *move* it. Now when it's clear we can get to *copy*.

### `copy` 키워드

어느 값을 함수에 전달하고 (이동 지점에) 변수의 사본을 저장하려는 경우, `copy` 키워드를 사용하면 됩니다.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        // we use keyword copy to clone structure
        // can be used as `let a_copy = copy a`
        M::value(copy a);
        M::value(a); // won't fail, a is still here
    }
}
```

이 예시에서는 변수(즉 값) `a` 의 *사본*을 메서드 `value`의 첫 번째 호출로 전달하고 `a`를 로컬 스코프에 저장하여 두 번째로 호출이 진행될 경우 다시 사용할 수 있도록 처리했습니다.

값을 복사함으로써 우리는 이를 복제하게 되었고 프로그램의 메모리 크기를 증가시켰는데, 이를 감안하면 해당 키워드는 사용할 수는 있겠으나 크기가 큰 데이터를 복사하게 되는 경우 메모리 측면에서 비싼 대가를 치를 수 있습니다. 블록체인에서는 낭비할 바이트라고는 하나도 없으며 실행 가격에 영향을 끼치기 때문에, `copy` 키워드를 매번 사용하게 되면 비용이 크게 올라갈 수 있습니다.

이제 불필요한 복사를 피하고 실제로 돈을 절약할 수 있도록 돕는 기능인 참조에 대해 배워볼 준비가 되었습니다.

## 참조

여러 프로그래밍 언어에서는 참조 기능을 구현해 놓고 있습니다([위키피디아 참조](https://en.wikipedia.org/wiki/Reference_(computer_science))). *참조*는 어느 변수(주로 메모리에서의 한 구획)로 이어지는 링크인데, *이동*할 값을 대신하여 프로그램의 다른 부분들로 전달할 수 있는 요소입니다.

> 참조(&로 표기)는 *소유권*을 확보하지 않고도 해당 값을 *인용*할 수 있도록 합니다.

예시를 변경해서 참조가 어떻게 사용되었는가를 알아봅시다.

```Move
module M {
    struct T { value: u8 }
    // ...
    // ...
    // instead of passing a value, we'll pass a reference
    public fun value(t: &T): u8 {
        t.value
    }
}
````

`&` 표시를 인수 유형 `T`에 추가하였는데, 이를 통해 인수 유형을 기존의 `T`로부터 *T 참조* 내지는 `&T`로 변경하였습니다.

> Move에서는 두 가지 유형의 참조를 지원하는데, `&` 로 정의되는 *불변 유형*(예: `&T`)과 `&mut`에 해당하는 *가변 유형*(예: `&mut T`)이 있습니다.

불변 참조는 값을 변경하지 않고 읽을 수 있게 합니다. 반면 가변 유형은 값을 읽고 변경할 수 있습니다.

```Move
module M {
    struct T { value: u8 }

    // returned value is of non-reference type
    public fun create(value: u8): T {
        T { value }
    }

    // immutable references allow reading
    public fun value(t: &T): u8 {
        t.value
    }

    // mutable references allow reading and changing the value
    public fun change(t: &mut T, value: u8) {
        t.value = value;
    }
}
```

이제 업그레이드된 모듈 M을 어떻게 사용할지를 보겠습니다.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let t = M::create(10);

        // create a reference directly
        M::change(&mut t, 20);

        // or write reference to a variable
        let mut_ref_t = &mut t;

        M::change(mut_ref_t, 100);

        // same with immutable ref
        let value = M::value(&t);

        // this method also takes only references
        // printed value will be 100
        0x1::Debug::print<u8>(&value);
    }
}
```

> 불변(&) 참조를 사용하면 구조체로부터 데이터를 읽을 수 있으며, 가변(&mut)을 사용하면 이를 변경할 수 있습니다. 적절한 참조 유형을 사용함을 통해 보안성을 유지할 수 있으며 모듈 판독을 보조하여 독자들로 하여금 해당 메서드가 값을 변경하는지 아니면 읽기만 진행하는지를 알 수 있게 합니다.

### 차용 확인

Move는 참조를 사용하는 방식을 제어하며 예기치 못한 참사가 일어나는 일을 막도록 도와줍니다. 예시를 통해 이해해 봅시다. 모듈과 스크립트를 보면서 무슨 일이 일어나는지, 그리고 그 이유는 무엇인지를 함께 생각해 보겠습니다.

```Move
module Borrow {

    struct B { value: u64 }
    struct A { b: B }

    // create A with inner B
    public fun create(value: u64): A {
        A { b: B { value } }
    }

    // give a mutable reference to inner B
    public fun ref_from_mut_a(a: &mut A): &mut B {
        &mut a.b
    }

    // change B
    public fun change_b(b: &mut B, value: u64) {
        b.value = value;
    }
}
```

```Move
script {
    use {{sender}}::Borrow;

    fun main() {
        // create a struct A { b: B { value: u64 } }
        let a = Borrow::create(0);

        // get mutable reference to B from mut A
        let mut_a = &mut a;
        let mut_b = Borrow::ref_from_mut_a(mut_a);

        // change B
        Borrow::change_b(mut_b, 100000);

        // get another mutable reference from A
        let _ = Borrow::ref_from_mut_a(mut_a);
    }
}
```

이 코드는 컴파일이 진행되며 오류 없이 작동합니다. 먼저 여기에서 일어나고 있는 일은 가변 참조를 `A`에 사용하여 내부 구조체인 `B`에 가변 참조를 적용할 수 있도록 합니다. 그 뒤에 B를 변경하고, 계속 작업을 반복할 수 있습니다.

하지만 마지막 두 표현식을 바꾸어 `B`로의 가변 참조가 남아 있는 상태에서 `A`에 새로 가변 참조를 생성하려고 시도하면 어떻게 될까요?

```Move
let mut_a = &mut a;
let mut_b = Borrow::ref_from_mut_a(mut_a);

let _ = Borrow::ref_from_mut_a(mut_a);

Borrow::change_b(mut_b, 100000);
```

아마 오류가 발생했을 것입니다.

```Move
    ┌── /scripts/script.move:10:17 ───
    │
 10 │         let _ = Borrow::ref_from_mut_a(mut_a);
    │                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Invalid usage of reference as function argument. Cannot transfer a mutable reference that is being borrowed
    ·
  8 │         let mut_b = Borrow::ref_from_mut_a(mut_a);
    │                     ----------------------------- It is still being mutably borrowed by this reference
    │
```

This code won't compile. Why? Because `&mut A` is *being borrowed* by `&mut B`. If we could change `A` while having mutable reference to its contents, we'd get into an odd situation where `A` can be changed but reference to its contents is still here. Where would `mut_b` point to if there was no actual `B`?

코드가 컴파일되지 않을 것입니다. 그 이유는 `&mut A`가 `&mut B`에 의해 *차용되고 있기* 때문입니다. 만약 내용에 대한 가변 참조를 확보한 상태에서 `A`를 변경할 수 있게 된다면, 내용에 대한 참조가 여전히 여기 존재하는 상황에서 `A`가 변경된다는 이상한 상황이 발생하게 됩니다. `B`가 실제로 존재하지 않는데 `mut_b`가 어딜 지정해야 하는 걸까요?

이로써 몇 가지 결론이 도출됩니다.

1.  컴파일 에러가 일어나게 되는데, 즉 Move 컴파일러는 이런 사례들을 방지한다는 것을 뜻합니다. 이는 *차용 확인*이라고 하는 기능입니다(원본은 Rust 언어의 개념). 컴파일러는 *차용 그래프*를 축적하여 *차용된 값을 이동*하는 것은 허용하지 않습니다. 이는 Move를 블록체인에서 사용하기에 안전한 이유 중 하나입니다. 
2.  참조에서 참조를 생성하는 것도 가능하므로, 원본 참조는 신규 참조에서 *차용*하게 됩니다. 불변 및 가변 참조는 불변에서, 가변 참조는 가변에서만 생성할 수 있습니다.
3.  참조가 *차용된* 경우 다른 값들도 연결되어 있으므로 *이동*시킬 수 없습니다.

### 참조 해제

참조는 별표 `*`를 사용하여 연결된 값에서 참조 해제를 진행할 수 있습니다.

> 참조를 해제하는 경우에는 *사본*을 생성하게 됩니다. 해당 값에 복사 능력이 있는지를 확인하세요.

```Move
module M {
    struct T has copy {}

    // value t here is of reference type
    public fun deref(t: &T): T {
        *t
    }
}
```

> 참조 해제 연산자는 원본 값을 현재의 스코프로 이동해 주지 않습니다. 대신 이 값의 *사본*을 생성합니다.

Move에서 구조체의 내부 필드를 복사하기 위해 사용할 수 있는 기법이 하나 있는데, 바로 `*&`입니다. 필드에 대한 참조를 해제하는 것입니다. 여기 짧은 예시가 있습니다.

```Move
module M {
    struct H has copy {}
    struct T { inner: H }

    // ...

    // we can do it even from immutable reference!
    public fun copy_inner(t: &T): H {
        *&t.inner
    }
}
```

By using `*&` (even compiler will advise you to do so) we've copied the inner value of a struct.

`*&`를 사용하면 구조체의 내부 값을 복사하게 됩니다(컴파일러에서도 권장하는 기능입니다).

### 기본형의 참조

기본형은 단순하기 때문에 참조로 전달될 필요가 없으며 *복사* 작업을 대신 진행하게 됩니다. 해당 유형을 *값으로* 하여 함수에 전달한다 하더라도 현재 스코프에 남아있을 것입니다. 일부러 `move` 키워드를 사용할 수는 있으나, 기본형은 크기가 매우 작기 때문에 참조나 이동을 통해 전달하는 것보다 복사하는 것이 더 저렴할 수도 있습니다.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a = 10;
        M::do_smth(a);
        let _ = a;
    }
}
```

이 스크립트는 `a`를 참조로 전달하지 않았음에도 컴파일 될 것입니다. VM에서 이미 배치해 두었기 때문에 `copy`를 추가할 필요는 없습니다.
