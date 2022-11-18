# Sabitler (Constants)

Move dilinde *module* ve *script-level* sabitlerini tanımlayabilirsiniz. Bu unsurlar tanımlandıktan sonra değiştirilemezler. Bu yüzden bir modülde sabit kalacak değerler için sabitleri kullanmalısınız. Örnek olarak bir rol tanımlayıcısı ya da bir price action için veya bir script için sabitleri kullanabilirsiniz.

Sabitler ilkel tiplerle (integer, bool ve adresler) ya da `vector` olarak tanımlanabilirler. İsimleri kullanılarak erişilirler ve içinde tanımlandıkları script ya da modüle yerel halde bulunurlar.

> Modülün dışından sabit değerlere erişmek imkansızdır

```Move
script {

    use 0x1::Debug;

    const RECEIVER : address = 0x999;

    fun main(account: &signer) {
        Debug::print<address>(&RECEIVER);

        // aynı zamanda bir değişkene atanabilirler

        let _ = RECEIVER;

        // fakat bu kod derleme hatası verir
        // RECEIVER = 0x800;
    }
}
```

Modüllerde:

```Move
module M {

    const MAX : u64 = 100;

    // fakat fonksiyon kullanarak bir sabit değeri dışarıya geçirebilirsiniz
    public fun get_max(): u64 {
        MAX
    }

    // ya da aşağıdakini kullanarak
    public fun is_max(num: u64): bool {
        num == MAX
    }
}
```

### Özet

Sabitler hakkında bilinmesi gereken önemli noktalar:

1.	Tanımlandıktan sonra değiştirilemezler
2.	Tanımlandıkları modül ya da scriptte yerel olarak bulunurlar ve onların dışarısında kullanılamazlar.
3.	Genellikle modül seviyesinde bulunan ve iş bağlamında işlevleri olan, değişmeyen değerleri tanımlamak için kullanılırlar.
4.	Sabitleri ifade olarak tanımlamak mümkündür (küme parantezleriyle) fakat bu ifadenin syntaxı oldukça sınırlıdır.


### Daha fazla bilgi için

- [Sabit syntax ile PR](https://github.com/diem/diem/pull/4653)
