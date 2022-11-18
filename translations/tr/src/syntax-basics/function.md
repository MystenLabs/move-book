# Function

Fonksiyonlar, Move’da yürütme işleminin gerçekleştiği tek alanlardır. Fonksiyonlar `fun` anahtar sözcükleriyle başlarlar. Ardından fonksiyon ismi, argümanları içeren parantezler ve son olarak gövde oluşturmak amacıyla küme parantezleri koyulur.

```Move
fun function_name(arg1: u64, arg2: bool): u64 {
    // fonksiyon gövdesi
}
```

Önceki bölümlerde fonksiyonları zaten görmüştünüz. Şimdi onları nasıl kullanacağınızı öğreneceksiniz.

> **Not:** Move dilinde fonksiyonlara isim verirken *snake_case* tarzını kullanmamız, yani küçük harflerle yazmamız ve kelimeler arasına `_` koymamız gerekir.

## Scriptlerde fonksiyonlar

Bir script bloku sadece bir adet *main* (ana) fonksiyon barındırabilir. Bu fonksiyon (argüman da içermesi ihtimali göz önünde bulundurularak) bir hareket (transaction) olarak yürütülür. Oldukça kısıtlıdır ve değer döndüremez. Halihazırda paylaşılmış olan modüllerdeki diğer fonksiyonları çalıştırmak için kullanılmalıdır.

Adresin var olup olmadığını kontrol eden basit bir script örneği:

```Move
script {
    use 0x1::Account;

    fun main(addr: address) {
        assert(Account::exists(addr), 1);
    }
}
```

Bahsettiğimiz gibi bu fonksiyona argüman koyulabilir. Bu örnekte argüman: `adress` tipi `addr` argümanı. Bu fonksiyon aynı zamanda içeri aktarılmış modülleri çalıştırabilir.

> **Not:** Sadece bir adet fonksiyon olduğu için ona istediğiniz adı verebilirsiniz ama genel programlama konseptlerini takip etmek istiyorsanız onu **main** olarak adlandırın.

## Modüllerde fonksiyonlar

Script bağlamında fonksiyonlar oldukça kısıtlı olsalar da modüllerde tüm potansiyellerini kullanabilirsiniz. Bir daha tekrar edelim: Modüller birkaç fonksiyon ve tipin (bir sonraki bölümde bunu detaylı inceleyeceğiz) paketlenmiş ve paylaşılmış halleridir. Modüller bir veya birden fazla görevi yerine getirirler.

Şimdi basit bir Matematik modülü yapacağız. Bu modül kullanıcılara basit matematiksel fonksiyonlar ve birkaç yardım edici metodlar sunacak. Bunların çoğu modül kullanılmadan da yapılabilir fakat buradaki amacımız öğrenmek!

```Move
module Math {
    fun zero(): u8 {
        0
    }
}
```

İlk adım: `Math` adlı bir modül tanımladık ve içerisine `zero()` fonksiyonunu koyduk. Bu fonksiyon `u8` tipinde olan 0 değerini bize verir. İfadeleri hatırladınız mı? `0`dan sonra noktalı virgül yok çünkü zaten fonksiyonun döndürdüğü değerin ta kendisi. Burada da bloklarla yaptığımız gibi yapıyoruz. Bloklar ve fonksiyon gövdeleri birbirlerine oldukça benzerler.

### Fonksiyon argümanları

Bunun artık kafanızda oldukça net olması lazım fakat bir daha tekrar edelim. Fonksiyonlar argüman (değerlerin fonksiyonlara geçmesi) alabilirler ve sınırsız sayıda argüman barındırabilirler. Her argümanın 2 özelliği vardır: ismi ve tipi.

Fonksiyon argümanları, bir kapsam içerisinde tanımlanan her değişken gibi, sadece fonksiyon gövdesi içerisinde canlı kalırlar. Fonksiyon bloku bittiğinde ortada değişken kalmaz.

```Move
module Math {

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    fun zero(): u8 {
        0
    }
}
```

Math fonksiyonumuzda değişiklikler yapalım. İki `u64` değerini toplayan `sum(a,b)` fonksiyonu bir `u64` tipinde bir sonuç döndürüyor (tipi değişemez).

Birkaç syntax kuralı belirtelim:

1.	Argümanların tipleri olmalıdır ve aralarına virgül koyulmalıdır
2.	Fonksiyon dönüş değeri parantezden sonra gelir ve öncesinde iki nokta üst üste işareti olması gereklidir.


Peki bu fonksiyonu bir scriptte nasıl görebiliriz? Import yaparak.
```Move
script {
    use 0x1::Math;  // burada 0x1 kullandım; kendi adresinizi koyabilirsiniz
    use 0x1::Debug; // bundan sonra bahsedeceğiz

    fun main(first_num: u64, second_num: u64) {

        // değişken ismi ve fonksiyon ismi aynı olması gerekmiyor
        let sum = Math::sum(first_num, second_num);

        Debug::print<u64>(&sum);
    }
}
```

### `return` anahtar sözcüğü

`return` anahtar sözcüğü fonksiyon yürütmesini durdurmanızı ve bir değer döndürülmesini sağlar. `if` koşuluyla kullanılması gerekmektedir çünkü kontrol akışını koşullu bir şekilde değiştirmenin tek yolu budur.

```Move
module M {

    public fun conditional_return(a: u8): bool {
        if (a == 10) {
            return true // noktalı virgül yok!
        };

        if (a < 10) {
            true
        } else {
            false
        }
    }
}
```

### Birden fazla değer döndürmek

