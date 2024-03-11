# Modüller ve İçe aktarım (Import)

Modüller geliştiricinin birkaç fonksiyonu paketleyerek kendi adresi adı altında paylaştığı birime verilen addır. Önceki bölümlerde sadece script kullandık ancak script sadece paylaşılmış olan modüllerle ya da standart kütüphane ile çalışabilir. Zaten standart kütüphane de aslen `0x1` adresi altında paylaşılan bir modüldür.

> Modüller göndericinin adresinin adı altında paylaşılır. Standart kütüphane `0x1` adresi adı altında paylaşılır.

> Bir modül paylaşılırken hiçbir fonksiyonu çalıştırılmaz. Bir modül kullanmak için scriptlere ihtiyacınız vardır.

Modüller `module` anahtar sözcüğüyle başlarlar. Ardından modül adı yazılır ve küme parantezi koyulur. Ardından modülün içerikleri küme parantezlerinin içerisine yazılır.

```Move
module Math {

    // modül içerikleri

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
```

> Modüller başkalarının erişebileceği kodları paylaşmanın tek yoludur. Yeni tipler ve kaynaklar sadece bir modülün içindeki bağlam sayesinde tanımlanabilirler.

Varsayılan ayarlara göre modülünüz derlenir ve sizin adresinizin adı atlında paylaşılır. Fakat modülleri yerel olarak kullanmak istiyorsanız (örn. Test etme ya da geliştirme durumlarında) ya da adresinizi modülünüzün içinde belirtmek istiyorsanız `adress <ADDR> {}` syntaxını kullanın:

```Move
address 0x1 {
module Math {
    // modül içerikleri

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }
}
}
```
*Modülde gösterildiği gibi en doğrusu modül satırını girintisiz tutmaktır.*

## İçe Aktarım

Move dilinde Default context boştur. Kullanabileceğiniz sadece ilkel tipler (integer, bool ve adres) vardır ve boş bir bağlam içerisinde yapabileceğiniz tek şey bu tipleri ve değişkenleri kullanmaktır. Bu durum da anlamlı ya da işe yarar bir şey yapmamızın önüne geçer.


Bunu değiştirmek için paylaşılmış modülleri (ya da standart kütüphaneden) içeri aktarabilirsiniz.

### Doğrudan İçe Aktarım

Kodunuzda modülleri doğrudan adreslerini yazarak kullanabilirsiniz:

```Move
script {
    fun main(a: u8) {
        0x1::Offer::create(a == 10, 1);
    }
}
```

Bu örnekte `0x1` adresinden (standart kütüphane) `Offer` modülünü içeri aktardık ve `assert(expr: bool, code: u8)` metodunu kullandık.

### Anahtar sözcük kullanımı

Yazdığınız kodları daha kısa tutmak için (0x1 adresinin kısa olduğunu hatırlatmak isterim, aslında adresler oldukça uzun oluyor!) ve içeri aktardıklarınızı organize etmek istiyorsanız `use` anahtar sözcüğünü kullanın:

```Move
use <Address>::<ModuleName>;
```

Burada `<Address>` paylaşanın adresi ve `<ModuleName>` modülün ismi oluyor. Oldukça basit. Aşağıda da aynısını uygulayalım. `Vector` modülünü `0x1` adresinden içeri aktaralım.

```Move
use 0x1::Vector;
```

### Modül'ün içeriğine erişim

İçe aktardığınız bir modülün metodlarına (veya tiplerine) erişmek için `::` gösterimini kullanın. İşte bu kadar basit. Modüller sadece tek bir katmanda tanım barındırabilir. Bundan dolayı paylaştığınız bir modüldeki yaptığınız tüm tanımlamalara iki adet iki nokta üst üste gösterimiyle erişilebilir.

```Move
script {
    use 0x1::Vector;

    fun main() {
        // Vector modülünün empty() metodunu kullanıyoruz
        // her modülün tüm metodlarına aynı bu şekilde ulaşabilirsiniz
        let _ = Vector::empty<u64>();
    }
}
```

### Scriptlerin içeri aktarımı

Scriptlerde içeri aktarımlar `script {}` blokunun içine koyulmalıdır.

```Move
script {
    use 0x1::Vector;

    // aynı modül içeri aktarımı gibi
    // istediğiniz kadar aktarabilirsiniz!

    fun main() {
        let _ = Vector::empty<u64>();
    }
}
```

### Modüllerin içeri aktarımı

Modül içeri aktarımları `module {}` blokunun içine koyulmalıdır.

```Move
module Math {
    use 0x1::Vector;

    // scriptlerle aynı şekilde
    // istediğiniz sayıda modülü içeri aktarabilirsiniz

    public fun empty_vec(): vector<u64> {
        Vector::empty<u64>();
    }
}
```

### Member import

Import deyiminin anlamı genişletilebilir. Modülün hangi üyelerini içeri aktarmak istediğinizi belirtebilirsiniz.

```Move
script {
    // tek üyenin içeri aktarımı
    use 0x1::Signer::address_of;

    // birden fazla üyenin içeri aktarımı (mind braces)
    use 0x1::Vector::{
        empty,
        push_back
    };

    fun main(acc: &signer) {
        // modül erişimi olmadan fonksiyon kullanımı
        let vec = empty<u8>();
        push_back(&mut vec, 10);

        // same here
        let _ = address_of(acc);
    }
}
```

### "Self" kullanarak modülü üyeleriyle birlikte içeri aktarmak

Üye içe aktarımı syntaxını biraz genişletirseniz tüm modülü ve üyelerini içeri aktarabilirsiniz. `Self`in modül için kullanımı aşağıdadır:

```Move
script {
    use 0x1::Vector::{
        Self, // Self == içeri aktarılmış modül
        empty
    };

    fun main() {
        // `empty`,`empty` olarak içeri aktarılıyor
        let vec = empty<u8>();

        // Self burada Vector anlamına geliyor
        Vector::push_back(&mut vec, 10);
    }
}
```

### Use ve as’in birlikte kullanımı

İsimlendirme çelişkilerini (2 ya da daha fazla modülün aynı isme sahip olması) önlemek için ya da kodunuzu kısaltmak için içeri aktardığınız modülün adını `as` anahtar sözcüğüyle değiştirebilirsiniz.

Syntax:

```Move
use <Address>::<ModuleName> as <Alias>;
```

In script:

```Move
script {
    use 0x1::Vector as V; // Vector’un adı V olarak değiştirildi

    fun main() {
        V::empty<u64>();
    }
}
```

Modülde de aynı şekilde:

```Move
module Math {
    use 0x1::Vector as Vec;

    fun length(&v: vector<u8>): u64 {
        Vec::length(&v)
    }
}
```

Self kullanarak *üyeleri içe aktarırken*:

```Move
script {
    use 0x1::Vector::{
        Self as V,
        empty as empty_vec
    };

    fun main() {
        // `empty`, `empty_vec` olarak içeri aktarılır
        let vec = empty_vec<u8>();

        // Self V = Vector olarak
        V::push_back(&mut vec, 10);
    }
}
```
Yukarıdaki örnek, modül ve scriptlerde de çalışmaktadır.
