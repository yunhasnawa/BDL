USE TSQL2012;
GO

-- -----------
-- Sys.Objects
-- -----------
-- Adalah sebuah view yang menampung metadata dari semua object yang ada di database
-- tertentu pada SQL Server kita.
-- View ini memiliki 12 kolom yang menyimoan data dan menerangkan semua objek yang 
-- ada di dalam database kita.
SELECT * FROM sys.objects;

-- Jenis objek yang ada di SQL Server, bisa dilihat dengan query berikut:
-- Note: type_desc maksudnya adalah type description.
SELECT DISTINCT [type] AS JenisObjek, [type_desc] AS Deskripsi 
FROM sys.objects;

-- Menampilkan tabel apa saja yang sudah 'kita' (user) buat.
SELECT [name] AS NamaTabel FROM sys.objects WHERE [type] = 'U';

-- Menampilkan objek-objek yang telah dimodifikasi dalam 10 hari terakhir.
SELECT
	name AS [Nama Objek],
	SCHEMA_NAME(schema_id) AS [Nama Skema],
	modify_date AS [Tanggal Terakhir Dimofikasi]
FROM
	sys.objects
WHERE
	modify_date > (GETDATE() - 10);

-- --------------------
-- INFORMATION_SCHEMA.*
-- --------------------
-- Adalah skema yang berisi view-view yang memuat informasi terkait meta data.
-- Terdapat banyak VIEW yang tergabung pada schema tersebut.
-- Dan schema tersebut terdapat pada setiap database, baik database yang kita buat,
-- maupun database system.

-- Melihat informasi tentang VIEW-VIEW yang ada pada DB kita.
-- Pada VIEW tersebut terdapat kolom VIEW_DEFINITION yang merupakan kode SQL yang
-- kita gunakan untuk membuat VIEW-VIEW kita.
-- Kolom TABLE_NAME memuat nama dari VIEW kita.
SELECT * FROM INFORMATION_SCHEMA.VIEWS;

-- Melihat informasi semua tabel-tabel yang adad di DB kita
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Melihat informasi constraint-constraint apa saja yang ada pada DB kita
SELECT CONSTRAINT_SCHEMA, TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- Menampilkan kolom apa saja yang ada pada tabel tertentu.
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sales' AND TABLE_NAME = 'Orders';


-- ------------------
-- Metadata Functions
-- ------------------
-- Adalah fungsi-fungsi yang sudah disediakan Microsoft untuk mencari tahu hal-hal
-- terkait dengan metadata SQL Server.

-- Menampilkan data tentang server kita
SELECT SERVERPROPERTY('Edition') AS [Edisi SQL Serverku];
SELECT SERVERPROPERTY('InstanceName') AS [Nama Instance]; -- NULL jika default instance
SELECT SERVERPROPERTY('MachineName') AS [Nama Komputer];
SELECT SERVERPROPERTY('EngineEdition') AS [Edisi Engine];
-- 1 = Personal; 2 = Standard; 3 = Enterprise (Developer Edition) .... 11.

-- Di SQL Server SEMUAAAAA objek punya ID tertentu.
-- Untuk menampilkan objek ID dari suatu nama objek:
SELECT OBJECT_ID('Sales.OrderDetails'); -- 1301579675

-- Kalau sebaliknya, punya ID-nya dan ingin tahu namanya:
SELECT OBJECT_NAME(1301579675);


-- ----------------------------
-- System SP (Stored PROCEDURE)
-- ----------------------------
-- SP adalah seperti fungsi, tetapi yang tidak memiliki nilai balik.
-- Maka dari itu SP tidak bisa di-SELECT.
-- Untuk menjalankan SP, digunakan keyword EXEC
-- Function tidak bisa mengubah data, SP bisa.
--
-- System SP adalah fasilitas untuk melihat dan/atau berinteraksi dengan metadata
-- dalam bentuk stored procedure.

-- Menampilkan nama-nama database apa saja yang ada di server kita
EXECUTE sp_databases; -- Bisa juga pakai 'EXEC'

-- Stored procedure TIDAK memiliki nilai balik, sehingga SQL berikut akan error:
SELECT DATABASE_NAME FROM sp_databases;

-- Menampilkan nama kolom apa saja yang terletak pada suatu tabel.
-- @ disini adalah PARAMETER.
-- Ingat: SP itu adalah FUNCTION yang VOID, sehingga dia juga bisa diberi parameter.
EXECUTE sp_columns @table_name = 'Employees', @table_owner = 'HR';


-- --------------------------------
-- DMO (Dynamic Management Objects)
-- --------------------------------
-- Adalah objek-objek yang menyimpan metadata, tetapi yang datanya sangat cepat
-- berubah-ubah (dinamis).
-- Jenis DMO ada dua: (1) VIEW; (2) TVF (Table-Valued Functions)

-- Contoh DMO yang berupa VIEW:
-- Menampilkan daftar user yang saat ini sedang konek ke server SQL Server kita.
SELECT * FROM sys.dm_exec_sessions 
WHERE is_user_process <> 0 AND status = 'running';

-- Menampilkan informasi OS dari server kita saat ini
SELECT * FROM sys.dm_os_sys_info;
-- RAM
SELECT * FROM sys.dm_os_sys_memory;

-- Contoh DMO yang berupa TVF
-- Menampilkan 'referencing entities' (objek apa bergantung pada objek lain yang mana)
-- Sales.OrderDetails dipakai oleh objek mana saja?
SELECT * FROM sys.dm_sql_referencing_entities('Sales.OrderDetails', 'OBJECT');

-- Dia menggunakan objek yang mana saja?
SELECT * FROM sys.dm_sql_referenced_entities('Sales.CategoryOrderYear', 'OBJECT');