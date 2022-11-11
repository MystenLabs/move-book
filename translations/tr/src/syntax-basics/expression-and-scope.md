# İfade ve Kapsam

Programlama dillerinde ifade, bir kodu bir değere dönüştüren unsurdur. Geri döndürülen değer içeren tüm fonksiyon çağrıları ifadedir. Bu değer bir integer literal (tamsayı değişmezi) - ya da boolean veya adres -  olabilir çünkü integer tipinin de belli bir değeri vardır.

> İfadeler noktalı virgül ‘;’ ile ayrılmalıdırlar.*

*\* Noktalı virgül koyduğunuzda kodun içerisinde `; (empty_expression)` yani boş ifade oluşturmuş olursunuz. Noktalı virgülün ardından bir ifade belirtirseniz o ifade, oluşturulan boş ifadenin yerine geçer.


### Boş İfade

Boş ifadeleri büyük ihtimalle doğrudan kullanmayacaksınız fakat Move dilinde (Rust diline benzer bir şekilde) boş ifadeler, içi boş olan parantezlerle belirtilir:

```Move
script {
    fun empty() {
        () // bu bir boş ifadedir
    }
}
```

Boş ifadeler VM tarafından otomatik olarak koyulduğu için atlanılabilir niteliktedirler.

### Literal (Değişmez) İfade

Aşağıdaki koda bakın. Her satır, noktalı virgül ile biten bir ifade içeriyor. Son satırdaysa noktalı virgüllerle ayrılmış üç farklı ifade var.

```Move
script {
    fun main() {
        10;
        10 + 5;
        true;
        true != false;
        0x1;
        1; 2; 3
    }
}
```

Güzel. Böylece en basit ifadeleri öğrenmiş oldunuz. Ama ifadeler ne işimize yarıyor ve onları nasıl kullanıyoruz? İşte şimdi `let` anahtar sözcüğünü öğrenme vaktimiz geldi.

### Değişkenler ve `let` anahtar sözcüğü

Bir değişkenin içerisinde bir ifade değeri depolamak istiyorsak (bir yere geçirmek için) `let` sözcüğünü kullanabiliriz (daha önce [primitives bölümünde](/syntax-basics/primitives.md) karşınıza çıktı). Bu sözcük boş (tanımlanmamış) ya da bir değer içeren ifade değişkeni oluşturur.


```Move
script {
    fun main() {
        let a;
        let b = true;
        let c = 10;
        let d = 0x1;
        a = c;
    }
}
```

`let` anahtar sözcüğü, mevcut kapsam içerisinde yeni bir değişken oluşturur ve geliştiricinin isteğine göre bu değişkeni bir değer kullanarak başlatabilir. Bu ifade için gereken syntax: `let <VARIABLE> : <TYPE>;` ya da `let <VARIABLE> = <EXPRESSION>` şeklinde yazılır.

Bir değişken yaratıp başlattıktan sonra bir değişken ismi kullanarak onun değerine değiştirme (modify) yapabilir ya da erişim (access) sağlayabilirsiniz. Yukarıdaki örnekte `a` değişkeni fonksiyonun sonunda başlatıldı ve ardından ona `c` değeri atandı.

Eşittir işareti `=` bir atama (assignment) operatörüdür. Sağ taraftaki ifadeyi sol taraftaki değişkene atar. Örneğin: `a = 10` – `a` değişkenine `10` integer değerini atamış olur.



### İnteger tipleri için kullanılan operatörler

Move dilinde integer değerlerini değiştirmek için çeşitli operatörler vardır. Bu operatörlerin listesi aşağıda verilmiştir:

| Operator | Op     | Types |                                 |
|----------|--------|-------|---------------------------------|
| +        | sum    | uint  | Sol taraf ve Sağ tarafı toplamak                 |
| -        | sub    | uint  | Sağ tarafı Sol taraftan çıkarmak           |
| /        | div    | uint  | Sol tarafı Sağ tarafa bölmek              |
| *        | mul    | uint  | Sol taraf ve Sağ tarafı çarpmak          |
| %        | mod    | uint  | Bölme kalanı (Sol bölü Sağ) |
| <<       | lshift | uint  | Sol bit shift (Soldan Sağa)       |
| >>       | rshift | uint  | Sağ bit shift (Soldan Sağa)      |
| &        | and    | uint  | Bitwise AND                     |
| ^        | xor    | uint  | Bitwise XOR                     |
| \|       | or     | uint  | Bitwise OR                      |

