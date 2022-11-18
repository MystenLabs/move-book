# Kaynak Nedir

Kaynak, Move Whitepaper'da açıklanan bir kavramdır. Başlangıçta kendi başına bir tür olarak uygulandı, ancak daha sonra yeteneklerin eklenmesiyle iki yetenekle değiştirildi: `Key` (Anahtar) ve `Store` (Depo). Kaynak, kopyalanamaz ve bırakılamaz olmak için dijital varlıkları depolamada mükemmel bir tiptir. Aynı zamanda depolanabilir ve hesaplar arasında aktarılabilir olmalıdır.

### Tanım

Kaynak, yalnızca `key` ve `store` yeteneklerine sahip bir yapıdır:

```Move
module M {
    struct T has key, store {
        field: u8
    }
}
```

### Key ve Store Becerileri

Key yeteneği, yapının bir depolama tanımlayıcısı olarak kullanılmasına izin verir. Diğer bir deyişle `key`, en üst düzeyde depolanabilme ve `store` olabilme yeteneğidir; mağaza ise keyin altında saklanabilme yeteneğidir. Bir sonraki bölümde nasıl çalıştığını göreceksiniz. Şimdilik, ilkel tilerin bile depolama yeteneğine sahip olduğunu unutmayın- bunlar depolanabilir, ancak yine de `key`leri yoktur ve üst düzey kapsayıcı olarak kullanılamazlar.

Store yeteneği, değerin depolanmasına izin verir. Bu kadar basit.

### Kaynak Kavramı

Başlangıçta kaynağın Move'da kendi türü vardı, ancak yeteneklerin eklenmesiyle, _key_ ve/veya _store_ yetenekleriyle uygulanabilen daha soyut bir kavram haline geldi. Yine de bir kaynak için açıklamayı inceleyelim:

1. Kaynaklar hesap altında saklanır - bu nedenle yalnızca hesaba atandığında _var_ _olur_; ve yalnızca bu hesap üzerinden _erişilebilir_;
2. Hesap, _bir tipten yalnızca bir_ kaynağı tutabilir ve bu kaynağın `anahtar` yeteneğe sahip olması gerekir;
3. Kaynak kopyalanamaz veya bırakılamaz, ancak saklanabilir.
4. Kaynak değeri _kullanılmalıdır_. Kaynak oluşturulduğunda veya hesaptan alındığında bırakılamaz ve depolanması veya yok edilmesi gerekir.

Bu kadar teori yeter, hadi harekete geçelim!
