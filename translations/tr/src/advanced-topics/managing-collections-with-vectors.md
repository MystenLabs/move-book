# Vektör ile Koleksiyonları Kontrol Etmek

`Struct` tipiyle halihazırda aşinasınız ki bu size kendi tiplerinizi oluşturma ve karmaşık verileri depolama kabiliyetini veriyor. Ama bazen daha dinamik, genişletilebilir ve kontrol edilebilir bir şeye ihtiyacınız oluyor. Bu ihtiyaç için Move’un vektörlerini kullanabilirsiniz.

Vektör veri _koleksiyonları_ depolamak için yerleşik bir tiptir. Biri hariç her tipin toplanması için genel bir çözümdür. Fonksiyonelliği size VM tarafından verildiği gibi; beraberinde çalışmanın tek yolu [Move standard library](https://github.com/diem/move/tree/main/language/move-stdlib/sources)’yi ve `native` fonksiyonlarını kullanmaktır.

```Move
script {
    use 0x1::Vector;

    fun main() {
        // boş bir vektör oluşturmak için jenerik kullanın
        let a = Vector::empty<&u8>();
        let i = 0;

        // veri ile dolduralım
        while (i < 10) {
            Vector::push_back(&mut a, i);
            i = i + 1;
        }

        // şimdi vektör uzunluğunu yazdırın
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);

        // sonra 2 unsurunu çıkarın
        Vector::pop_back(&mut a);
        Vector::pop_back(&mut a);

        // ve uzunluğu bir daha yazdır
        let a_len = Vector::length(&a);
        0x1::Debug::print<u64>(&a_len);
    }
}
```

Vektörler tek bir referans olmayan tipten `u64` sayısına kadar değer depolayabilirler. Kocaman depoları nasıl kontrol altında tuttuğunu görmek için hadi bir modül yazalım.

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

    // bu metot kopyalanamaz içerikler için erişilemez olacak
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }

    public fun create<T>(): Shelf<T> {
        Shelf {
            boxes: Vector::empty<Box<T>>()
        }
    }

    // kutu değeri vektöre taşındı
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

Bir shelf ve bu shelf için birkaç kutu oluşturacağız ki modülde vektörle nasıl çalışıldığını görelim:

```Move
script {
    use {{sender}}::Shelf;

    fun main() {

        // shelf ve u64 tipinde iki kutu oluştur
        let shelf = Shelf::create<u64>();
        let box_1 = Shelf::create_box<u64>(99);
        let box_2 = Shelf::create_box<u64>(999);

        // iki kutuya shlef’e koy
        Shelf::put(&mut shelf, box_1);
        Shelf::put(&mut shelf, box_2);

        // boyutunu yazdırır - 2
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));

        // sonra shelf’ten bir tane al (son push'lanan)
        let take_back = Shelf::remove(&mut shelf);
        let value     = Shelf::value<u64>(&take_back);

        // geri aldığımız kutunun 999’lu olduğunu onayla
        assert(value == 999, 1);

        // ve boyutu bir daha yazdır - 1
        0x1::Debug::print<u64>(&Shelf::size<u64>(&shelf));
    }
}
```

Vektörler oldukça güçlü araçlardır. Çok fazla veri depolamanıza (en fazla _18446744073709551615_) ve dizinlenmiş depo içinde bu veriyle çalışmana izin veriyorlar.

### Inline vektör tanımları için Hex ve Bytestring değişmezi

Vektörler, ayrıca string’leri de temsil etme amacıyla oluşturulmuş unsurlardır. VM yazıda `vector<u8>`’ü argüman olarak `main` fonksiyonuna geçirmeyi de destekler.

Ama Hexdecimal değişmezini scriptinizde `vector<u8>` tanımlamak için de kullanabilirsiniz:

```Move
script {

    use 0x1::Vector;

    // main’de argümanları kabul etmek için bir yol
    fun main(name: vector<u8>) {
        let _ = name;

        // sabitler böyle kullanılır
        // "hello world" stringi!
        let str = x"68656c6c6f20776f726c64";

        // hex sabiti size vector<u8>’i de verir
        Vector::length<u8>(&str);
    }
}
```

Bytestring sabitlerini kullanmak için benzer bir yaklaşım:

```Move
script {

    fun main() {
        let _ = b"hello world";
    }
}
```

Onlara ASCII olarak davranılır ve `vector<u8>` olarak yorumlanırlar.

### Vektör kopya kağıdı

Standart kütüphaneden vektör metodlarına dair küçük bir kopya kağıdı:

- `<E>` tipinde boş vektör oluştur

```Move
Vector::empty<E>(): vector<E>;
```

- Vektörün uzunluğunu al

```Move
Vector::length<E>(v: &vector<E>): u64;
```

- Elementi vektörün sonuna at:

```Move
Vector::push_back<E>(v: &mut vector<E>, e: E);
```

- Susturulabilir referans al, susturulabilir için `Vector::borrow()` kullan

```
Vector::borrow_mut<E>(v: &mut vector<E>, i: u64): &E;
```

- Vektörün sonundan bir element çıkar:

```
Vector::pop_back<E>(v: &mut vector<E>): E;
```

Move standart kütüphanesinde vektör modülü: [link](https://github.com/diem/move/blob/main/language/move-stdlib/sources/Vector.move)
