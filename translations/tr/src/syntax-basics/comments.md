# Comments (Yorum)

Eğer kodunuzda bazı kısımlarda ek olarak açıklamalar koymak istiyorsanız *comment* kullanın. Comment, bir kodda çalıştırılmayan bloklar ya da satırlara verilen addır. Kodun belli kısımlarını açıklamak amacıyla yazılırlar.

### Yorum satırları

```Move
script {
    fun main() {
        // bu bir yorum satırıdır
    }
}
```

Yorum satırı yapmak için iki eğik çizgi "*//*" kullanabilirsiniz. Kural oldukça basit: "*//*" ardından **tüm satır** artık yorum sayılır. Bu yorum satırlarını geliştiriciler için kısa notlar bırakmak için ya da kodunuzda bir satırı devre dışı bırakmak için – bir diğer deyişle *comment out* yapmak için – kullanabilirsiniz.


```Move
script {
    // haydi gelin her yere birer not ekleyelim!
    fun main() {
        let a = 10;
        // let b = 10 bu satır commentlendiği için artık devre dışı yani çalıştırılmayacak
        let b = 5; // işte bu şekilde bir kodun ardından yorum ekleyebilirsiniz
        a + b // cevap 15, 10 değil!
    }
}
```

### Blok Yorum Satırı

Eğer her satırın tamamını comment yaparak devre dışı bırakmak istemiyorsanız ya da yorumunuz birden fazla satırdan oluşuyorsa blok comment kullanabilirsiniz. 

Blok yorum satırları, eğik çizgi ve yıldız işaretinden */\** başlar ve tam tersi olan *\*/ işaretine kadar devam eder. Blok yorum satırları, bir satıra kısıtlı olmadıkları için kodunuzda dilediğiniz herhangi bir yere not yazmanızı sağlarlar.


```Move
script {
    fun /*istediğiniz yere yorum yapabilirsiniz*/ main() {
        /* buraya
           şuraya
           her yere */ let a = 10;
        let b = /* buraya bile */ 10; /* burası da var */
        a + b
    }
    /* blok yorum satırları belli ifadeleri ya da tanımları devre dışı bırakmak için kullanabilirsiniz
    fun empty_commented_out() {

    }
    */
}
```

Elbette bu gerçek dışı bir örnek fakat blok yorum satırlarının gücünü görebiliyorsunuz. Dilediğiniz her yere yorum yapın!

<!-- ### Documentation comments -->
