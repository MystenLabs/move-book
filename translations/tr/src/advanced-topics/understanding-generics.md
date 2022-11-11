# Jenerikler (Generics)

Jenerikler Move için esastır. Jenerik, Move’un esnekliğinin kaynağıdır ve blockchain dünyasında bu dili bu kadar özgün yapan unsurdur.

[Rust Kitabı](https://doc.rust-lang.org/stable/book/ch10-00-generics.html)’ndan bir kesitle başlayalım: Jenerikler somut tipler ve diğer özellikler için oluşturulan soyut yedeklerdir. Bir fonksiyonu yazmamızı sağlayan unsurlardır. Bu fonksiyonlar da sonradan her tip için kullanılabilirler. Her tip için kalıp işleyicisi (template handler) olarak kullanılabildikleri için onlara kalıp (template) da diyebiliriz.

Move’da jenerikler, `struct` ve `function` imzalarına uygulanabilir.

### Struct tanımında jenerikler

Önce `u64` değerini tutan bir kutu oluşturacağız. Bunları daha önce de gördük.

```Move
module Storage {
    struct Box {
        value: u64
    }
}
```

Bu kutu sadece `u64` tipinde değer içerebilir. Peki ya aynı kutuyu `u8` ya da `bool` tipleri için yapmak isteseydik? `Box1` sonra `Box2` mı yapmamız gerekirdi? Yoksa farklı bir modül mü üretirdik? Hayır, jenerik kullanırdık.

```Move
module Storage {
    struct Box<T> {
        value: T
    }
}
```

Struct adının yanına `<T>` koyduk. Açılı ayraçların `<..> `olduğu yer jenerik tiplerini tanımlama yeridir. `T`, bu struct'da kalıba çevirdiğimiz bir tiptir. Struct gövdesi tanımımızın içinde `T`‘yi sıradan bir tip olarak kullandık. `T` tipi diye bir şey yok. Sadece _herhangi bir tip_ için bir yer tutucu (placeholder) olarak orada duruyor.

### Fonksiyon imzasında (function signature) jenerikler

Şimdi `u64`‘yi değer olarak kullanacak bu struct için bir yapıcı metod (constructor) oluşturalım.

```Move
module Storage {
    struct Box<T> {
        value: T
    }

    // u64 tipi açılı ayraçların içince koyulmuş
    // demek ki u64 tipinde Box kullanıyoruz
    public fun create_box(value: u64): Box<u64> {
        Box<u64>{ value }
    }
}
```

Jenerikleri tanımlamak biraz daha karışık bir işlemdir. Çünkü belirtilen parametrelerine ihtiyaç duyarlar ve sıradan `Box` sturct'ı `Box<u64>`’a dönüşür. Jenerikleri tanımlarken açılı ayraçlara istediğiniz tipi geçirebilirsiniz. Bunun üzerine bir kısıtlama yoktur. `create_box` metodumuzu genelleştirmek ve kullanıcıların her tipi belirtmesi için başka bir jenerik kullanırız. Bu sefer bunu fonksiyon imzasının içinde yapalım!

```Move
module Storage {
    // ...
    public fun create_box<T>(value: T): Box<T> {
        Box<T> { value }
    }

    // Buna biraz sonra gireceğiz bana güvenin
    public fun value<T: copy>(box: &Box<T>): T {
        *&box.value
    }
}
```

### Fonksiyon çağrılarında jenerikler

Yaptığımız şey fonksiyon isminden hemen sonra fonksiyona açılı ayraç eklemekti. Aynı struct'larda yaptığımız gibi. Peki bu fonksiyonu nasıl kullanırız? Fonksiyon çağrısında tip belirterek.

```Move
script {
    use {{sender}}::Storage;
    use 0x1::Debug;

    fun main() {
        // değer Storage::Box<bool> tipinde olacak
        let bool_box = Storage::create_box<bool>(true);
        let bool_val = Storage::value(&bool_box);

        assert(bool_val, 0);

        // integerla da aynısını yapabiliriz
        let u64_box = Storage::create_box<u64>(1000000);
        let _ = Storage::value(&u64_box);

        // başka bir kutuyla da aynısını yapalım!
        let u64_box_in_box = Storage::create_box<Storage::Box<u64>>(u64_box);

        // bu kutunun değerine ulaşmak zorlu olacak :)
        // Box<u64> bir tip ve Box<Box<u64>> de bir tip
        let value: u64 = Storage::value<u64>(
            &Storage::value<Storage::Box<u64>>( // Box<u64> type
                &u64_box_in_box // Box<Box<u64>> type
            )
        );

        // şimdi Debug::print<T> metodunu gördünüz
        // o da herhangi bir tipi yazdırmak için jenerik kullanıyor
        Debug::print<u64>(&value);
    }
}
```

Burada Box struct'ını 3 tiple kullandık `bool` , `u64` ve `Box<u64>` - sonuncusu çok karmaşık gelebilir fakat alıştığınız ve nasıl çalıştığını anladığınız zaman rutininizin pir parçası oluyor.

<!-- , Move opens in new way - the way you probably could never imagine in blockchains. -->

Daha fazla ileri gitmeden önce bir adım geri gidelim. `Box` struct'ına jenerik ekleyerek bu kutuyu _soyut_ yaptık. Tanımı, bize verdiği kapasiteyle karşılaştırıldığına oldukça basit. Artık herhangi bir tiple `Box` oluşturmayı biliyoruz. Bu `u64`, `adress`, başka bir box ya da başka bir struct olabilir.

### Yetenekleri kontrol etmeye dair kısıtlamalar

[Yetenekleri](/advanced-topics/abilities/README.md) öğrendik. Jeneriklerle “kontrol edilebilir” ya da _kısıtlanabilirler_. Kısıtlamalar, isimlerini yeteneklerinden alırlar:

```Move
fun name<T: copy>() {} // sadece kopyalanabilir değerlere izin ver
fun name<T: copy + drop>() {} // değerler kopyalanabilir ya da atılabilir
fun name<T: key + store + drop + copy>() {} // 4 yetenek birden var
```

...ya da struct ile:

```Move
struct name<T: copy + drop> { value: T } // T kopyalanabilir a da atılabilir
struct name<T: store> { value: T } // T genel depoda depolanabilir
```

> Bu syntax’ı unutmamaya çalışın: `+` (artı) işaretini ilk başta garipseyebilirsiniz. Çünkü Move’un anahtar kelime listesinde `+` kullanılan tek yer burası.

Kısıtlamalarla bir sistem örneği:

```Move
module Storage {

    // kutunun içerikleri depolanabilir
    struct Box<T: store> has key, store {
        content: T
    }
}
```

İç tipler (ya da jenerik tipler) kapsayıcılarının tüm yeteneklerine (`key` hariç) sahip olmaları ZORUNLUDUR. Düşündüğünüzde her şey mantıklı ve sezgisel işliyor: kopyalama yeteneği olan bir yapının içeriği de **kopyalama** yeteneğine sahip olmalı. Öbür türlü kapsayan obje kopyalanabilir olamaz. Move derleyicisi bu mantığı takip etmeyen kodlar yazmanıza izin verir fakat bu yetenekleri kullanamazsınız.Örnek:

```Move
module Storage {
    // kopyalanamaz ya da atılamaz yapı
    struct Error {}

    // kısıtlamalar belirtilmemiş
    struct Box<T> has copy, drop {
        contents: T
    }

    // bu metod kopyalanamayan veya atılamayan (not droppable) içerikli bir kutu oluşturuyor
    public fun create_box(): Box<Error> {
        Box { contents: Error {} }
    }
}
```

Bu kod başarılı bir şekilde yazılır ve derlenir, ama kullanmaya çalışırsanız...

```Move
script {
    fun main() {
        {{sender}}::Storage::create_box() // değer oluşturuldu ve atıldı
    }
}
```

Box’nun atılamaz (not droppable) olduğunu söyleyen bir hatayla karşılaşacaksınız:

```
   ┌── scripts/main.move:5:9 ───
   │
 5 │   Storage::create_box();
   │   ^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

Bu durum iç değerin atma yeteneğine sahip olmamasından kaynaklanıyor. Kapsayıcı otomatik olarak içindekiler tarafından kısıtlanıyor, yani, örneğin eğer kopyalama, atma ve depolama yeteneğine sahip bir kapsayıcınız ve içinde sadece atma yeteneği olan bir yapınız varsa bu kapsayıcıyı kopyalamak ya da depolamak imkansız olacaktır. Kısacası, bir kapsayıcının içindeki tiplere dair kısıtlayıcıları olmak zorunda değildir, esnek olabilir - içindeki her tip için kullanılabilir.

> Fakat hatalardan kaçınmak için fonksiyonlarda ve yapılarda jenerik kısıtlamalarını kontrol edin ve gerekiyorsa belirtin.

Bu örnekte daha güvenli bir yapı tanımı şu olabilirdi:

```Move
// ebeveynin kısıtlamalarını yazıyoruz
// şimdi iç tip kopyalanabilir ve atılabilir OLMALI
struct Box<T: copy + drop> has copy, drop {
    contents: T
}
```

### Jeneriklerde çoklu tipler

Sadece bir tip kullanabildiğiniz gibi isterseniz birden fazla tip de kullanabilirsiniz. Jenerik tipler açılı ayraçların içine konup virgülle ayrılır. Şimdi yeni bir tip olan `Shelf`’i ekleyelim. İki farklı tipteki iki kutuyu tutacak.

```Move
module Storage {

    struct Box<T> {
        value: T
    }

    struct Shelf<T1, T2> {
        box_1: Box<T1>,
        box_2: Box<T2>
    }

    public fun create_shelf<Type1, Type2>(
        box_1: Box<Type1>,
        box_2: Box<Type2>
    ): Shelf<Type1, Type2> {
        Shelf {
            box_1,
            box_2
        }
    }
}
```

`Shelf` için tip parametreleri yapının bölgesinin tanımının içinde listelenip eşlenmiştir. Ayrıca görebildiğiniz gibi jeneriklerin içindeki tip parametrelerinin ismi önemli değil, düzgün bir tane seçmek size bağlı. Ve her bir tip parametre tanım içinde geçerli yani `T1` veya `T2‘yi` `T` ile eşleştirmeye gerek yok.

Birden fazla jenerik tip parametresi kullanmak, bir tane kullanmaya benzer:

```Move
script {
    use {{sender}}::Storage;

    fun main() {
        let b1 = Storage::create_box<u64>(100);
        let b2 = Storage::create_box<u64>(200);

        // herhangi bir tip kullanabilirsin – yani aynı olanlar da geçerli
        let _ = Storage::create_shelf<u64, u64>(b1, b2);
    }
}
```

_Bir tanımda 18,446,744,073,709,551,615 (u64 boyutu) sayısına kadar jeneriğe sahip olabilirsiniz. Bu sınıra kesinlikle varmayacaksınız, o yüzden istediğiniz kadar kullanın._

### Kullanılmamış tip parametreleri

Jeneriklerde belirtilmiş her tip kullanılmak zorunda değildir. Bu örneğe bakınız:

```Move
module Storage {

    // bu iki tip kutunun shelf’ten alındığında
    // nereye gönderileceğini işaretlemek için kullanılacak
    struct Abroad {}
    struct Local {}

    // düzenlenmiş Box aynı hedef niteliğe sahip olacak
    struct Box<T, Destination> {
        value: T
    }

    public fun create_box<T, Dest>(value: T): Box<T, Dest> {
        Box { value }
    }
}
```

Bazen jenerikleri kısıtlamak ya da sabit olarak kullanmak faydalı oluyor. Kodda nasıl kullanılabildiğine bakalım:

```Move

script {
    use {{sender}}::Storage;

    fun main() {
        // değer Storage::Box<bool> tipinde olacak
        let _ = Storage::create_box<bool, Storage::Abroad>(true);
        let _ = Storage::create_box<u64, Storage::Abroad>(1000);

        let _ = Storage::create_box<u128, Storage::Local>(1000);
        let _ = Storage::create_box<address, Storage::Local>(0x1);

        // or even u64 destination!
        let _ = Storage::create_box<address, u64>(0x1);
    }
}
```

Burada jeneriği tipi işaretlemek için kullanıyoruz ama aslında kullanmıyoruz. İlerde, kaynaklar konseptine geldiğimizde bu tanımın neden önemli olduğunu öğreneceksiniz. Şimdilik bu, sadece onları kullanmanın farklı bir yolu.

<!-- ### Copyable

*Copyable kind* - is a kind of types, value of which can be copied. `struct`, `vector` and primitive types - are three main groups of types fitting into this kind.

To understand why Move needs this constraint let's see this example:

```Move
module M {
    public fun deref<T>(t: &T): T {
        *t
    }
}
```

By using *dereference* on a reference you can *copy* the original value and return it as a regular. But what if we've tried to use `resource` in this example? Resource can't be copied, hence this code would fail. Hopefully compiler won't let you compile this type, and kinds exist to manage cases like this.

```Move
module M {
    public fun deref<T: copyable>(t: &T): T {
        *t
    }
}
```

We've added `: copyable` constraint into generic definition, and now type `T` must be of kind *copyable*. So now function accepts only `struct`, `vector` and primitives as type parameters. This code compiles as constraint provides safety over used types and passing non-copyable value here is impossible.

### Resource

Another kind has only one type inside is a `resource` kind. It is used in the same manner:

```Move
module M {
    public fun smth<T: resource>(t: &T) {
        // do smth
    }
}
```

This example here is only needed to show syntax, we'll get to resources soon and you'll learn actual use cases for this constraint. -->
