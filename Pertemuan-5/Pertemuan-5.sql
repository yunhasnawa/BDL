USE TSQL2012;
GO

------------------------------------
-- Fungsi skalar vs Fungsi Agregasi
-- Fungsi skalar, mengembalikan 1 nilai dengan input yang 1 nilai juga
-- Contoh: Memberikan '$' di depan unitprice pada tabel Production.Products
-- Gunakan fungsi Concat()
SELECT 
	productid,
	productname,
	unitprice,
	CONCAT('$', unitprice) AS dollarprice
FROM Production.Products;

-- Fungsi Agregasi: Inputnya banyak nilai dari baris-baris yang berbeda,
-- namun mengembalikan hanya 1 nilai luaran (output)
-- Contoh: Hitung rata-rata harga barang di tiap-tiap kategori!
-- Gunakan fungsi AVG() & klausa GROUP BY
SELECT * FROM Production.Products;
SELECT 
	categoryid,
	AVG(unitprice) AS avgprice
FROM Production.Products
GROUP BY categoryid
ORDER BY categoryid;

-- Fungsi-fungsi konversi
-- 1. CAST: Untuk mengubah tipe data tertentu menjadi tipe data lainnya.
-- Contoh: Mengubah string angka menjadi angka sungguhan.
DECLARE @AngkaString AS NVARCHAR(10) = '305.29';
-- Akan error jika stringnya tidak bisa diubah jadi angka. Contoh:
-- DECLARE @AngkaString AS NVARCHAR(10) = '305,29';
DECLARE @AngkaDesimal AS FLOAT = CAST(@AngkaString AS FLOAT);
-- Tampilkan:
SELECT
	@AngkaString AS [Angka String],
	@AngkaDesimal AS [Angka Desimal];

