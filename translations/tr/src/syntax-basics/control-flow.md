#   Kontrol Akışı

Move bir emir dilidir ve her emir dili gibi bir *kontrol akışı* vardır. Kontrol akışı, bir kod blokunun çalıştırılıp çalıştırılmayacağını ya da hangi kodun çalışacağını seçmenin bir yoludur.

<!-- In Move you have two statme to control flow: by using loops (`while` and `loop`) or `if` expressions. -->

Move dilinde döngüler (loop) vardır. Bunlar `while`, `loop` ve `if` ifadeleridir.

##  `if` ifadesi

`if` ifadesi bir koşul doğruysa bir kod blokunun çalıştırılmasını veya yanlışsa farklı bir kod blokunun çalıştırılmasını sağlayan ifadedir.

```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        if (a) {
            Debug::print<u8>(&0);
        } else {
            Debug::print<u8>(&99);
        };
    }
}
```

Bu örnekte `if` ve `block`u kullanarak `a == true` ise `0`, a `false` ise `99` printlemesini sağladık. İşte bu kadar basit. if syntaxı aşağıdaki gibidir:

```
if (<bool_ifadesi>) <ifade> else <ifade>;
```

`if` bir ifadedir ve her ifade gibi noktalı virgül ile bitmelidir. Bu da “if”i `let` deyimiyle kullanmamız için bir sebeptir.

```Move
script {
    use 0x1::Debug;

    fun main() {

        // try switching to false
        let a = true;
        let b = if (a) { // ilk branch
            10
        } else { // ikinci branch
            20
        };

        Debug::print<u8>(&b);
    }
}
```

Burada `a` ifadesine göre `b` değişkenine farklı bir değer atanacak. Ama `if` fonksiyonundaki iki branch de aynı tipi döndürmeli. 
Aksi halde `b` değişkeninin farklı bir tür olma (ya da tanımsız olma) seçeneği olacaktır ve bu statik dillerde imkansızdır. Compiler terimlerine göre buna branch uyumluluğu deriz. İki branch de uyumlu (aynı) tipi döndürmek zorundadır.


`if`, `else` kullanmadan solo olarak kullanılabilir.

```Move
script {
    use 0x1::Debug;

    fun main() {

        let a = true;

        // sadece bir adet seçimli branch
        // eğer a = false olursa debug çağrısı olmaz
        if (a) {
            Debug::print<u8>(&10);
        };
    }
}
```

But keep in mind that `if` expression without `else` branch cannot be used in assignment as when condition is not met - alternative branch is not called and variable may be undefined which is, again, impossible.

## Döngülerle yineleme (iterating) yapmak

Move dilinde loopları tanımlamanın iki yolu vardır

1.	`while` kullanarak yapılan koşullu (conditional) loop
2.	Sonsuz (infinite) loop

### `while` kullanarak yapılan koşullu (conditional) loop

`while` bir loopu tanımlamanın yollarından biridir. While kullanarak belli koşullar sağlandığında çalıştırılan bir ifade elde etmiş oluruz. Bu looplarda *while* koşulu `true` olduğu sürece kod yineleyerek tekrar çalıştırılmaya devam eder. Koşul koymak için genellikle dış değişkenler ya da sayaçlar (counter) kullanılır.

```Move
script {
    fun main() {

        let i = 0; // sayacı tanımlayın

        // while i < 5'i yineleyin
        // her yinelemede i değerini arttırın
        // i 5 olduğunda koşul karşılanmaz ve loop sonlanır
        while (i < 5) {
            i = i + 1;
        };
    }
}
```

`while`ın aynı `if` gibi bir ifade olduğunu belirtmemiz oldukça önemli. `while`ın sonuna da noktalı virgül koymamız gerekir. Bu yüzden while looplarının genel syntaxı şöyledir:

```Move
while (<bool_expression>) <expression>;
```

`if`in aksine `while` bir değer döndüremez bu yüzden değişken ataması (`if` ifadesiyle yaptığımız gibi) yapmamız mümkün değildir.

### Erişilemeyen kod (Unreachable code)

Move dilinin güvenilir olması için emniyetli de olması gerekir. Bu yüzden Move tüm değişkenleri kullanmanızı zorunlu kılar ve erişilemeyen kod bulunmasına izin vermez. Dijital varlıklar programlanabilir ve kodlarda kullanılabilirler ([resources bölümünde bundan daha ayrıntılı bir şekilde bahsedeceğiz](/chapters/resource.md)), Onları erişilemeyen yerlere koymamız sorunlara yol açabilir ve onları kaybetmemizle sonuçlanabilir.

