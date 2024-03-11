# Yapılar (Structures)

Yapı, karmaşık veri içeren (veya hiç veri içermeyen) özgün bir tiptir. Anahtarın, niteliğin ismi; değerin ise depolanan şey olduğu basit bir anahtar-değer deposu olarak açıklanabilir. `struct` anahtar kelimesi ile tanımlanır. Yapılara 4’e kadar yetenek atanabilir ve bunlar tip tanımıyla belirtilir. 

> Move’da özel tip oluşturmanın tek yolu “struct” (yapı) kullanmaktır.

## Tanım (Definition)

Struct tanımına sadece bir modül içerisinde izin verilir. `struct` anahtar kelimesiyle başlar, yapı alanlarının tanımlandığı isim ve küme parantezleri koyulur: 

```Move
struct NAME {
    FIELD1: TYPE1,
    FIELD2: TYPE2,
    ...
}
```

Aşağıdaki yapı örneklerini inceleyin:

```Move
module M {

    // yapı alansız olabilir
    // ama farklı bir tip olur
    struct Empty {}

    struct MyStruct {
        field1: address,
        field2: bool,
        field3: Empty
    }

    struct Example {
        field1: u8,
        field2: address,
        field3: u64,
        field4: bool,
        field5: bool,

        // başka bir yapıyı tip olarak kullanabilirsiniz
        field6: MyStruct
    }
}
```
*Bir yapıdaki en fazla alan sayısı 65535’dir*.

Her tanımlanmış yapı farklı bir tip olur. Bu tipe içinde bulunduğu modülünden ulaşabilirsiniz (aynı modül fonksiyonlarına ulşatığınız gibi):
```
M::MyStruct;
// or
M::Example;
```

### Özyineli tanım (Recursive definition)

Hiç olmadığı kadar kısa:

> Özyineli yapı tanımı imkansızdır.

Başka bir yapıyı tip olarak kullanabilirsiniz ama aynı yapıyı tekrarlı bir şekilde kullanamazsınız. Move derleyicisi kendini tekrar eden tanımları kontrol eder ve sizin böyle bir kod yazmanıza izin vermez:

```Move
module M {
    struct MyStruct {

        // DERLENMEZ
        field: MyStruct
    }
}
```

## Yeni bir yapı oluşturmak

Bu tipi kullanmak için *instance*ını oluşturmanız lazım.

>Yeni instancelar yalnızca tanımlandıkları modülün içinde oluşturulabilirler.

Yeni bir instance oluşturmak için tanımı kullanırız ama tipin kendisini geçirmek yerine bu tiplerin değerlerini geçiririz:

```Move
module Country {
    struct Country {
        id: u8,
        population: u64
    }

    // Bu fonksiyonda Country dönüş tipi!
    public fun new_country(c_id: u8, c_population: u64): Country {
        // yapı oluşturmak bir ifadedir (expression).
        let country = Country {
            id: c_id,
            population: c_population
        };

        country
    }
}
```

Move, aynı zamanda yapının alanıyla (ve tipiyle!) eşleşen değişken ismi geçirerek, yeni instanceları daha kısa yapmanıza olanak verir. Bu kuralı `new_country()`  metodumuzu kullanarak basitleştirebiliriz:

```Move
// ...
public fun new_country(id: u8, population: u64): Country {
    // id ve id: u8 alanı eşleşiyor
    // population ve population alanı eşleşiyor
    Country {
        id,
        population
    }

    // ya da sadece bir satırda: Country { id, population }
}
```

Boş (ve alansız) bir yapı oluşturmak için sadece süslü parantez kullanın:

```Move
public fun empty(): Empty {
    Empty {}
}
```

## Yapı alanlarına erişim

Yapıların alanlarına ulaşamasaydık neredeyse hiçbir işimize yaramazlardı (ama alansız yapılar oluşturmamız mümkün).

