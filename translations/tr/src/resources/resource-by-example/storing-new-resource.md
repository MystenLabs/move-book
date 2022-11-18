# Kaynak Yaratma ve Taşıma

Öncelikle modülümüzü oluşturalım:

```Move
// modules/Collection.move
module Collection {


    struct Item has store {
        // özelliklerini sonra düşünürüz
    }

    struct Collection has key {
        items: vector<Item>
    }
}
```

> Modülden sonra bir modülün ana kaynağını çağırmak için bir kural vardır (örneğin, Collection::Collection). Bunu takip ederseniz, modüllerinizin başkaları tarafından okunması ve kullanılması kolay olacaktır.

### Oluşturma ve Taşıma

`Item` tipi vektörü tutacak olan _Key_ yeteneği ile bir `Collection` yapısı tanımladık. Şimdi yeni koleksiyona nasıl başlayacağımızı ve _bir kaynağın hesap altında nasıl saklanacağını_ görelim. Bu uygulamada depolanan kaynak, gönderenin adresi altında sonsuza kadar yaşayacaktır. Hiç kimse bu kaynağı değiştiremez veya sahibinden alamaz

```Move
// modules/Collection.move
module Collection {

    use 0x1::Vector;

    struct Item has store {}

    struct Collection has key {
        items: vector<Item>
    }

    /// &signer tipinin geçirildiğine dikkat edin!
    public fun start_collection(account: &signer) {
        move_to<Collection>(account, Collection {
            items: Vector::empty<Collection>()
        })
    }
}
```

[Signer'ı](/resources/signer-type.md) hatırlıyor musunuz? Şimdi nasıl çalıştığını görüyorsunuz! Kaynağı hesaba _taşımak_ için, ilk argüman olarak `signer`ı ve ikinci olarak `Collection`u alan yerleşik _move_to_ fonksiyonuna sahipsiniz. `move_to` fonksiyonunun imzası şu şekilde temsil edilebilir:

```Move

native fun move_to<T: key>(account: &signer, value: T);

```

Bu iki sonuca yol açar:

1. Yalnızca hesabınızın altına bir kaynak koyabilirsiniz. Başka bir hesabın `signer` değerine erişiminiz olamaz, dolayısıyla oraya kaynak koyamazsınız.
2. Tek bir adres altında yalnızca tek bir tür kaynak saklanabilir. Aynı işlemi iki kez yapmak, mevcut kaynağın atılmasına yol açacaktır ve bu olmamalıdır (coinlerinizi depoladığınızı ve yanlış bir işlemle boş bakiyeyi iterek tüm birikimlerinizi attığınızı hayal edin!). Varolan kaynağı oluşturmaya yönelik ikinci deneme, hatayla başarısız olur.

### Adreste Varlığı Kontrol Etme

Belirtilen adreste kaynağın olup olmadığını kontrol etmek için `exists` fonksiyonu vardır, imza da buna benzer.

```Move

native fun exists<T: key>(addr: address): bool;

```

Jenerik kullanarak bu fonksiyon, tipten bağımsız hale getirilir ve adreste bulunup bulunmadığını kontrol etmek için herhangi bir kaynak türünü kullanabilirsiniz. Aslında, verilen adreste kaynağın olup olmadığını herkes kontrol edebilir. Ancak varlığını kontrol etmek, depolanan değere erişmiyor!

Kullanıcının zaten koleksiyonu olup olmadığını kontrol etmek için bir fonksiyon yazalım:

```Move
// modules/Collection.move
module Collection {

    struct Item has store, drop {}

    struct Collection has store, key {
        items: Item
    }

    // ... atlandı ...

    /// bu fonksiyon kaynağın adreste olup olmadığını kontrol edecek
    public fun exists_at(at: address): bool {
        exists<Collection>(at)
    }
}
```

---

Artık bir kaynağı nasıl oluşturacağınızı, onu gönderene nasıl taşıyacağınızı ve kaynağın zaten var olup olmadığını nasıl kontrol edeceğinizi biliyorsunuz. Bu kaynağı okumayı ve değiştirmeyi öğrenmenin zamanı geldi!