Önceki örneklerde dönüş değeri olmayan ya da single fonksiyonlarla birkaç deney yaptık. Peki size her tipten birden fazla değer döndürebileceğimizi söylesem? İlginizi çekti mi? Haydi bir inceleyelim!

Birden fazla dönüş değeri belirtmek için parantez kullanmanız gerekir:

```Move
module Math {

    // ...

    public fun max(a: u8, b: u8): (u8, bool) {
        if (a > b) {
            (a, false)
        } else if (a < b) {
            (b, false)
        } else {
            (a, true)
        }
    }
}
```

Bu fonksiyon `a` ve `b` olan iki argüman almaktadır ve iki değer döndürmektedir. İlki, ikisi arasındaki değerin en büyüğü hangisiyse geçirir, ikincisiyse bir booldur. Girilen sayıların aynı olması bir şey değiştirmez. Syntaxa daha detaylı bir bakalım: tek dönüş argümanı belirtmek yerine parantez ekledik ve argüman dönüş tiplerini listeledik.

Aşağıdaki örnekte bu fonksiyonun sonucunu scriptteki farklı bir fonksiyonda nasıl kullanacağımızı göreceksiniz:

```Move
script {
    use 0x1::Debug;
    use 0x1::Math;

    fun main(a: u8, b: u8)  {
        let (max, is_equal) = Math::max(99, 100);

        assert(is_equal, 1)

        Debug::print<u8>(&max);
    }
}
```

Bu örnekte bir veri grubunu *yok ettik*: max fonksiyonunun dönüş değerlerini değerlerini ve tiplerini içeren iki değişken oluşturduk. Böylece düzen korunuyor ve max değişkeni u8 tipini alıyor ve artık maksimum değeri barındırıyor. Öteki yandn *is_equal* bir *bool*dur.

Burada sınırımız iki değildir. Döndürülen argümanların sayısı tamamen size kalmış. Fakat ileride structlar hakkında öğrendiğinizde kompleks verileri döndürmek için alternatif bir yol göreceksiniz.

### Fonksiyon görülebilirliği

Bir modül tanımlarken diğer geliştiricilerin bazı fonksiyonları görebilmelerini, bazılarını da görmemelerini isteyebilirsiniz. İşte bu durumda *fonksiyon görünülebilirlik değiştiricileri* devreye girer.

Varsayılan ayarlara göre modüllerde tanımlanan her fonksiyon gizlidir. Farklı modüllerden veya scriptlerden erişilemezler. Ancak dikkatli birisiyseniz Math modülümüzde tanımladığımız bazı fonksiyonların `public` anahtar sözcüğü taşıdığını görmüş olabilirsiniz.

```Move
module Math {

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    fun zero(): u8 {
        0
    }
}
```

Bu örnekte `sum()` fonksiyonu, modül içeri aktarıldığında dışarıdan erişilebilir halde. Ancak `zero()` fonksiyonu varsayılan ayarlardan dolayı gizlidir.

> `public` anahtar sözcüğü, fonksiyonun varsayılan gizlilik ayarını değiştirir ve onu açık hale getirir.

Kısacası `sum()` fonksiyonunu *public* yapmadıysanız bu mümkün olmazdı.

```Move
script {
    use 0x1::Math;

    fun main() {
        Math::sum(10, 100); // derlemiyor!
    }
}
```

### Yerel fonksiyonlara erişim

Eğer asla erişilemiyorsa gizli fonksiyon yapmanın hiçbir anlamı olmazdı. Gizli fonksiyonların var olma sebebi, açık fonksiyonlara çağrı yapıldığında *iç çalışma* yapmalarını sağlamaktır.

> Gizli fonksiyonlar sadece içerisinde tanımlandıkları modüllerde erişime açıktırlar.

Peki aynı modülde bu fonksiyonlara nasıl erişebiliriz? Fonksiyonu sanki içeri aktarım yapılıyormuş gibi çağırarak!

```Move
module Math {

    public fun is_zero(a: u8): bool {
        a == zero()
    }

    fun zero(): u8 {
        0
    }
}
```

Bir modül içerisinde tanımlanan her fonksiyon, gizlilik ayarı fark etmeksizin, aynı modülde yer alan her fonksiyon tarafından erişilebilir haldedir. Bu şekilde gizli fonksiyonlar, açık fonksiyonlar içerisinde çağrı yaparak kullanılabilirler. Böylece gizli özellikleri ya da riskli operasyonları ortaya çıkarmamış, yani gizlemiş oluruz.

### Yerli fonksiyonlar

Bir de yerli fonksiyon adı verilen özel fonksiyonlar var. Yerli fonksiyonlar, kodumuza Move’un içinde mümkün olmayan işlevsellikler katmamızı sağlarlar ve bizim kodlama gücümüzü arttırırlar. Yerel fonksiyonlar VM tarafından tanımlanırlar ve çeşitli kullanım çeşitleri vardır. Bu da Move syntaxı bağlamında kullanılmadıkları anlamına geliyor. Bu nedenle fonksiyon gövdesi içinde bulunmak yerine sadece noktalı virgülle biterler. `native` anahtar kelimesi, yerel fonksiyonları işaretlemek amacıyla kullanılır. Fonksiyon görülebilirliğiyle çelişmezler ve bir fonksiyon aynı anda hem `native` hem `public` olabilir.

Diem’in standart kütüphanesinden bir örnek:

```Move
module Signer {

    native public fun borrow_address(s: &signer): &address;

    // ... ve farklı fonksiyonlar ...
}
```
