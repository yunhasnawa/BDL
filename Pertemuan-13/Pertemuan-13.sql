USE TSQL2012;
GO

-- -----------------
-- Blok
-- -----------------
-- Adalah sekumpulan baris-baris statement (perintah) SQL yang menjadi
-- satu kesatuan.
-- Blok diawali dengan BEGIN, dan diakhiri dengan END

BEGIN
	-- Mendeklarasikan variabel, sekaligus mengisi nilai (Cara-1)
	DECLARE @Nama AS NVARCHAR(50) = 'Yoppy Yunhasnawa'; 
	-- Cara-2: Dideklarasikan dulu, tidak langsung diisi
	DECLARE @Instansi AS NVARCHAR(50);
	SET @Instansi = 'Politeknik Negeri Malang'; -- Mengisi variabel
	-- Menampilkan isi variabel
	SELECT @Nama AS Nama, @Instansi AS Instansi;
	-- Menampilkan isi variabel tetapi di tab 'Messages'
	PRINT('Nama: ' + @Nama + '; Instansi: ' + @Instansi);
END


-- -----------------
-- Perulangan
-- -----------------
-- Untuk melakukan perulangan di T-SQL, digunakan keyword WHILE, yang diikuti
-- dengan kode yang ingin diulang.
-- Apabila kode yang ingin diulang lebih dari satu baris, maka harus dibuat
-- blok (diberi BEGIN dan END)

-- Contoh: Menampilkan kelas wajib belajar di Indonesia.
PRINT('Kelas wajib belajar di Indonesia adalah sebagai berikut: ');
-- Buat dulu i untuk menampung angkanya.
DECLARE @i AS INT = 1;
-- Lakukan perulangan dengan WHILE
WHILE (SELECT @i) <= 12
BEGIN
	DECLARE @Kelas AS NVARCHAR(10) = CONCAT('Kelas-', @i);
	PRINT(@Kelas);
	-- Jangan lupa mengupdate nilai i
	SET @i = (@i + 1);
END

-- -----------------
-- Pencabangan
-- -----------------
-- Untuk melakukan pencabangan di T-SQL, digunakan keyword IF ... ELSE
-- Ini berbeda dengan function IIF() yang sudah kita pelajari sebelumnnya.

-- Contoh: Menampilkan kata 'MAHAL' apabila harga suatu ID Produk > rata-rata
--         dan menampilkan 'TIDAK MAHAL', apabila sebaliknya.

SELECT * FROM Production.Products; -- Cek produk
-- Variabel untuk menyimpan ID produk yang ingin dicek.
DECLARE @IdProduk AS INT = 9;
DECLARE @RerataHarga AS MONEY = (SELECT AVG(unitprice) FROM Production.Products);
DECLARE @HargaProduk AS MONEY = (SELECT unitprice FROM Production.Products 
								 WHERE productid = @IdProduk);
PRINT('Data Produk');
PRINT('ID Produk     : ' + CAST(@IdProduk AS NVARCHAR(10)));
PRINT('Harga         : ' + CAST(@HargaProduk AS NVARCHAR(10)));
PRINT('Rerata Harga  : ' + CAST(@RerataHarga AS NVARCHAR(10)));
IF @HargaProduk > @RerataHarga
	PRINT('Kategori Harga: MAHAL');
ELSE
	PRINT('Kategori Harga: TIDAK MAHAL');

-- --------
-- ROUTINE
-- --------
-- Adalah 'blok' yang bisa diberi input, dan kemudian menghasilkan sesuatu. 
-- Apabila inputnya berbeda, maka hasilnya juga akan berbeda.
-- Seuatu yang dihasilkan tersebut bisa berupa:
-- A. Nilai (Value)           --> FUNCTION
-- B. Perubahan pada database --> PROCEDURE

-- ------------------
-- ROUTINE - FUNCTION
-- ------------------
-- Adalah routine yang mengembalikan nilai (value) tetapi tidak dapat mengubah database

-- Contoh: Mari kita ubah pengecekan harga sebelumnya menjadi sebuah fungsi.
GO -- Agar tidak error di bagian deklarasi fungsi
/*CREATE*/ ALTER FUNCTION Production.CekHarga(@IdProduk AS INT) RETURNS NVARCHAR(15) AS
BEGIN
	DECLARE @RerataHarga AS MONEY = (SELECT AVG(unitprice) FROM Production.Products);
	DECLARE @HargaProduk AS MONEY = (SELECT unitprice FROM Production.Products 
								     WHERE productid = @IdProduk);
	DECLARE @KategoriHarga AS NVARCHAR(15) = 'MAHAL';
	IF @HargaProduk <= @RerataHarga
		SET @KategoriHarga = 'TIDAK MAHAL';
	-- Function tidak bisa mengubah data
	-- DELETE FROM Production.Products WHERE productid = @IdProduk;
	RETURN @KategoriHarga;
END
GO -- Agar tidak error di bagian deklarasi fungsi

-- Menggunakan fungsi yang sudah dibuat
SELECT
	productid,
	productname,
	unitprice,
	(SELECT AVG(unitprice) FROM Production.Products) AS Rata2Harga,
	Production.CekHarga(productid) AS KategoriHarga -- Memanggil fungsi
FROM
	Production.Products;


-- -------------------
-- ROUTINE - PROCEDURE
-- -------------------
-- Disebut juga dengan Stored Procedure, adalah routine yang pada dasarnya tidak memiliki nilai
-- balik (return value), namun bisa melakukan perubahan pada data.
-- Stored procedure bisa memiliki parameter atau tidak. Sama seperti function juga demikian.

-- Contoh: Membuat stored procedure yang memeriksa kolom shipregion pada tabel Sales.Orders.
--         Apabila nilainya NULL maka di-UPDATE dengan string 'No Data';

GO
CREATE PROCEDURE Sales.CekShipRegion (@OrderId AS INT, @Label AS NVARCHAR(50)) AS
BEGIN
	DECLARE @ShipRegion AS NVARCHAR(255) = (SELECT Shipregion FROM Sales.Orders 
											WHERE orderid = @OrderId);
	IF @ShipRegion IS NULL
		BEGIN
			UPDATE Sales.Orders SET shipregion = @Label
			WHERE orderid = @OrderId;
			PRINT('Data berhasil diperbarui!');
		END
	ELSE
		PRINT('Data shipregion tidak NULL. Data TIDAK diperbarui.');
END;
GO

-- Mencoba SP yang baru dibuat
-- Cari data shipregion yang NULL
SELECT * FROM Sales.Orders WHERE shipregion IS NULL; -- 10249

-- Panggil SP untuk mengubah data sales orders id 10249, menjadi 'No Data';
EXECUTE Sales.CekShipRegion @OrderId = 10249, @Label = 'No Data';

-- Cek lagi data shipregion nomor 10249
SELECT * FROM Sales.Orders WHERE orderid = 10249;