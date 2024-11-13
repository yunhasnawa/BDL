USE TSQL2012;
GO

-- Membuat view untuk contoh running totals
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

-- Buat View untuk menampilkan data penjualan per category per tahun
CREATE VIEW Sales.CategoryQtyYear AS
SELECT categoryname, orderyear, SUM(qty) AS qty
FROM Sales.CategoryOrderYear
GROUP BY categoryname, orderyear
ORDER BY categoryname, orderyear;

GO

-- Window function dasar
-- Contoh: Membuat running total dari quantity untuk tiap-tiap
--         barang berdasarkan kategori.
SELECT * FROM Sales.CategoryQtyYear ORDER BY categoryname, orderyear;

-- Dengan Window Function
SELECT 
	categoryname, 
	orderyear, 
	qty,
	SUM(qty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS runningtotals
FROM Sales.CategoryQtyYear
-- WHERE categoryname = 'Beverages'; -- Bisa ditambahkan WHERE

-- Moving average: Rata-rata berjalan.
-- Contoh: Dari data sebelumnya, tampilkan moving average-nya!
SELECT 
	categoryname, 
	orderyear, 
	qty,
	SUM(qty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS runningtotals,
	AVG(qty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS movingavg
FROM Sales.CategoryQtyYear

-- Perangkingan dengan window RANK()
-- Contoh: Mengurutkan data qty dari penjualan pada tahun-tahun yang ada
SELECT 
	categoryname, 
	orderyear, 
	qty,
	SUM(qty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS runningtotals,
	AVG(qty) OVER (PARTITION BY categoryname ORDER BY orderyear) AS movingavg,
	RANK() OVER (PARTITION BY categoryname ORDER BY qty DESC) AS ranking
FROM Sales.CategoryQtyYear
GO

-- Studi kasus: Pendapatan harian dari seluruh penjualan
CREATE VIEW Sales.DailyIncome AS
SELECT
	o.orderdate,
	SUM((od.qty * od.unitprice) * (1 - od.discount)) AS income
FROM Sales.Orders AS o
	INNER JOIN Sales.OrderDetails AS od ON od.orderid = o.orderid
GROUP BY o.orderdate;
GO

SELECT * FROM Sales.DailyIncome ORDER BY orderdate;

-- --------------
-- Tugas Latihan:
-- --------------
-- 1. Tampilkan running total untuk pendapatan harian di tahun 2007 bulan 5 saja.
-- 2. Tampilkan moving average dari soal nomor 1.
-- 3. Tampilkan running total untuk pendapatan BULANAN di tahun 2007 saja.
-- 4. Tampilkan rangking produk dengan harga termahal hingga yang termurah.

-- * Tulis query-nya, screenshot hasilnya, letakkan di file word, jadikan PDF, 
--   dan kumpulkan!
-- * Link pengumpulannya akan saya berikan ke ketua kelas.