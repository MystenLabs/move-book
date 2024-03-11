# Kaynakları Alıp Yok Etme

Bu bölümün son fonksiyonu, hesaptan kaynak alan `move_from` fonksiyonudur. `destroy` fonksiyonu, kaynakları hesaptan alıp farklı bir yere taşır ve tüm içeriğini yok eder.

```Move
// modules/Collection.move
module Collection {

    // ... atlandı ...

    public fun destroy(account: &signer) acquires Collection {

        // artık hesaba bağlı bir kaynak yok
        let collection = move_from<Collection>(Signer::address_of(account));

        // şimdi de varlık değeri (resource value) kullanmamız gerek – onu parçalayacağız
        // dikkatli bakın - Eşyaların droplanabilmesi gerekmektedir
        let Collection { items: _ } = collection;

        // tamamlandı. kaynak yok edildi
    }
}
```

Varlık değerinin (resource value) kullanılması şart. Yani kaynak bir hesaptan alındığında ya parçalanmalı ya da dönüş değeri olarak geçirilmeli. Ancak bu değeri dışarıya geçirmenizin ve scriptin içine koymanızın ardından seçenekleriniz oldukça kısıtlı hale geldiği aklınızda bulunsun. Bunun nedeni script bağlamı struct ya da resourceları başka bir yere geçirme dışında bir eylemde bulunmanıza izin vermez. Artık bunu da bildiğinize göre modüllerinizi uygun bir şekilde tasarlayın ve kullanıcıya döndürülen kaynakla ilgili seçenekler sunun.

En son imza:

```Move

native fun move_from<T: key>(addr: address): T;

```
