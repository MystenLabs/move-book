# Kaynak Okuyup Değiştirme

Kaynağı okumak ve değiştirmek için Move'un iki yerleşik işlevi daha vardır. İsimleri hedeflerine mükemmel şekilde uyuyor: `borrow_global` ve `borrow_global_mut`.

## `Borrow_global` ile Değiştirilemeyen borrow

[Sahiplik ve referanslar bölümünde](/advanced-topics/ownership-and-references.md) değiştirilebilir (&mut) ve değişmez referansları öğrenmiş olmalısınız. Bu bilgiyi uygulamaya koymanın zamanı geldi!

```Move
// modules/Collection.move
module Collection {

    // buraya bir gereksinim koyduk!
    use 0x1::Signer;
    use 0x1::Vector;

    struct Item has store, drop {}
    struct Collection has key, store {
        items: vector<Item>
    }

    // ... atlandı ...

    /// koleksiyon boyutunu al
    /// acquires anahtar sözcüğüne dikkat!
    public fun size(account: &signer): u64 acquires Collection {
        let owner = Signer::address_of(account);
        let collection = borrow_global<Collection>(owner);

        Vector::length(&collection.items)
    }
}
```

Burada çok şey yaşandı. İlk olarak, yöntem imzasıyla ilgilenelim. Genel işlev `borrow_global<T>`, T kaynağına değişmez bir referans verir. İmzası şöyledir:

```Move

native fun borrow_global<T: key>(addr: address): &T;

```

Bu fonksiyonu kullanarak, belirli bir adreste depolanan kaynağa okuma erişimi sağlarız. Bu, modülün kaynaklarından herhangi birini herhangi bir adreste okuma yeteneğine sahip olduğu anlamına gelir (bu fonksiyon uygulanmışsa).

Başka bir sonuç: borrow kontrolü nedeniyle, kaynağa veya içeriğine referansı iade edemezsiniz (çünkü kaynağa yapılan orijinal referans, kapsam sonunda ölecektir).

> Kaynak kopyalanamaz bir tür olduğundan, üzerinde '\*' referans operatörünü kullanmak mümkün değildir.

### Acquires (elde etme) anahtar kelimesi

Anlatmam gereken bir detay daha var. Fonksiyonun dönüş değerinin ardından koyulan `acquires` anahtar sözcüğü. Bu anahtar kelime, bir fonksiyon tarafından elde edilen tüm kaynakları _belirtme_ işlevi görür. Elde edilen tüm kaynakları belirtmelisiniz. Yuvalanmış fonksiyon çağrısı kaynak elde ediyorsa bile bu kaynağın üst kapsama ait (parent scope) acquires listesinde belirtlilmiş olması gerekmektedir.

`acquires` ile kullanılan fonksiyonların syntax’ı aşağıdaki gibidir:

```Move

fun <name>(<args...>): <ret_type> acquires T, T1 ... {

```

## `Borrow_global_mut` ile susturulabilen borrow

Kaynağa değiştirilebilir referans almak için, `borrow_global`'inize `_mut` ekleyin ve hepsi bu. Koleksiyona yeni (şu anda boş) öğe eklemek için bir işlev ekleyelim.

```Move
module Collection {

    // ... atlandı ...

    public fun add_item(account: &signer) acquires T {
        let collection = borrow_global_mut<T>(Signer::address_of(account));

        Vector::push_back(&mut collection.items, Item {});
    }
}
```

Kaynağa değiştirilebilir referans, içeriğine değiştirilebilir referanslar oluşturmaya izin verir. Bu nedenle, bu örnekte iç vektör `öğelerini` değiştirebiliyoruz.

`Borrow_global_mut` için imza:

```Move

native fun borrow_global_mut<T: key>(addr: address): &mut T;

```
