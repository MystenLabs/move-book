# Giriş

> **Uyarı:** Bu sayfada bulunan içerik güncel değildir ve yeniden düzenlenmesi gerekmektedir. Move IDE için daha yeni bir sürüm yakın zamanda yayınlanacaktır. Şimdilik [move-cli](https://github.com/diem/move/tree/main/language/tools/move-cli) kullanmanızı öneriyorum.

---

Her derlenmiş dilde olduğu gibi Move uygulamalarını derlememiz (compile), çalıştırmamız (run) ve hata ayıklaması (debug) yapmamız için gereken birtakım araçlara ihtiyacımız vardır. Move, blockchainler için oluşturulduğu ve sadece blockchainler içerisinde kullanıldığı için kodları zincir dışında çalıştırmak pek de basit değildir. Her modülün bir ortama, hesap yönetimi özelliğine ve compile-publishing sistemine ihtiyacı vardır.

Move modüllerinin geliştirilmesini basitleştirmek adına Visual Studio Code için bir [Move IDE](https://github.com/damirka/vscode-move-ide) uzantısı oluşturdum. Bu uzantı ortamın gereksinimleriyle başa çıkmanızı kolaylaştıracaktır. Bu uzantıyı kullanmanızı şiddetle tavsiye ediyorum çünkü build ve run ortamlarını sizin için halledecektir ve bu sayede CLI ile uğraşmanıza gerek kalmadan Move dilini öğrenmeye odaklanmanızı sağlayacaktır. Bu uzantı aynı zamanda hata ayıklamanızı kolaylaştıran Move syntax highlighter ve yürütücü özelliklerine de sahiptir.

## Move IDE Kurulumu

Kurulum için aşağıdakilere ihtiyacınız vardır

1. VSCode (1.43.0 sürümü veya daha iyisi) - [buradan indirebilirsiniz;](https://code.visualstudio.com/download); zaten kuruluysa 2. adıma geçiniz;
2.	Move IDE – VSCode’u kurduktan sonra Move IDE’nin en güncel sürümünü indirmek için [bu linke tıklayınız.](https://marketplace.visualstudio.com/items?itemName=damirka.move-ide) .

### Kurulum Ortamı

Move IDE dizin yapınızı düzenlemeniz için size tek bir yol sunar. Projeniz için yeni bir dizin oluşturun ve VSCode ile açın. Ardından bu dizin yapısını kurun.

```
modules/   - modüllerimiz için kullanacağımız dizin
scripts/   - transaction scriptleri için kullanacağımız dizin
out/       - derlediğimiz kaynaklar (source) bu dizinde toplanacaktır

```

Ayrıca `.mvconfig.json` adlı bir dosya yaratmanız gerekmektedir. Bu dosya çalışma ortamınızı yapılandıracaktır. Aşağıda `libra` için bir örnek bulunmaktadır:

```json
{
    "network": "libra",
    "sender": "0x1"
}
```

Alternatif olarak ağınız için `dfinance` de kullanabilirsiniz:

```json
{
    "network": "dfinance",
    "sender": "0x1"
}
```

> dfinance bech32 ‘wallet1…’ adreslerini, libra da 16-byte ‘0x…’ adreslerini kullanmaktadır. Yerel olarak çalıştırmak ve denemek istiyorsanız basit ve kısa olan 0x1 adresi yeterli olacaktır. Fakat gerçek blockchainlerle testnet ya da üretim ortamlarında çalışacaksanız seçtiğiniz network için uygun olan adresi kullanmanız gerekmektedir.

## İlk Move uygulamanız

Move IDE kodlarınızı test ortamlarında çalıştırmanıza olanak sunar. Gelin `gimme_five()` fonksiyonunu VSCode’da çalıştırarak nasıl yapıldığına bir göz atalım.

### Module oluşturmak

Projenizin `modules/` dizininde `hello_world.move` adlı bir dosya oluşturun.
```Move
// modules/hello_world.move
address 0x1 {
module HelloWorld {
    public fun gimme_five(): u8 {
        5
    }
}
}
```

> 0x1 yerine kendi adresinizi kullanmaya karar verdiyseniz bu ve bunun ardından göreceğiniz dosyada da 0x1 yazan kısmı doğru adresle değiştirmeyi unutmayın.

### Script Yazmak

Daha sonra `scripts/` dizininin içinde bir script oluşturun. Adını `me.move` koyalım:
```Move
// scripts/run_hello.move
script {
    use 0x1::HelloWorld;
    use 0x1::Debug;

    fun main() {
        let five = HelloWorld::gimme_five();

        Debug::print<u8>(&five);
    }
}
```

Sonra kodunuzu açık bırakarak aşağıdaki adımları takip edin:
1. `⌘+Shift+P` (on Mac) or `Ctrl+Shift+P` (on Linux/Windows) tuşlarına basarak VSCode'un command palette özelliğini açın.
2. `>Move: Run Script` yazın ve Enter'a basın ya da doğru seçeneği gördüğünüzde üzerine tıklayın.

İşte bu kadar! Debug kısmında printlenen değerin ‘5’ olduğu bir log mesajı olan yürütme sonucununu görüyor olmanız lazım. Karşınıza çıkan pencere bu değilse bu kısmı bir daha gözden geçirin.

Dizin yapınızın aşağıdaki gibi gözükmesi gerekmektedir:

```
modules/
  hello_world.move
scripts/
  run_hello.move
out/
.mvconfig.json
```

> Modüllerinizi koyduğunuz ‘modules’ dizinine istediğiniz kadar modül koyabilirsiniz. Modüllerinizin hepsine script’inizde erişebileceksiniz. Her biri. mvconfig.json dosyasında belirttiğiniz adreslerde bulunacaktır.
