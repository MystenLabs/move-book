# Yetenekli Tipler

Move dili özelleştirilebilir ve esnek bir tip sistemine sahiptir. Tiplerdeki değerlerin nasıl kullanılabildiğini, atılabildiğini ya da depolanabildiğini tanımlayan 4 adet yetenek vardır:

> “Copy” (Kopyala), “Drop” (At), “Store” (Depola), “Key” (Anahtar)

Basitçe tarif:

- **Copy** - değer _kopyalanabilir_ (ya da klonlanabilir).
- **Drop** - değer kapsamın dışına varana kadar _atılabilir_.
- **Key** - değer genel depolama operasyonları için _bir anahtar olarak kullanılabilir_.
- **Store** - değer genel bir depoda _depolanabilir_.

Bu sayfada `Copy` ve `Drop` yeteneklerini detaylıca göreceğiz; `Key` ve `Store` yeteneklerini [Kaynaklar](/resources/index.html) bölümünde daha detaylı bir şekilde işleyeceğiz.

### Yetenekler Syntax’ı

> İlkel ve yerleşik tiplerin yetenekleri önceden tanımlanmış ve değiştirilemezdir: integer, vektör, adres ve boolean değerleri _copy_, _drop_, ve _store_ yeteneklerine sahiptir

Ancak struct'ları tanımlarken bu syntax'ı kullanarak herhangi bir yetenek kümesi belirleyebilirsiniz:

```Move
struct NAME has ABILITY [, ABILITY] { [FIELDS] }
```

Örnek:

```Move
module Library {

    // her yeteneğin eşleşen anahtar kelimesi vardır
    // birden fazla yetenek virgülle listelenir
    struct Book has store, copy, drop {
        year: u64
    }

    // tek yetenek de mümkündür
    struct Storage has key {
        books: vector<Book>
    }

    // bunun hiç yeteneği yok
    struct Empty {}
}
```

### Yeteneği olmayan Yapılar

Yeteneklerin nasıl kullanılacağına ve dile ne getirdiklerine girmeden önce, yeteneksiz tiplerin ne olduklarına bakalım.

```Move
module Country {
    struct Country {
        id: u8,
        population: u64
    }

    public fun new_country(id: u8, population: u64): Country {
        Country { id, population }
    }
}
```

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000);
    }
}
```

Eğer bu kodu çalıştırırsanız, bu hatayı alırsınız:

```
error:
   ┌── scripts/main.move:5:9 ───
   │
 5 │     Country::new_country(1, 1000000);
   │     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cannot ignore values without the 'drop' ability. The value must be used
   │
```

`Country::new_country()` metodu bir değer oluşturur, bu değer hiçbir yerde geçirilmediği için fonksiyon bittiğinde otomatik olarak atılır. Ama Country tipinin _Drop_ yeteneği yok ve başarısızı oluyor. Şimdi yapı tanımımızı değiştirip **Drop** yeteneğini ekleyelim.

### Drop

Yetenek syntax’ını kullanarak `has drop` ekleyip bu yapının `drop` yeteneğini belirtiyoruz. Bu yapının tüm durumları drop yeteneğine sahip olacak ve böylece _atılabilir_ olacak.

```Move
module Country {
    struct Country has drop { // has <ability>
        id: u8,
        population: u64
    }
    // ...
}
```

Şimdi `Country` yapısı atılabildiğinde kodumuz çalıştırılabilir.

```Move
script {
    use {{sender}}::Country;

    fun main() {
        Country::new_country(1, 1000000); // değer atıldı
    }
}
```

> **Not**: Drop yeteneği _atma_ hareketini tanımlar, [_Yok etmek_](/advanced-topics/struct.html#destructing-structures) Drop gerektirmez.

### Copy

`Country` yapısının yeni instancelarını oluşturmayı ve atmayı öğrendik. Peki bir _kopya_ oluşturmak isteseydik ne yapardık? Varsayılan ayarlara göre yapılar değerle geçirilir, bu yapının bir kopyasını oluşturmak için `copy` anahtar kelimesini kullanacağız ([bir sonraki kısımda](/advanced-topics/ownership-and-references.html) bu hareketi daha detaylı bir şekilde öğreneceksiniz:

```Move
script {
    use {{sender}}::Country;

    fun main() {
        let country = Country::new_country(1, 1000000);
        let _ = copy country;
    }
}
```

```
   ┌── scripts/main.move:6:17 ───
   │
 6 │         let _ = copy country;
   │                 ^^^^^^^^^^^^ Invalid 'copy' of owned value without the 'copy' ability
   │
```

Bekleyebildiğiniz üzere, copy yeteneği olmadan bir tipin kopyasını yapmak başarısız oldu. Derleyenin mesajı da oldukça açık:

```Move
module Country {
    struct Country has drop, copy { // burdaki virgüle dikkat edin!
        id: u8,
        population: u64
    }
    // ...
}
```

Bu değişimi yaparsak üstteki kod derlenir ve çalışır.

### Özet

- İlkel tipler store, copy ve drop’a sahiptir.
- Varsayılan olarak yapıların hiçbir yeteneği yoktur.
- Copy ve Drop yetenekleri bir değerin kopyalanabilmesini ve atılabilmesini tanımlar.
- Bir yapı için 4 yetenek kurmak mümkün.

### Daha fazla bilgi için

- [Move Yetenekleri Tanımları](https://github.com/diem/diem/blob/main/language/changes/3-abilities.md)