Bu yüzden erişelemeyen kodlar çok ciddi bir problemdir. Artık bunu netleştirdiğimize göre devam edebiliriz.


### Sonsuz `loop`

Move dilinde sonsuz loopları tanımlamanın bir yolu vardır. Koşulsuzlardır ve siz onları durmaya zorlayana kadar çalışırlar. Maalesef compiler bir loopun sonsuz olup olmadığını saptama özelliğine (çoğu durumda) sahip değildir ve bu yüzden sizin kodu yayınlamanızı durdurma yetisine sahip değildir. Bu durumda kodun çalıştırılması tüm kaynaklarınızı tüketecektir (blockchain terimleriyle – gas). Bu sebeple kodunuzu düzgün bir şekilde test etmek veya daha güvenli olan koşullu `while` looplarını kullanma sorumluluğu tamamen size düşüyor.

Sonsuz looplar `loop` anahtar kelimesiyle tanımlanırlar.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;
        };

        // ERİŞİLEMEYEN KOD
        let _ = i;
    }
}
```

Fakat aşağıdakini yapmanız mümkün (yani compiler bunu yapmanıza izin verir):

```Move
script {
    fun main() {
        let i = 0;

        loop {
            if (i == 1) { // bunu hiç değiştirmedim
                break // bu deyim loopu bozuyor
            }
        };

        // burası aslında erişilemez
        0x1::Debug::print<u8>(&i);
    }
}
```

Compiler’ın bir loopun sonsuz olup olmadığını saptamasını sağlamak oldukça zorlayıcı bir durum. Bu yüzden şimdilik loop hatalarından kendinizi korumak sizin sorumluluğunuzda.

### Loopları `continue` ve `break` ile yönetmek

`continue` anahtar sözcüğü bir roundun atlama emri vermenize, `break` anahtar sözcüğüyse bir yinelemeyi durdurmanızı sağlar. İkisini de bahsettiğimiz iki loop türü için kullanabilirsiniz.

Örneğin `loop`a iki koşul koyalım. Eğer `i` çift sayıysa `continue` kullanarak okuma işleminin bir sonraki yinelemeye atlamasını ve `continue` çağrısının kapsadığı kodu çalıştırmamasını sağlar.

Eğer `break` kullanırsak yinelemeyi durdururuz ve döngüden çıkarız.

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i / 2 == 0) continue;
            if (i == 5) break;

            // burada bir şeyler yaptığımızı varsayalım
         };

        0x1::Debug::print<u8>(&i);
    }
}
```

Noktalı virgüllere gelirsek, eğer `break` ya da `continue` bir bloktaki son anahtar kelimeyse onların ardından noktalı virgül koymamalısınız çünkü bu onlardan sonra olan kodların çalıştırılmasını önler. Aşağıdaki örneğe bakalım:

```Move
script {
    fun main() {
        let i = 0;

        loop {
            i = i + 1;

            if (i == 5) {
                break; // böyle yaparsak hata verir, doğrusu `break` noktalı virgül olmadan kullanmak
                       // Error: Unreachable code
            };

            // continue için de aynısı geçerli: asla noktalı virgül koymayın;
            if (true) {
                continue
            };

            // fakat noktalı virgülü aşağıdaki gibi kullanabilirsiniz çünkü continue ve break burada basit ifade, 
            // bu yüzden zaten “kendi kapsamlarını sonlandırıyorlar” 
            if (true) continue;
            if (i == 5) break;
        }
    }
}
```

### Koşullu `abort` (Durdurma)

Koşulların sağlanmadığı bazı durumlarda bir hareketin (transaction) çalıştırmasını durdurmanız gerekebilir. Bunu yapmamızı sağlayan anahtar sözcük `abort`tur.

```Move
script {
    fun main(a: u8) {

        if (a != 10) {
            abort 0;
        }

        // buradaki kod a != 10 ise çalıştırılmayacak
        // transaction durduruldu
    }
}
```

`abort` anahtar sözcüğü bir kodun çalışmasını *durdurmanızı* ve hemen sonrasında bir hata kodu verilmesini sağlar.

### Yerleşik `assert` fonksiyonunun kullanımı

Move dilinde yerleşik olarak bulunan `assert! (<bool ifadesi>, <kod>)` metodu `abort` ve `koşulu` birleştirir ve kodun her yerinde kullanılabilir:

```Move
script {

    fun main(a: u8) {
        assert!(a == 10, 0);

        // buradaki kod (a == 10) ise çalıştırılacak
    }
}
```

`assert()` bir koşul sağlanmadığında kodun çalıştırılmasını durdurur, koşul karşılanıyorsa da işlevde bulunmaz.
