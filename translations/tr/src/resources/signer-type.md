# Göndericinin Signer Olması

Kaynakların nasıl kullanılacağına geçmeden önce, `signer` tipinin ne olduğunu ve bu tipin neden var olduğunu bilmemiz gerekir.

> Signer, transaction göndericisinin adresini tutan yerel, kopyalanamaz (kaynak benzeri) bir tiptir.

Signer tipi gönderici yetkisini temsil eder. Diğer bir deyişle- signer kullanmak, gönderenin adresine ve kaynaklarına erişim anlamına gelir. İmzalarla veya kelimenin tam anlamıyla imzalama ile doğrudan bir ilgisi yoktur, Move VM açısından sadece göndericiyi temsil eder.

> Signer türünün yalnızca bir yeteneği vardır – Atmak.

<!-- Important! `0x1::Transaction::sender()` may soon be deprecated [as mentioned here](https://community.libra.org/t/signer-type-and-move-to/2894). So in the future using `signer` will be the only way to get sender's address. -->

### Scriptlerde Signer

Signer yerleşik bir tip olduğundan, yaratılması gerekir. `Vektörden` farklı olarak, doğrudan kodda oluşturulamaz, ancak bir komut dosyası ile oluşturulabilir:

```Move
script {
    // signer, sahibi olan bir değerdir
    fun main(account: signer) {
        let _ = account;
    }
}
```

Signer bağımsız değişkeni, komut dosyalarınıza VM tarafından otomatik olarak eklenir; bu, komut dosyasına manuel olarak aktarmanın bir yolu olmadığı ve/veya buna gerek olmadığı anlamına gelir. Bir şey daha - bu her zaman bir referanstır. Standart kitaplığın (Diem için- [DiemAccount](https://github.com/diem/diem/blob/master/language/stdlib/modules/DiemAccount.move)) signerın gerçek değerine erişimi olmasına rağmen, bu değeri kullanan fonksiyonlar özeldir ve signer değerini başka hiçbir yerde kullanmanın veya iletmenin bir yolu yoktur.

> Şu anda, signer türü tutan değişkenin kurallı adı _account_’tur.

### Standart kütüphanede signer modülü

Yerleşik türler yerel işlevler gerektirir ve signer türü için `0x1::Signer`'dır. Bu modül oldukça basittir ([diem'deki orijinal modül](https://github.com/diem/diem/blob/master/language/diem-framework/modules/Signer.move)):

````Move
module Signer {
    // signer adresini ödünç alır
    // signer’ı bir adrese kaynak yapısı wrapleyen
    // bir unsur olarak düşünebilirsiniz
    // ```
    // kaynak yapısı Signer’ı { addr: address }
    // ```
    // `borrow_address` bu iç bölgeyi ödünç alır
    native public fun borrow_address(s: &signer): &address;

    // signer adresini kopyalar
    public fun address_of(s: &signer): address {
        *borrow_address(s)
    }
}
````

Gördüğünüz gibi, biri yerel diğeri dereference operatörü ile adresi kopyaladığı için daha kullanışlı olan 2 yöntem var.

Bu modülün kullanımı da aynı derecede basittir:

```Move
script {
    fun main(account: signer) {
        let _ : address = 0x1::Signer::address_of(&account);
    }
}
```

### Modüllerde signer

```Move
module M {
    use 0x1::Signer;

    // proxyleyelim Signer::address_of
    public fun get_address(account: signer): address {
        Signer::address_of(&account)
    }
}
```

> `&signer` tipini bağımsız değişken olarak kullanan yöntemler, gönderenin adresini kullandıklarını açıkça gösterir.

Bu tipin asıl nedenlerinden biri, hangi yöntemlerin gönderen yetkisi gerektirdiğini ve hangilerinin gerektirmediğini göstermekti. Bu nedenle yöntem, kullanıcıyı kaynaklarına yetkisiz erişim için kandıramaz.

<!--  MAYBE ADD HISTORY OF THIS TYPE? -->

### Daha fazla bilgi için

- [Signer üzerine yazılan bir Diem topluluğu paylaşımı](https://community.diem.com/t/signer-type-and-move-to/2894)
- [Diem veri havuzu](https://github.com/diem/diem/issues/3679)
- [Diem veri havuzunda PR](https://github.com/diem/diem/pull/3819)