*uint: u8, u64, u128.*

<!--

### Comparison and boolean operators

To build a bool condition by comparing values you have these operators. All of them return `bool` value and require LHS and RHS types match.

| Operator | Op     | Types |                                |
|----------|--------|-------|--------------------------------|
| ==       | equal  | any   | Check if LHS equals RHS        |
|----------|--------|-------|--------------------------------|
| =<       | equal  | any   | Check if LHS equals RHS        |
|----------|--------|-------|--------------------------------|

-->

### Kullanılmayan olarak işaretlemek için alt tire “_” kullanımı

Move dilinde her değişken kullanılmalıdır yoksa kod derlenemez. Bu yüzden bir değişkeni başlattıktan sonra onun öylece bırakamazsınız. Fakat alt tire `_` kullanarak bir değişkeni kasıtlı olarak kullanılmıyor olarak işaretleyebilirsiniz.

Bu kodu derlemek isterseniz hata verir:

```Move
script {
    fun main() {
        let a = 1;
    }
}
```

Hata mesajı:

```

    ┌── /scripts/script.move:3:13 ───
    │
 33 │         let a = 1;
    │             ^ Unused assignment or binding for local 'a'. Consider removing or replacing it with '_'
    │
```

Compiler mesajı oldukça net ve yapmamız gereken şey belli. Değişken yerine alt tire koyacağız.

```Move
script {
    fun main() {
        let _ = 1;
    }
}
```

### Gölgeleme (Shadowing)

Move bir değişkeni iki kere tanımlamanıza izin verir fakat bir adet kısıtlaması vardır. Değişkenin kesinlikle kullanılması gerekir. Yukarıdaki örnekte sadece ikinci `a` kullanılmış. `let a = 1` olan diğeriyse kullanılmamakta çünkü sonraki satırda `a` yeniden tanımlanmış ve ilk kullanıldığı tanımı devre dışı hale getirmiş.


```Move
script {
    fun main() {
        let a = 1;
        let a = 2;
        let _ = a;
    }
}
```

İlk değişkeni kullanarak da çalıştırabiliriz:

```Move
script {
    fun main() {
        let a = 1;
        let a = a + 2; // burada let kullanmamıza gerek yoktu
        let _ = a;
    }
}
```

## Block ifade

