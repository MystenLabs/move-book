# İlkel Veri Tipleri

Move’un yapısında yerleşik olarak birkaç ilkel veri tipi mevcuttur. Bu ilkel veri tipleri (u8, u64, u128), `boolean` ve `address` gibi sayılar, adresler ve boolean değerleri temsil etmemizi sağlarlar.

Move dilinde string veri tipi veya floating point sayıları bulunmaz.

## Integer Türleri

Integer’lar `u8`, `u64` ve `u128` değerleriyle temsil edilirler. Move dilinde mümkün olan tam sayı formülleri aşağıdaki gibidir:

```Move
script {
    fun main() {
        // boş değişkeni tanımla, daha sonra değeri belirle
        let a: u8;
        a = 10;

        // değişkeni tanımla, tipi belirle
        let a: u64 = 10;

        // ve sonunda basit bir değer atanmasına ulaşırız
        let a = 10;

        // tanımlanmış bir değer tipiyle basit bir atama
        let a = 10u128;

        // fonksiyon çağrısı (function call) veya fonksiyon ifadelerinde (function expression) integerları sabit değer olarak kullanabilirsiniz 
        if (a < 10) {};

        // ya da tipi belirterek yapabilirsiniz
        if (a < 10u8) {}; // genellikle tipi belirtmeniz gerekmez
    }
}
```

###  `as` Operatörü

Değer karşılaştırması yapmanız gerektiğinde veya fonksiyon argümanınız için farklı boyutlarda integerlar gerekiyorsa `as` operatörünü kullanarak integer değişkeninizi farklı bir boyuta dönüştürebilirsiniz:

```Move
script {
    fun main() {
        let a: u8 = 10;
        let b: u64 = 100;

        // sadece aynı boyuttaki integarları karşılaştırabiliriz
        if (a == (b as u8)) abort 11;
        if ((a as u64) == b) abort 11;
    }
}
```

## Boolean

Boolean tipi zaten bildiğiniz boolean’in aynısıdır. İki sabit değer vardır: `false` ve `true`. Bunların ikisi de tek bir anlama gelebilir: `bool` veri tipinin bir değeri.

```Move
script {
    fun main() {
        // tüm uygulama yolları aşşağıda yer almaktadır
        let b : bool; b = true;
        let b : bool = true;
        let b = true;
        let b = false; // false değeri için örnek
    }
}
```

## Address

Address, blockchainde gönderenin ya da cüzdanın tanımlayıcısıdır. Adres tipi gerektiren en basit işlemler coin gönderimi ve modüllerin içeri aktarımıdır.

```Move
script {
    fun main() {
        let addr: address; // type identifier

        // bu kitapta {{sender}} gösterimini kullanacağım
        // örneklerdeki `{{sender}}` gösterimini sanal makine adresiyle değiştirmeyi unutmayın !!! 
        addr = {{sender}};

        // Diem’in Move Sanal Makinesi (Move VM) ve Starcoin’de  – HEX’te 16-bit adres kullanılır 
        addr = 0x...;

        // dfinance’in DVM’inde - "wallet1" önekiyle bech32 kodlu adres kullanılır
        addr = wallet1....;
    }
}
```