> Sadece modüller yapılarının alanlarına erişebilir. Alanlar modül dışındayken gizlidirler.

Yapı alanları sadece modüllerinin içerisindeyken görülür (açık) hale gelirler. Modülün dışında (farklı scriptte veya modülde) sadece bir tip olarak görülürler. Yapının alanlarına erişmeniz için “.” (nokta) göstermesini kullanın:

```Move
// ...
public fun get_country_population(country: Country): u64 {
    country.population // <struct>.<property>
}
```

Eğer bir yuvalanmış yapı tipi aynı modülde tanımlanmışsa, ona da benzer bir yol izleyerek ulaşabiliriz:

```Move
<struct>.<field>
// ve alan başka bir yapı olabilir, yani
<struct>.<field>.<nested_struct_field>...
```

## Yapıları yok etmek

Bir yapıyı *yok etmek* için `let <STRUCT DEF> = <STRUCT>` syntax’ını kullanın:

```Move
module Country {

    // ...

    // bu yapının değerlerini dışarı döndüreceğiz
    public fun destroy(country: Country): (u8, u64) {

        // değişkenler yapı alanlarına uymalı
        // tüm yapı alanları belirtilmeli
        let Country { id, population } = country;

        // yok etmeden sonra Country atılır
        // ama alanları şimdi değişken oldular
        // ve kullanılabilirler
        (id, population)
    }
}
```

Move’da kullanılmamış değişkenlere izin verilmediğini hatırlamalısınız ve bazen bir yapıyı, alanlarını kullanmadan yok etmeniz gerekebilir. Kullanılmamış yapı alanları için `_`  (alttan tire) kullanın:

```Move
module Country {
    // ...

    public fun destroy(country: Country) {

        // böylece yapıyı yok edersiniz ve kullanılmamış değişken bırakmazsınız
        let Country { id: _, population: _ } = country;

        // ya da sadece bir id al ve “population” değişkenini başlatma
        // let Country { id, population: _ } = country;
    }
}
```

Yok etme işlemi şu an size önemsiz gelmiş olabilir fakat kaynaklara geldiğimizde çok önemli bir rolü olacak.

### Yapı alanları için alıcı fonksiyonlar (getter functions) kullanmak

Yapı alanlarını dışarıda okunabilir kılmak için, bu alanları okuyacak ve dönüş değeri olarak geçirecek metotlar uygulamanız lazım. Getter metodu genellikle yapı alanları gibi çağırılırlar fakat modülünüz birden fazla yapı tanımlıyorsa bu sorun yaratabilir.

```Move
module Country {

    struct Country {
        id: u8,
        population: u64
    }

    public fun new_country(id: u8, population: u64): Country {
        Country {
            id, population
        }
    }

    // metodları public yapmayı unutma!
    public fun id(country: &Country): u8 {
        country.id
    }

    // & işaretinin neden burada olduğunu ileride öğreneceksiniz
    public fun population(country: &Country): u64 {
        country.population
    }

    // ... fun destroy ... 
}
```

Getters oluşturarak modül kullanıcılarının yapımızın alanına erişmelerini sağladık:

```Move
script {
    use {{sender}}::Country as C;
    use 0x1::Debug;

    fun main() {
        // buradaki değişken C::Country tipinden
        let country = C::new_country(1, 10000000);

        Debug::print<u8>(
            &C::id(&country)
        ); // id yazdır

        Debug::print<u64>(
            &C::population(&country)
        );

        // fakat bu imkansız ve derleme hatasına sebep olacak
        // let id = country.id;
        // let population = country.population.

        C::destroy(country);
    }
}
```

---

Artık 'structure' özel tipini tanımlamayı biliyorsunuz fakat varsayılan ayarlara göre işlevsellikleri oldukça sınırlı. Bir sonraki kısımda, bu tipdeki değerleri manipüle etmenize ve kullanmanıza yarayan yetenekleri öğreneceksiniz
