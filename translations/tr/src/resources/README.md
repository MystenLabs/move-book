# Programlanabilir Kaynaklar

Bu kısımda Move’un anahtar özelliklerinden birini öğreneceğiz: Kaynaklar (Resources). Kaynaklar Move’u özel, güvenli ve güçlü yapan yegâne özelliktir.

Başlangıç için, diem geliştiricileri web sitesindeki önemli noktaları gözden geçirelim (Libra'yı Diem olarak yeniden adlandırdıktan sonra kaynak sayfa kaldırılmıştır):

> 1. Move'un temel özelliği, özel kaynak türlerini tanımlama yeteneğidir. Kaynak tipleri, zengin programlanabilirlik ile güvenli dijital varlıkları kodlamak için kullanılır.
> 2. Kaynaklar dilde sıradan değerlerdir. Veri yapıları olarak saklanabilir, prosedürlere argüman olarak iletilebilir, prosedürlerden döndürülebilir vb.

Kaynak özel bir yapı tipidir ve Move kodunda yeni (veya mevcut) kaynak tanımlamak ve oluşturmak mümkündür. Bu nedenle, dijital varlıkları diğer verileri (vektör veya yapı gibi) kullandığınız şekilde yönetebilirsiniz.

> 3. Move tip sistemi, kaynaklar için özel güvenlik garantileri sağlar. Move kaynakları asla çoğaltılamaz, yeniden kullanılamaz veya ıskarta edilemez. Bir kaynak tipi yalnızca tipi tanımlayan modül tarafından oluşturulabilir veya yok edilebilir. Bunun garantisi Move sanal makinesinin bytecode doğrulaması sayesinde istatistiksel olarak verilebilir. Move sanal makinesi, bytecode doğrulayıcısından geçmeyen kodu çalıştırmayı reddedecektir.

[Referanslar ve sahiplik bölümünde](/advanced-topics/ownership-and-references.md) Move'un kapsamları nasıl güvence altına aldığını ve değişkenin sahip kapsamını nasıl kontrol ettiğini gördünüz. Ayrıca [jenerikler bölümünde](/advanced-topics/understanding-generics.md), kopyalanabilir ve kopyalanamaz türleri ayırmak için tip eşleştirmenin özel bir yolu olduğunu öğrendiniz. Bu özelliklerin tümü, kaynak tipi için güvenlik sağlar.

> 4. Tüm Diem para birimleri, genel Diem::T türü kullanılarak uygulanır. Örneğin: LBR para birimi, `Diem::T<LBR::T>` olarak temsil edilir ve varsayımsal bir USD para birimi, `Diem::T<USD::T>` olarak temsil edilir. Diem::T'nin dilde özel bir statüsü yoktur; her Move kaynağı aynı korumalardan yararlanır.

Tıpkı Diem para birimi gibi, diğer para birimleri veya diğer varlık türleri de Move'da temsil edilebilir.

### Daha fazla bilgi için

- [Move whitepaper](https://developers.diem.com/docs/technical-papers/move-paper/)
