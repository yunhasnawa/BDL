-- Mencoba membuat database sendiri
-- Apabila tidak menggunakan 'go', error
CREATE DATABASE PercobaanTI2D;
USE PercobaanTI2D; -- Error karena selesai duluan

-- 'go' adalah Batch Separator
-- Perintah dijalankan batch demi batch
CREATE DATABASE PercobaanTI2D;
go
USE PercobaanTI2D; -- Tidak error karena menunggu batch sebelumnya
go

-- Konteks Database
-- Adalah database mana saat ini yang kita gunakan.
-- Bisa dilihat di kiri atas atau kanan bawah.
-- Untuk mengganti konteks bisa menggunakan yang kiri atas,
-- Atau menggunakan USE.
-- Apabila konteks belum diganti, akses ke tabel akan error.
-- Contoh:
SELECT * FROM Sales.Orders; -- Agar tidak error, ganti konteks ke TSQL2012

-- Predicates and Operator
-- Contoh salah satu predicate (IN):
-- Menampilkan data dari kota-kota tertentu.
SELECT * FROM Sales.Orders 
WHERE shipcity IN ('Reims', 'Lyon', 'Rio de Janeiro');

-- Contoh operator (*, -)
-- Menghitung harga jual:
-- HJ = UP * (1 - disc) * qty
SELECT 
	*,
	unitprice * (1 - discount) * qty AS hargajual
FROM Sales.OrderDetails;

-- Operator penggabungan string (concatenate)
-- Contoh:
-- Menggabungkan sapaan, nama depan, nama belakang
SELECT 
	empid,
	lastname,
	firstname,
	titleofcourtesy,
	(titleofcourtesy + ' ' + firstname + ' ' + lastname) AS namalengkap
FROM HR.Employees

-- Function
-- Contoh beberapa function
-- Fungsi string untuk mengambil beberapa karakter dari kanan (RIGHT)
SELECT * FROM Sales.Customers 
WHERE RIGHT(contacttitle, 7) = 'manager';
-- Perhatikan bahwa fungsi selalu diikuti () setelah namaFungsi.

-- Fungsi tanggal/waktu
-- Menampilkan waktu sekarang
SELECT SYSDATETIME() AS datetimesekarang;

-- Fungsi agregasi
-- Menghitung total jumlah barang yang sudah terjual
SELECT SUM(qty) AS totaljumlah FROM Sales.OrderDetails;

-- Variabel
-- Adalah fasilitas untuk menyimpan nilai secara sementara
-- Contoh deklarasi variabel
DECLARE @Tahun AS INT = 2007;
-- Tampilkan nilainya
SELECT @Tahun;
-- Tampilkan data penjualan yang tahunnya ada di variabel
SELECT * FROM Sales.Orders
WHERE YEAR(orderdate) = @Tahun;

-- Control Flow
-- Adalah elemen-elemen T-SQL yang terkait dengan pemrograman.
-- Contoh BEGIN..END:
-- Membuat fungsi untuk menghitung total berat penjualan berdasarkan tahun
CREATE FUNCTION Sales.HitungTotalBerat(@Tahun INT) RETURNS FLOAT AS
BEGIN
	DECLARE @TotalBerat AS FLOAT;
	SELECT @TotalBerat = SUM(freight) FROM Sales.Orders 
		WHERE YEAR(orderdate) = @Tahun;
	RETURN @TotalBerat;
END

-- Memanggil fungsi
SELECT Sales.HitungTotalBerat(2007);

-- CASE, adalah fitur untuk pencabangan, namun CASE BUKAN termasuk 
-- Control of flow, karena dia bisa digunakan di luar Programmability
-- Programmability -> Function, Stored Procedure, Trigger, dll.
-- Contoh Case:
-- Menampilkan nama kategori produk berdasarkan categoryid
SELECT *,
	CASE categoryid
		WHEN 1 THEN 'Minuman'
		WHEN 2 THEN 'Makanan Ringan'
		WHEN 3 THEN 'Menu Utama'
		ELSE 'Tidak diketahui'
	END 
	AS jenis
FROM Production.Products;






