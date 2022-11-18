# Sahiplik ve Referanslar


Move VM, Rust’a benzeyen bir sahiplik sistemi uygular ve bu konseptin en iyi açıklaması [Rust kitabındadır.](https://doc.rust-lang.org/stable/book/ch04-01-what-is-ownership.html). 

Rust syntax’ının farklı olması ve bazı örneklerinin anlaşılması daha zor olmasına rağmen Rust Kitabı’ndaki sahiplik kısmını okumanızı tavsiye ediyorum. Bu bölümde ana kısımlara değineceğim.

> Her değişkenin sadece bir sahip kapsamı vardır. Sahip kapsamı bittiğinde sahip değişkenleri atılır.

Bu hareketi daha önce [ifadeler](/syntax-basics/expression-and-scope.md) bölümünde gördük. Bir değişkenin, kapsamı bitene kadar yaşadığını hatırlayalım. Şimdi işin derinliklerine inip neden böyle olduğunu anlama zamanı.

Owner (sahip), bir değişkene sahip olan bir kapsama verilen addır. Değişkenler bu kapsamda tanımlanabilir (örn. `let`) ya da kapsama argüman olarak geçirilebilirler. Move dilindeki tek kapsam fonksiyonlar olduğu için kapsamlara değişken koymanın başka bir yolu yoktur. 

Her değişkenin sadece tek sahibi vardır. Bu da demek oluyor ki; bir değişken fonksiyona argüman olarak geçirildiğinde bu fonksiyon *yeni owner*’a dönüşüyor ve artık eski fonksiyon değişkenin sahibi olarak görülmüyor. Kısacası, diğer fonksiyonun *değişkenin sahipliğini aldığını* söyleyebilirsiniz.

```Move
script {
    use {{sender}}::M;

    fun main() {
        // Module::T is a struct
        let a : Module::T = Module::create(10);

        // burada değişken 'a' 'main' fonksiyonunun bölgesinden ayrılıyor
        // ve `M::value` fonksiyonunun yeni bölgesine koyuluyor
        M::value(a);

        // bu bölgede artık bir değişken yok
        // bu kod derlenmeyecek
        M::value(a);
    }
}
```

Değerimizi içine geçirince `value()` fonksiyonuna ne olduğuna bakalım

```Move
module M {
    // create_fun atlandı
    struct T { value: u8 }

    public fun create(value: u8): T {
        T { value }
    }

    // M::T tipinin t değişkeni geçirildi
    // `value()` fonksiyonu sahipliği alıyor
    public fun value(t: T): u8 {
        // t değişken olarak kullanılabilir
        t.value
    }
    // fonksiyon bölgesi bitiyor, t atılıyor, sadece u8 sonucu dönüş yaptı
    // t artık yok
}
```

Hızlı çözüm olarak orijinal değişken ve ek sonuçlarla bir veri grubu döndürebilirdik. (dönüş değeri `(T, u8)` olurdu) ama Move’un daha iyi bir çözümü var

### Move (taşı) ve Copy (kopyala)

Öncelikle Move VM’sinin nasıl çalıştığını ve değerinizi bir fonksiyondan geçirdiğinizde ne olduğunu anlamanız gerekiyor. VM’de iki bytecode talimatı vardır: *MoveLoc* ve *CopyLoc* - `move` ve `copy` anahtar sözcükleriyle kullanılabilirler. 

Bir değişken başka bir fonksiyona geçirildiğinde *taşınmış (moved)* olur ve *MoveLoc* OpCode kullanılmış olur. `move` anahtar kelimesini kullanınca kodumuzun nasıl olacağına bakalım:

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        M::value(move a); // a değişkeni taşındı

        // yerel a droplandı
    }
}
```

Bu geçerli bir Move kodu fakat değerin zaten taşınacağını bildiğiniz için *taşımanıza* gerek yok. Bunu anladığımıza göre *copy* anahtar sözcüğüne geçiyoruz.

### `copy` anahtar sözcüğü

Eğer bir değeri fonksiyona (taşındığı yere) geçirmek ve değişkeninizin bir kopyasın kaydetmek isterseniz, `copy` anahtar kelimesini kullanabilirsiniz.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let a : Module::T = Module::create(10);

        // copy anahtar kelimesini bu yapıyı kopyalamak için kullanıyoruz
        // `let a_copy = copy a` olarak kullanılabilir
        M::value(copy a);
        M::value(a); // başarısız olmayacak, a hala orada
    }
}
```

