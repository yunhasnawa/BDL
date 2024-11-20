USE TSQL2012;
GO

-- -----
-- PIVOT
-- -----
-- Untuk mengubah representasi hasil SELECT dari yang berbasis baris,
-- menjadi berbasis kolom.
-- Atau dengan kata lain, membuat rekap, atau rekapan (bahasa jawa)
-- Kita awali dengan membuat Derived Table dulu.
-- Karena operator PIVOT() itu mengolah hasil SELECT yang ada di belakang FROM

-- Buat terlebih dahulu VIEW untuk mencontohkan Pivot
CREATE VIEW Sales.CategoryOrderYear AS
SELECT 
	p.productid,
	p.productname,
	c.categoryname,
	od.qty,
	o.orderdate,
	YEAR(o.orderdate) AS orderyear
FROM Sales.Orders AS o
	INNER JOIN Sales.OrderDetails AS od ON od.orderid = o.orderid
	INNER JOIN Production.Products AS p ON p.productid = od.productid
	INNER JOIN Production.Categories AS c ON c.categoryid = p.categoryid;
GO

-- Data pembelian tiap kategori di semua tahun
-- Catatan: HARUS menggunakan DT (Derived Table)
SELECT * FROM
(SELECT categoryname, qty, orderyear FROM Sales.CategoryOrderYear) AS dt
PIVOT (
    SUM(qty)                   -- [Elemen Pivot-1]: Aggregation
	FOR orderyear              -- [Elemen Pivot-2]: Groupping
	IN([2006], [2007], [2008]) -- [Elemen Pivot-3]: Spreading
) AS pvt; -- Jangan lupa diberi Alias untuk pivotnya


-- -------
-- UNPIVOT
-- -------
-- Merupakan kebalikan dari PIVOT. Mengubah data yang berbasis kolom, menjadi
-- berbasis baris.
-- Tapi ingat: Tidak bisa selalu mengembalikan 100% data seperti semula.
-- Karena SQL Server tidak tahu detail dari mana rekap (agregasi) datanya.
-- Catatan: UNPIVOT berguna apabila bentuk asli datanya memang sudah
-- PIVOT.

-- Contoh UNPIVOT:
-- Karena tidak ada data dalam database yang memang aslinya berbentuk PIVOT,
-- Maka kita simpan saja, SQL sebelumnya menjadi VIEW untuk mensimulasikan
-- Data yang ingin kita tampilkan dalam bentuk UNPIVOT.
GO
CREATE VIEW Sales.RekapPenjualanTiapTahun AS
SELECT * FROM
(SELECT categoryname, qty, orderyear FROM Sales.CategoryOrderYear) AS dt
PIVOT (
    SUM(qty)                   -- [Elemen Pivot-1]: Aggregation
	FOR orderyear              -- [Elemen Pivot-2]: Groupping
	IN([2006], [2007], [2008]) -- [Elemen Pivot-3]: Spreading
) AS pvt; -- Jangan lupa diberi Alias untuk pivotnya
GO

-- Cek datanya
SELECT * FROM Sales.RekapPenjualanTiapTahun; 

-- Tampilkan data tersebut dalam bentuk UNPIVOT
SELECT 
	categoryname AS kategori,
	tahun,
	jumlah
FROM 
	Sales.RekapPenjualanTiapTahun
UNPIVOT(
	jumlah
	FOR tahun
	IN([2006], [2007], [2008])
) AS unpvt;


-- Contoh (pengayaan)
-- Membuat PIVOT namun dengan subquery pada IN-nya
-- Bisa dilakukan namun dengan menggunakan teknik dynamic SQL

-- Deklarasi variabel untuk menyimpan daftar kolom berupa tahun-tahun yang berbeda
DECLARE @DaftarTahun AS VARCHAR(MAX);
-- "[2006], [2007], [2008]" <-- Gunakan fungsi STRING_AGG() dan QUOTENAME()
SELECT @DaftarTahun = STRING_AGG(QUOTENAME(orderyear), ',')
					  FROM
					  (SELECT DISTINCT orderyear FROM Sales.CategoryOrderYear) AS tmp;
SELECT @DaftarTahun;

-- Selanjutnya gunakan teknik Dynamic SQL
-- Untuk memasukkan variabel @DaftarTahun tadi ke sintaksis pembuatan PIVOT
-- Dynamic SQL adalah menjadikan SQL sebagai String.
-- Agar bisa diubah-ubah, dimanipulasi.
-- Kemudian dieksekusi sebagai string menggunakan procedure sp_executesql()
-- 1. Buat variabel untuk menampung SQL pembuatan PIVOT
DECLARE @sqlPembuatPivot AS NVARCHAR(MAX);
-- 2. Masukkan SQL untuk membuat pivot ke variabel tadi
SELECT @sqlPembuatPivot = 
'SELECT * FROM
(SELECT categoryname, qty, orderyear FROM Sales.CategoryOrderYear) AS dt
PIVOT (
    SUM(qty)                   
	FOR orderyear              
	IN(' + @DaftarTahun + ') 
) AS pvt;'
-- 3. Jalankan (execute) SQL dalam bentuk string tersebut menggunakan sp_executesql
EXEC sp_executesql @sqlPembuatPivot;


-- -------------
-- GROUPING SETS
-- -------------
-- Adalah fitur yang merupakan jalan pintas apabila kita ingin menampilkan hasil
-- agregasi dari berbagai kolom menjadi 1 hasil SELECT.
-- Contoh: Menampilkan detail agregasi dari kolom CategoryName dan OrderYear yang 
--         ada pada view Sales.CategoryOrderYear

-- Aslinya jika tidak menggunakan GROUPING SETS, kita perlu menulis query berikut
SELECT categoryname, orderyear, qty FROM Sales.CategoryOrderYear;

SELECT 
	categoryName, 
	orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	categoryname, orderyear -- Mengelompokkan berdasarkan categoryname dan orderyear

UNION ALL

SELECT 
	categoryName, 
	NULL,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	categoryname -- Berdasarkan categoryname SAJA

UNION ALL

SELECT 
	NULL, 
	orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	orderyear -- Berdasarkan orderyear SAJA

UNION ALL

SELECT 
	NULL, 
	NULL,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear -- Tidak ada group by-nya. Ditotal SEMUA

-- Dengan menggunakan GROUPING SETS, akan menjadi JAAAUUUHHHH lebih sederhana.
SELECT 
	categoryName, 
	orderyear,
	SUM(qty) AS total
FROM 
	Sales.CategoryOrderYear
GROUP BY
	GROUPING SETS(
		(categoryname, orderyear),
		categoryname,
		orderyear
	)
ORDER BY categoryName, orderyear, total;
