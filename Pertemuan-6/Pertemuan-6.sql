-- -----------------------------
-- Fungsi Agregasi
-- -----------------------------
-- Fungsi agregasi adalah fungsi yang merekap banyak nilai menjadi 1 nilai.
-- Berbeda dengan fungsi skalar yang mengolah 1 nilai dari baris yang sama, dan
-- mengembalikan 1 nilai juga.
-- Beberapa contoh fungsi agregasi: MIN(), MAX(), AVG(), COUNT(), SUM()
-- Contoh: Harga termahal dari semua barang yang ada di tabel produk!
SELECT MAX(unitprice) FROM Production.Products;
-- Bagaimana dengan harga yang termurah?
SELECT MIN(unitprice) FROM Production.Products;
-- Rata-rata harganya?
SELECT AVG(unitprice) FROM Production.Products;
-- Jumlah total harga?
SELECT SUM(unitprice) FROM Production.Products;
-- Ada berapa jumlah semua barangnya?
SELECT COUNT(unitprice) FROM Production.Products;
-- Bagaimana jika ingin dijadikan satu hasil SELECT?
SELECT
	MAX(unitprice) AS [Harga Termahal],
	MIN(unitprice) AS [Harga Termurah],
	AVG(unitprice) AS [Rata-rata Harga],
	SUM(unitprice) AS [Total Semua Harga],
	COUNT(unitprice) AS [Jumlah Data]
FROM
	Production.Products;

-- Catatan: Dengan fungsi agregasi kita hanya bisa tau angkanya saja.
-- Tetapi barangnya yang mana kita tidak bisa tau.
-- Untuk mengetahui barangnya yang mana kita harus mengguannakan kombinasi SQL
-- yang lainnya. Misalnya SUBQUERY!
-- Contoh: Barang yang mana yang harganya termahal?
-- 1. Kita cari dulu harga termahalnya
SELECT MAX(unitprice) FROM Production.Products; -- 263,50
-- 2. Cari barang yang harganya 263,50
SELECT * FROM Production.Products WHERE unitprice = 263.50; -- Product QDOMO
-- Atau...
-- Bisa langusng dalam 1 query saja.
SELECT * FROM Production.Products 
WHERE unitprice = (SELECT MAX(unitprice) FROM Production.Products); -- SELECT yang disini
																	-- adalah subquery

-- -----------------------------
-- Klausa GROUP BY
-- -----------------------------
-- Berfungsi untuk mengelompokkan hasil dari fungsi agregasi.
-- Jika tanpa GROUP BY, fungsi agregasi akan selalu menghasilkan TEPAT 1 nilai,
-- dengan GROUP BY, hasilnya bisa lebih dari satu, tergantung dikelompokkannya
-- berdasarkan apa.
-- Contoh: Cari tahu total berat pengiriman barang di tiap-tiap kota tujuan lalu urutkan!
SELECT
	shipcity, -- Bisa ditambahkan di SELECT, karena sudah ada di GROUP BY
	SUM(freight) AS [Total Berat] -- Kalau tidak diberi AS -> (No column name)
FROM Sales.Orders
GROUP BY shipcity
ORDER BY [Total Berat] DESC; -- Urutkan menurun. Yang paling besar, di atas.

-- Contoh lain: Hitung total uang yang dihasilkan dari penjualan tiap-tiap produk!
SELECT 
productid,
SUM((unitprice * qty) * (1 - discount)) AS total_omset
FROM Sales.OrderDetails
GROUP BY productid
ORDER BY total_omset DESC;

-- Bagaimana jika ingin mengetahui nama produknya? Pakai Sub-query
SELECT * FROM Production.Products WHERE productid = (
	SELECT productid FROM (
		SELECT TOP 1
		productid,
		SUM((unitprice * qty) * (1 - discount)) AS total_omset
		FROM Sales.OrderDetails
		GROUP BY productid
		ORDER BY total_omset DESC
	) AS tmp
);


-- -----------------------------
-- Klausa HAVING
-- -----------------------------
-- Digunakan untuk memfilter GROUP dari hasil GROUP BY.
-- Contoh: Tampilkan kota mana saja, yang karyawannya lebih dari 1.
SELECT 
	city AS Kota,
	COUNT(*) AS [Jumlah Karyawan] 
FROM HR.Employees
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY [Jumlah Karyawan];

-- Contoh lain: Tampilkan customer yang sudah pernah beli lebih dari 10x
SELECT
	custid AS [ID Pelanggan],
	COUNT(*) AS [Jumlah Pembelian]
FROM Sales.Orders
GROUP BY custid
HAVING COUNT(*) > 10
ORDER BY [Jumlah Pembelian] DESC;


-- -----------------------------
-- Sub-query: Query bersarang, alias SELECT di dalam SELECT
-- -----------------------------
-- 1. Sub-query scalar: Adalah subquery yang menghasilkan 1 nilai saja.
-- Contoh: Tampilkan ID pelanggan yang TERAKHIR melakukan pembelian!
-- Data pembelian:
SELECT custid FROM Sales.Orders WHERE orderdate = 
(
	-- Sub-query scalar
	SELECT MAX(orderdate) FROM Sales.Orders -- Menghasilkan TEPAT 1 nilai: 2008-05-06
);

-- 2. Sub-query Multi value: Adalah subquery yang menghasilkan nilai lebih dari 1,
-- tetapi hanya 1 kolom.
-- Siapa saja nama customer yang beli paling akhir tersebut?
SELECT contactname FROM Sales.Customers WHERE custid IN (
	-- Subquery multi-value
	SELECT custid FROM Sales.Orders WHERE orderdate = (
	-- Sub-query scalar
	SELECT MAX(orderdate) FROM Sales.Orders -- Menghasilkan TEPAT 1 nilai: 2008-05-06
	)
);
