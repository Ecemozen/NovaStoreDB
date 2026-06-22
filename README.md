# NovaStoreDB: E-Ticaret Veritabanı Yönetimi ve Analitik Raporlama Sistemi

NovaStoreDB, modern bir e-ticaret platformunun operasyonel veri akışını yönetmek, veri bütünlüğünü otomatikleştirmek ve stratejik karar alma süreçlerini desteklemek amacıyla SQL Server üzerinde geliştirilmiş ilişkisel bir veritabanı (RDBMS) projesidir.

Proje; veri tabanı mimarisi tasarımı (DDL), veri manipülasyonu (DML), veri tutarlılığı otomasyonu (Triggers) ve iş zekası analitiği (Reporting Queries) olmak üzere uçtan uca bir mimari sunmaktadır.

## Teknik Mimari ve Çözüm Bileşenleri

* **İlişkisel Veri Modeli (DDL):** Veri standardizasyonunu sağlamak ve anormallikleri önlemek amacıyla optimize edilmiş 5 ana tablo (`Categories`, `Customers`, `Products`, `Orders`, `OrderDetails`) mimarisi.
* **Veri Tutarlılığı ve Otomasyon (Trigger):** `OrderDetails` tablosundaki herhangi bir veri değişikliğinde (`INSERT`, `UPDATE`, `DELETE`) tetiklenen ve ilişkili siparişin toplam tutarını (`TotalAmount`) anlık olarak asenkron hesaplayan `AFTER TRIGGER` mekanizması.
* **Soyutlama Katmanı (View):** Karmaşık çoklu `INNER JOIN` yapılarını maskeleyerek sistem performansını artıran ve sorgu süreçlerini standartlaştıran `vw_SiparisOzet` katmanı.
* **İş Zekası ve Analitik Sorgular:**
  * Kritik stok seviyesi izleme ve envanter yönetimi.
  * Müşteri segmentasyonu ve toplam ciro (Revenue) analizi.
  * Zaman bazlı sipariş performansı ve veri analitiği (`DATEDIFF`).

## Dosya Yapısı

* `EcemOzen_NovaStore_Proje.sql`: Veritabanı şemasını, tetikleyicileri, görünümleri, test veri setlerini ve analitik rapor sorgularını içeren ana SQL betiği.

## Dağıtım ve Kurulum (Deployment)

1. Tercih edilen bir SQL Server yönetim arayüzünü (SSMS, Azure Data Studio vb.) başlatın.
2. Depoda bulunan `.sql` uzantılı script dosyasını projenize dahil edin.
3. Betiği execute (çalıştır) ettiğinizde; `NovaStoreDB` veritabanı, şema yapısı, örnek veri seti ve analitik sorgular otomatik olarak konfigüre edilecektir.