Bu örnekte `a` değişkeninin (yani değerin) *kopyasını* `value`  metodunun ilk çağrısına geçirdik ve `a`‘yı yerel kapsamda ikinci bir çağırıda kullanmak için muhafaza ettik.

Bir değeri, kullanılabilmesi amacıyla, kopyalayarak çoğalttık ve programımızın hafıza büyüklüğünü arttırmış olduk. Fakat büyük boyutlu veriler kopyalarsanız fazla hafıza kullanabilir. Unutmayın – blockchainlerde her byte bizim için önemlidir ve işlemin bedelini büyük oranda etkiler. Yani her zaman `copy` kullanmak pahalıya patlayabilir.

Şimdi referansları öğrenmeye hazırsınız – Sizi gereksiz kopyalamadan kurtaracak ve para kaybetmemenizi sağlayacak bir araç.

## Referenslar

Birçok programlama dili referansların uygulanmasına sahiptir ([Wikipedia'dan bakınız](https://en.wikipedia.org/wiki/Reference_(computer_science))) Referans, bir değişkene (genelde hafızadaki bir bölüme) bağlanan bir bağlantıdır. *Referansları* kullanarak bir değeri taşımak yerine, değerleri programın diğer parçalarına geçirebilirsiniz.

> & ile işaretli referanslar sizin bir değerin sahipliğini almadan o değere başvurmanızı sağlar.

Hadi örneğimizi değiştirelim ve referanların nasıl kullanılabileceğini görelim.

```Move
module M {
    struct T { value: u8 }
    // ...
    // ...
    // değeri taşımak yerine bir referans geçireceğiz
    public fun value(t: &T): u8 {
        t.value
    }
}
````

T argüman tipine & ekledik ve bunu yaparak argüman tipini T yerine *T’nin referansına* yani &T‘ye değiştirmiş olduk.

> Move dili iki tür referans destekler: s*usturulamaz (immutable)* - & ile tanımlanır(örneğin &T ). Ve *susturulabilir (mutable)* - &mut (örneğin &mut T ).

Susturulamaz referanslar değerin değiştirmeden okunmasını sağlarken susturulabilir referanslar tam tersi olarak değerin okunmasını ve değiştirilmesini sağlar

```Move
module M {
    struct T { value: u8 }

    // dönüş yapan değer referans olmayan tipten
    public fun create(value: u8): T {
        T { value }
    }

    // susturulamaz referanslar okumaya izin verir
    public fun value(t: &T): u8 {
        t.value
    }

    // susturulabilir referanslar değerin okunmasını ve değiştirilmesini sağlar
    public fun change(t: &mut T, value: u8) {
        t.value = value;
    }
}
```

Şimdi geliştirilmiş M modülümüzü nasıl kullanacağımıza bakalım.

```Move
script {
    use {{sender}}::M;

    fun main() {
        let t = M::create(10);

        // doğrudan bir referans oluştur
        M::change(&mut t, 20);

        // ya da bir değişkene referans yaz
        let mut_ref_t = &mut t;

        M::change(mut_ref_t, 100);

        // susturulamaz referansla da aynı
        let value = M::value(&t);

        // bu metot sadece referansları alır
        // yazılan değer 100 olacak

        0x1::Debug::print<u8>(&value);
    }
}
```

> Yapılardan veri okumak için susturulamaz (&) referans kullanın. Değiştirmek için susturulabilir (mut&) referans kullanın. Uygun türde referanslar kullanarak güvenliğin sağlanmasına ve modüllerin okunmasına yardım edersiniz. Böylece okuyucu metodun değeri sadece okunacağını ya da değerde değiştirme yapılacağını anlar.

### Ödünç (borrow) kontrolü

Move dili referansları nasıl kullandığınızı kontrol eder ve beklenmedik zorlukları engellemenizi sağlar. Bunu nasıl yaptığını anlamak için bir örneğe bakalım. Bir modül ve yazı vereceğim ve sonrasında ne olduğuna ve neden olduğuna yorum yapacağız.

```Move
module Borrow {

    struct B { value: u64 }
    struct A { b: B }

    // içteki B ile A’yı oluştur
    public fun create(value: u64): A {
        A { b: B { value } }
    }

    // içteki B’ye susturulabilir referans ver
    public fun ref_from_mut_a(a: &mut A): &mut B {
        &mut a.b
    }

    // B’yi değiştir
    public fun change_b(b: &mut B, value: u64) {
        b.value = value;
    }
}
```

```Move
script {
    use {{sender}}::Borrow;

    fun main() {
        // yapı oluştur A { b: B { value: u64 } }
        let a = Borrow::create(0);

        // susturulabilir referansı mut A’dan mut B’ye getir
        let mut_a = &mut a;
        let mut_b = Borrow::ref_from_mut_a(mut_a);

        // B'yi değiştir
        Borrow::change_b(mut_b, 100000);

        // A'dan başka bir susturulabilir referans al
        let _ = Borrow::ref_from_mut_a(mut_a);
    }
}
```

Bu kod hatasız bir şekilde çalışır ve derlenir. `A`’da susturulabilir referans kullanıyoruz ki susturulabilir referansı iç yapısındaki `B`’ye getirelim. Sonra `B`’yi değiştiriyoruz. Bunun ardından işlem tekrarlanabilir.

Peki ya son iki ifadenin yerini değiştirip önce `B` hala canlıyken `A`’ya yeni bir susturulabilir referans açmaya çalışsaydık?

```Move
let mut_a = &mut a;
let mut_b = Borrow::ref_from_mut_a(mut_a);

let _ = Borrow::ref_from_mut_a(mut_a);

Borrow::change_b(mut_b, 100000);
```

Şu hatayı alırdık:

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

Bu kod derlenemez. Niye? Çünkü `&mut A` , `&mut B` tarafından ödünç (borrow) alınıyor. Eğer içindekilere susturulabilir bir referansa sahipken `A`’yı değiştirebilseydik, içindekilere referansların hala var olduğu ama A’nın değiştirilebilir olduğu garip bir duruma girerdik. Eğer gerçek bir `B `olmasaydı `mut_b` nereyi gösterirdi? 

Özetle:

1.	Bir derleme sorunu alıyoruz, bu demek ki Move derleyicisi bu olayları engelliyor. Buna *ödünç kontrolü* deniyor (Aslında Rust dilinden bir konsept). Derleyici bir ödünç grafiği inşa ediyor ve *ödünç alınan değerlerin taşınmasına* izin vermiyor. Bu Move’un blokchainlerde kullanılmasının bu kadar güvenli olmasının bir sebebi de budur.
2.	Referanstan referans üretebilirsiniz. Böylece asıl referans yeni bir referansa *ödünç alınabilir*. Susturulabilir referanslardan iki tür referansı da oluşturabiliriz. Susturulamaz fonksiyonlardansa sadece başka bir susturulamaz fonksiyon oluşturabiliriz.
3.	Referanslar *ödünç alındığıklarında* taşınamazlar çünkü başka değerler onlara bağlıdır.

### Referanstan ayırmak (Dereference)

Referanslar, bağlantılı değeri almak için referanstan ayrılabilir bunu yapmak için `*` kullanın.

> Referans ayrımı yaparken bir kopya yaparız. Bu yüzden değerin Copy yeteneğine sahip olduğundan emin olun.

```Move
module M {
    struct T has copy {}

    // burdaki t değeri referans türünden
    public fun deref(t: &T): T {
        *t
    }
}
```

> Referans ayırma operatörü orijinal değeri aktif kapsama taşımaz, onun yerine bu değerin bir kopyasını oluşturur.

Move’da bir yapının iç alanını kopyalamak için bu tekniği kullanırız: `*&`

Kısa bir örnek:

```Move
module M {
    struct H has copy {}
    struct T { inner: H }

    // ...

    // Susturulamaz bir referanstan bile yapabiliriz!
    public fun copy_inner(t: &T): H {
        *&t.inner
    }
}
```

`*&` kullanarak (derleyici bile böyle yapmanızı önerecektir) bir yapının iç değerini kopyaladık.

### İlkel tipleri referanslamak (Referencing primitive types)

İlkel tiplerin (basitliklerinden dolayı) referans olarak geçirilmelerine gerek yoktur. Onun yerine kopyalama operasyonu yapılır. Onları bir fonksiyona değerleriyle geçirseniz bile o anki kapsamlarında kalırlar. `move` anahtar sözcüğünü kullanabilirsiniz fakat ilkel tipler çok küçük boyutta oldukları için onları kopyalamak, referansla geçirmekten veya taşımaktan daha hesaplı olabilir.

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

Bu kod `a`‘yı referans olarak geçirmememize rağmen derlenir. `Copy` eklemek gereksizdir- VM zaten oraya onu koyuyor.