-- 2. CONVERT(): Mengubah tipe data tertentu menjadi tipe data lainnya. Baik digunakan
-- untuk melakukan konversi terkait tanggal
-- Fungsi ini memerlukan parameter berupa kode format (style)
-- Kode format yang ada rentangnya antara 0-21 (Tidak pakai 'abad'/century) atau
-- 100-114, 120, 121, 126, 127, 130, 131 (dengan abad/century)
-- Bisa dilihat di: w3schools.com/sql/func_sqlserver_convert.asp
-- Contoh: Mengubah string tanggal kemerdekaan menjadi DATETIME
DECLARE @Tanggal1 AS NVARCHAR(10) = '19450817'
DECLARE @Tanggal2 AS NVARCHAR(10) = '17-08-1945'
DECLARE @Konversi1 AS DATETIME = CONVERT(DATETIME, @Tanggal1, 101)
DECLARE @Konversi2 AS DATETIME = CONVERT(DATETIME, @Tanggal2, 105)
SELECT
	@Konversi1 AS [Konversi #1], 
	@Konversi2 AS [Konversi #2];

-- Fungsi PARSE(): Digunakan untuk mengubah tipe data STRING menjadi tipe data
-- yang lainnya.
-- Contoh: parsing tipe data string ke MONEY
DECLARE @NominalTeks AS NVARCHAR(10) = '150.000';
DECLARE @Rupiah AS MONEY = PARSE(@NominalTeks AS MONEY USING 'id-ID');
DECLARE @Dollar AS MONEY = PARSE(@NominalTeks AS MONEY USING 'en-US');
DECLARE @Pounds AS MONEY = PARSE(@NominalTeks AS MONEY USING 'en-UK');
SELECT
	@NominalTeks, @Rupiah, @Dollar, @Pounds;
GO
-- Fungsi TRYPARSE(): Seperti PARSE(), tetapi jika error, tidak stop, melainkan
-- NULL yang akan dikembalikan.
-- Contoh: Dibawah ini akan ERROR
DECLARE @NominalTeks AS NVARCHAR(10) = '150 koma 000';
DECLARE @Rupiah AS MONEY = PARSE(@NominalTeks AS MONEY USING 'id-ID');
SELECT
	@NominalTeks, @Rupiah;
GO
-- Dengan TRYPARSE, tidak error.
DECLARE @NominalTeks AS NVARCHAR(10) = '150 koma 000';
DECLARE @Rupiah AS MONEY = TRY_PARSE(@NominalTeks AS MONEY USING 'id-ID');
SELECT
	@NominalTeks, @Rupiah;

-- Konversi otomatis: Di SQL server, apabila suatu tipe data itu nilainya 
-- 'trivial', ketika ia masuk ke dalam ekspresi, akan dikonversi secara otomatis.
-- Contoh: Penambahan string dengan decimal
DECLARE @AngkaTeks AS NVARCHAR(10) = '100.5';
DECLARE @AngkaDesimal AS DECIMAL(5,2) = 100.25;
DECLARE @Jumlah AS DECIMAL(5,2) = @AngkaTeks + @AngkaDesimal;
SELECT @Jumlah;

------------------------------------------
-- Fungsi Logika
-- Adalah fungsi-fungsi yang digunakan untuk 'memilih' nilai berdasarkan
-- Tes Logika (predicate) tertentu
------------------------------------------
-- 1. Fungsi IIF(): Digunakan untuk menampilkan nilai tertentu berdasarkan 
-- parameter yang pertama (tes logikanya). Apabila true, maka parameter-2
-- yang ditampilkan, apabila false, maka parameter-3 yang ditampilkan.
-- Contoh: Tampilkan kategori mahal atau murah dari harga yang ada di tabel
-- Production.Products. Apabila harga barangnya > $20, maka tampilkan 'Mahal',
-- Selain itu tampilkan 'Tidak Mahal'.
SELECT 
	*, 
	IIF(unitprice > 20, 'Mahal', 'Tidak Mahal') AS [Tingkatan Harga] 
FROM Production.Products;

-- 1.1. Fungsi IIF() bersarang
-- Contoh: Bagaiman jika rentangnya ada 3? Misal: 
-- < 20 = Murah, 20 - 50: Sedang, > 50: Mahal 
SELECT 
	*, 
	IIF(unitprice < 20, 'Murah', 
		IIF(unitprice > 50, 'Mahal', 'Sedang')) AS [Tingkatan Harga] 
FROM Production.Products;

-- 2. Fungsi CHOOSE(): Untuk memilih satu nilai dari sekumpulan nilai 
-- berdasarkan indeks yang diberikan.
-- Contoh-1: Pemilihan sederhana.
SELECT CHOOSE(1, 'Malang','Surabaya', 'Semarang');
SELECT CHOOSE(3, 'Malang','Surabaya', 'Semarang');
-- Contoh-2: Studi kasus -> Suatu ketika ada penugasan dari kantor pusat untuk
-- Semua karyawan ke 2 kota yaitu 'Malang' atau 'Semarang'. Pemilihan dilakukan
-- Secara acak berdasarkan ID Karyawan. Bagi Karyawan yang ID-nya ganjil pergi
-- ke Malang, dan yang genap pergi ke Semarang. Bagaimana menampilkan datanya?
SELECT 
	empid, 
	firstname,
	CHOOSE((empid % 2) + 1, 'Semarang', 'Malang') AS penugasan
FROM HR.Employees;


------------------------------------------
-- Fungsi Pengecekan Nilai NULL (NLUL-Checking functions)
-- Berfungsi untuk memeriksa apakah suatu variabel bernilai NULL atau tidak
------------------------------------------

-- 1. COALESCE(): Mengembalikan nilai pertama dari sekumpulan nilai yang diinputkan
-- ke dalam parameternya
-- Contoh:
DECLARE @A AS NVARCHAR(10);
DECLARE @B AS NVARCHAR(10) = NULL;
DECLARE @C AS NVARCHAR(10) = '';
DECLARE @D AS NVARCHAR(10) = 0; -- Tidak error karena konversi otomatis trivial.
DECLARE @E AS NVARCHAR(10) = 'Halo!';
-- Penggunaan Coalesce;
SELECT COALESCE(@A, @B, @C, @D, @E);

-- 2. ISNULL(): Memeriksa apakah parameter yang pertama nilainya NULL?
-- Jika ya, maka akan mengembalikan parameter kedua, jika tidak maka nilai parameter 1
-- yang akan dikembalikan.
-- CONTOH: Di data karyawan apabila kolom 'wilayah' tidak diisi maka tampilkan
-- 'Data tidak diisi', apabila diisi, maka tampilkan nilai aslinya.
SELECT 
	empid,
	CONCAT(firstname, ' ', lastname) AS fullname,
	ISNULL(region, 'Data tidak ada') AS region
FROM HR.Employees;


------------------------------------------
-- Fungsi-fungsi STRING
-- Berfungsi untuk mengolah String -> VARCHAR/NVARCHAR/TEXT/CHAR/NCHAR
-- Ada banyak fungsi string, kita pelajari beberapa diantarnya.
------------------------------------------
-- 1. CONCAT(): Untuk menggabungkan beberapa string menjadi satu string.
-- Contoh:
DECLARE @NamaDepan AS NVARCHAR(20) = 'Pak Prabowo';
DECLARE @NamaBelakang AS NVARCHAR(10) = 'Subianto';
DECLARE @PakPresiden AS NVARCHAR(30) = CONCAT(@NamaDepan, ' ', @NamaBelakang);
SELECT @PakPresiden;

-- 2. LEN(): Digunakan untuk menghitung panjang karakter dalam suatu string
-- Contoh: Menampilkan panjang nama dari tiap-tiap karyawan
SELECT
	CONCAT(firstname, ' ', lastname) AS [Nama Lengkap],
	LEN(CONCAT(firstname, ' ', lastname)) AS [Panjang Karakter]
FROM
	HR.Employees;

-- 3. REPLACE(): Digunakan untuk mengganti suatu string yang ada didalam string dengan
-- string lainnya.
-- Biasanya digunakan untuk keperluan 'menyeragamkan data'
SELECT 
	orderid,
	shipname,
	REPLACE(shipname, 'Destination', 'Ship to') AS [Uniform Shipname]
FROM Sales.Orders;