Bloklar birer ifadedir ve küme parantezleri `{}` kullanarak işaretlenirler. Bir blok farklı ifadeler (hatta farklı bloklar( içerebilir. Fonksiyon gövdesi de - gördüğünüz üzere o da küme parantezleriyle işaretlenmiş - bir bakıma blok sayılır fakat birtakım kısıtlamaları vardır.


```Move
script {
    fun block() {
        { };
        { { }; };
        true;
        {
            true;

            { 10; };
        };
        { { { 10; }; }; };
    }
}
```

### Kapsamları anlamak

Kapsam ([Wikipedia'ye göre](https://en.wikipedia.org/wiki/Scope_(computer_science))) bir bağlanmanın (binding) geçerli olduğu bir kod bölümüne verilen addır. Bir diğer deyişle değişkenler içeren kod parçasıdır. Move dilinde kapsam, küme parantezleriyle çevrelenmiş bir kod bloku, yani bir bloktur.

Yani blok kelimesini tanımlarken aynı zamanda kapsamı tanımlamış oluruz.


```Move
script {
    fun scope_sample() {
        // bu bir fonksiyon kapsamıdır
        {
            // this is a block scope inside function scope
            {
                // bu da kapsam içerisinde bulunan bir kapsamdır
                // fonksiyon kapsamlarının içerisinde vs.
            };
        };

        {
            // bu bir fonksiyon kapsamının içinde bulunan bir bloktur
        };
    }
}
```

Örnekteki yorumlarda gördüğünüz gibi kapsamlar, bloklar ya da fonksiyonlarla tanımlanırlar. Yuvalanabilirler ve tanımlayabileceğiniz kapsam sayısının bir limiti yoktur.

### Değişken ömrü ve görünülebilirliği

let anahtar sözcüğünün bir değişken yarattığını biliyoruz. Ancak tanımlanmış değişkenlerin sadece tanımlandıkları kapsam içerisinde (yani yuvalandıkları kapsam içerisinde) canlı olduklarını büyük ihtimalle bilmiyordunuz. Basitleştirmem gerekirse: Değişkenler sadece kapsamları içindeyken canlı kalırlar ve kapsamları bittiği anda ölürler.

```Move
script {
    fun let_scope_sample() {
        let a = 1; // A değişkenini fonksiyon kapsamı içerisinde tanımladık

        {
            let b = 2; // B değişkeni blok kapsamı içerisinde

            {
                // A ve B değişkenleri bunların içerisindeyken erişilebilir durumdalar
                // yuvalanmış kapsamlar
                let c = a + b;

            }; // C burada ölüyor

            // bu satırı artık yazamayız
            // let d = c + b;
            // çünkü C kapsamı bitince öldü

            // ama farklı bir C tanımlayabiliriz
            let c = b - 1;

        }; // C değişkeni ve C ölür

        // bu imkansızdır
        // let d = b + c;

        // fakat istediğimiz değişkeni tanımlayabiliriz
        // isimler özel olarak ayrılmadı
        let b = a + 1;
        let c = b + 1;

    } // fonksiyon kapsamı sona erdi – a, b ve c bırakıldı ve artık erişilemez haldeler
}
```

> Değişkenler sadece tanımlandıkları kapsamlar (ya da bloklar) içerisinde canlı kalırlar. Kapsam bittiği anda değişken de ölmüş olur.

### Blok dönüş değerleri

Önceki bölümde blokların bir ifade olduğundan bahsettik fakat bunun sebebini açıklamadık ve blokların dönüş değerlerinin ne olduklarını tam olarak açıklamadık. 

> Blok bir değer döndürebilir. Ardından noktalı virgül gelmiyorsa bu değer bloktaki son ifadenin değeridir.

Biraz karmaşık gelmiş olabilir. Bu yüzden size birkaç örnek veriyorum:

```Move
script {
    fun block_ret_sample() {

        // blok bir ifade olduğu için değerini
        // let kullanarak bir değişkene atayabiliriz
        let a = {

            let c = 10;

            c * 1000  // noktalı virgül yok!!
        }; // kapsam sona erdi, a değişkeni 10000 değerini aldı

        let b = {
            a * 1000  // noktalı virgül yok!
        };

        // b değişkeni 10000000 değerini aldı

        {
            10; // işte burada noktalı virgül var
        }; // bu blok bir değer döndürmez

        let _ = a + b; // hem a hem b değerlerini bloktan alırlar
    }
}
```

> Kapsamdaki son ifade, (noktalı virgül olmayan) kapsamın döndürülen değeridir.

### Özet

Bu bölümün ana fikirlerini sınıflandıralım.

1. 	Her ifade, blokun dönüş değeri olmadığı sürece noktalı virgülle bitmelidir;
2. `let` anahtar sözcüğü bir değer ya da sağ taraf ifadesi barındıran bir değişken oluşturur ve bu değişkenler içinde tanımlandıkları kapsamları sonlanana kadar canlı kalırlar.
3. Blok, bir değer verme veya vermeme ihtimali olan bir ifadedir.

Yürütme akışının nasıl kontrol edileceği ve mantık anahtarları için blokların nasıl kullanılacağını sonraki sayfada işleyeceğiz.

### Daha fazla bilgi için

- [Boş ifadeler ve noktalı virgül üzerine yazılan Diem topluluğu paylaşımı](https://community.diem.com/t/odd-error-when-semi-is-put-after-break-or-continue/2868)
