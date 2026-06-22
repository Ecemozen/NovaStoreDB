


-- BÖLÜM 1: VERİ TABANI TASARIMI (DDL)



USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NovaStoreDB')
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- 1. Ana Tablo: Categories (Kategoriler)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

-- 2. Ana Tablo: Customers (Müşteriler)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);
GO

-- 3. Bağımlı Tablo: Products (Ürünler)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT CONSTRAINT DF_Products_Stock DEFAULT 0,
    CategoryID INT,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- 4. Bağımlı Tablo: Orders (Siparişler)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME CONSTRAINT DF_Orders_OrderDate DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) CONSTRAINT DF_Orders_TotalAmount DEFAULT 0.00,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- 5. Ara Tablo: OrderDetails (Sipariş Detayları)

CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO


-- İLERİ SEVİYE NESNE: OTOMATİK TOPLAM TRIGGER

CREATE TRIGGER trg_UpdateTotalAmount
ON OrderDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Yalnızca etkilenen siparişlerin toplam tutarlarını alt sorgu ile güncelliyoruz.
    UPDATE Orders
    SET TotalAmount = ISNULL((
        SELECT SUM(Quantity * UnitPrice)
        FROM OrderDetails
        WHERE OrderDetails.OrderID = Orders.OrderID
    ), 0.00)
    WHERE Orders.OrderID IN (
        SELECT OrderID FROM inserted
        UNION
        SELECT OrderID FROM deleted
    );
END;
GO

-- BÖLÜM 2: VERİ GİRİŞİ (DML)

-- Görev 1: 5 Yeni ve Özgün Kategori
INSERT INTO Categories (CategoryName) VALUES
('Denizcilik & Amatör Balıkçılık'),
('Kamp & Outdoor Yaşam'),
('Premium Kahve & Gurme'),
('Masaüstü Strateji Oyunları'),
('Akıllı Ev & Hobi Atölyesi');
GO

-- Görev 2: Kategorilere Dağıtılmış 12 Seçkin Ürün
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Karbon Sazan Oltası 3.60m', 2450.00, 15, 1),
('Suni Yem ve Kaşık Seti (24 Parça)', 650.00, 45, 1),
('4 Kişilik Mevsimlik Kamp Çadırı', 5200.00, 8, 2),
('Kaz Tüyü Mumyalanmış Uyku Tulumu', 3100.00, 12, 2),
('Single Origin Ethiopia Kahve Çekirdeği 1kg', 850.00, 60, 3),
('SQL Raporlama ve Veri Analizi El Kitabı', 420.00, 25, 3), -- Yönergedeki Kitap gereksinimi için
('Catan Strateji Masa Oyunu', 1850.00, 14, 4),
('Dungeons & Dragons Zar ve Deri Kese Seti', 750.00, 30, 4),
('Akıllı RGB Led Şerit Aydınlatma 5m', 1200.00, 19, 5),
('Şarjlı Hassas Gravür ve Oyma Seti', 2900.00, 4, 5),
-- Raporlama testleri için stoğu 20'nin altında olan kritik ürünler:
('Taşınabilir Kamp Ocağı & Gaz Seti', 1350.00, 6, 2),
('Retro Pikap ve Bluetooth Hoparlör', 6800.00, 3, 5);
GO

-- Görev 3: Yönergeye Tam Uyumlu Müşteri Kayıtları (Ahmet Yılmaz Dahil)
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz', 'İstanbul', 'ahmet.yilmaz@mail.com'),
('Ayşe Kaya', 'Ankara', 'ayse.kaya@mail.com'),
('Mehmet Demir', 'İzmir', 'mehmet.demir@mail.com'),
('Elif Çelik', 'Bursa', 'elif.celik@mail.com'),
('Can Özkan', 'Zonguldak', 'can.ozkan@mail.com'),
('Zeynep Yıldız', 'Antalya', 'zeynep.yildiz@mail.com');
GO

-- Görev 4: Zaman Analizine Uygun 9 Sipariş Girişi (Haziran 2026)
INSERT INTO Orders (CustomerID, OrderDate) VALUES
(1, '2026-06-10 10:30:00'), -- Ahmet Yılmaz
(2, '2026-06-12 14:15:00'),
(3, '2026-06-14 09:00:00'),
(4, '2026-06-17 18:45:00'),
(5, '2026-06-18 11:20:00'),
(1, '2026-06-19 15:00:00'), -- Ahmet Yılmaz (2. Sipariş)
(6, '2026-06-19 16:30:00'),
(2, '2026-06-19 20:45:00'),
(3, '2026-06-19 22:15:00');
GO

-- Sipariş Alt Detayları (Trigger otomatik olarak Orders.TotalAmount'u hesaplayacak)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 2450.00),  -- Ahmet Yılmaz Karbon Olta aldı
(1, 2, 2, 650.00),   -- Ahmet Yılmaz 2 adet Suni Yem aldı
(2, 5, 2, 850.00),
(3, 3, 1, 5200.00),
(3, 11, 1, 1350.00),
(4, 12, 1, 6800.00),
(5, 10, 1, 2900.00),
(5, 6, 1, 420.00),
(6, 6, 2, 420.00),   -- Ahmet Yılmaz Kitap aldı
(7, 9, 1, 1200.00),
(8, 4, 1, 3100.00),
(9, 7, 1, 1850.00);
GO

-- BÖLÜM 4: İLERİ SEVİYE NESNE - VIEW

IF OBJECT_ID('vw_SiparisOzet', 'V') IS NOT NULL
    DROP VIEW vw_SiparisOzet;
GO

CREATE VIEW vw_SiparisOzet AS
SELECT
    C.FullName AS MusteriAdi,
    O.OrderDate AS SiparisTarihi,
    P.ProductName AS UrunAdi,
    OD.Quantity AS Adet,
    OD.UnitPrice AS BirimFiyat,
    (OD.Quantity * OD.UnitPrice) AS SatirToplami
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON P.ProductID = OD.ProductID;
GO


-- BÖLÜM 3: SORGU VE ANALİZ (RAPORLAR)


print '--- 1. Stok Miktarı 20''den Az Olan Ürünler ---';
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

print '--- 2. Müşteri ve Sipariş Eşleşme Raporu ---';
SELECT
    C.FullName AS [Müşteri Adı],
    C.City AS [Şehir],
    O.OrderDate AS [Sipariş Tarihi],
    O.TotalAmount AS [Toplam Tutar]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID;
GO

print '--- 3. Ahmet Yılmaz İsimli Müşterinin Detay Raporu ---';
SELECT
    C.FullName AS [Müşteri Adı],
    P.ProductName AS [Ürün Adı],
    P.Price AS [Fiyat],
    CA.CategoryName AS [Kategori Adı]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories CA ON P.CategoryID = CA.CategoryID
WHERE C.FullName = 'Ahmet Yılmaz';
GO

print '--- 4. Kategori Bazlı Toplam Ürün Sayısı ---';
SELECT
    CA.CategoryName AS [Kategori Adı],
    COUNT(P.ProductID) AS [UrunSayisi]
FROM Categories CA
LEFT JOIN Products P ON CA.CategoryID = P.CategoryID
GROUP BY CA.CategoryName;
GO

print '--- 5. Müşteri Bazlı Toplam Ciro Analizi ---';
SELECT
    C.FullName AS [Müşteri Adı],
    SUM(OD.Quantity * OD.UnitPrice) AS [ToplamCiro]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
GROUP BY C.FullName
ORDER BY [ToplamCiro] DESC;
GO

print '--- 6. Sipariş Zaman Analizi (DATEDIFF) ---';
SELECT
    OrderID AS [Sipariş No],
    OrderDate AS [Sipariş Tarihi],
    DATEDIFF(DAY, OrderDate, GETDATE()) AS [GecenGun]
FROM Orders;
GO

-- ==========================================
-- BÖLÜM 4: YEDEKLEME (BACKUP)
-- ==========================================

BACKUP DATABASE NovaStoreDB
TO DISK = 'EcemOzen_NovaStoreDB_Full.bak'
WITH FORMAT,
INIT,
NAME = 'NovaStore Proje Master Full Backup';
GO