

-- STEP1:
-- create an empty table catalog CERVA sk language version


USE GAJOStest;

DROP TABLE IF EXISTS dbo.catalog_sk

CREATE TABLE dbo.catalog_sk (  
    code nvarchar(15),
	title nvarchar(100),
	description nvarchar(1000),
	category_path nvarchar(20),
	packaging nvarchar(10),
	size_code int,
	size_title nvarchar(20),
	colour_code nvarchar(3),
	colour_title nvarchar(20),
	standard_code varchar(10),
	standard_title nvarchar(10),
	season_code char(4),
	season_title nvarchar(20),
	brand nvarchar(10),
	property_code int,
	property_title nvarchar(20),
	image_type_1 char(3),
	image_title_1 nvarchar(40),
	image_path_1 nvarchar(200),
	image_type_2 char(3),
	image_title_2 nvarchar(40),
	image_path_2 nvarchar(200),
	image_type_3 char(3),
	image_title_3 nvarchar(40),
	image_path_3 nvarchar(200),
	image_type_4 char(3),
	image_title_4 nvarchar(40),
	image_path_4 nvarchar(200),
	image_type_5 char(3),
	image_title_5 nvarchar(40),
	image_path_5 nvarchar(200)
); 


-- create an empty table catalog CERVA cs language version

USE GAJOStest;

DROP TABLE IF EXISTS dbo.catalog_cs

CREATE TABLE dbo.catalog_cs (  
    code nvarchar(15),
	title nvarchar(100),
	description nvarchar(1000),
	category_path nvarchar(20),
	packaging nvarchar(10),
	size_code int,
	size_title nvarchar(20),
	colour_code nvarchar(3),
	colour_title nvarchar(20),
	standard_code varchar(10),
	standard_title nvarchar(10),
	season_code char(4),
	season_title nvarchar(20),
	brand nvarchar(10),
	property_code int,
	property_title nvarchar(20),
	image_type_1 char(3),
	image_title_1 nvarchar(40),
	image_path_1 nvarchar(200),
	image_type_2 char(3),
	image_title_2 nvarchar(40),
	image_path_2 nvarchar(200),
	image_type_3 char(3),
	image_title_3 nvarchar(40),
	image_path_3 nvarchar(200),
	image_type_4 char(3),
	image_title_4 nvarchar(40),
	image_path_4 nvarchar(200),
	image_type_5 char(3),
	image_title_5 nvarchar(40),
	image_path_5 nvarchar(200)
); 




-- STEP2:
--shredd xml catalog file sk version and insert it into the empty table 'catalog_sk'


IF OBJECT_ID('catalog_sk') IS NOT NULL
TRUNCATE TABLE catalog_sk

DECLARE @impxml xml

SELECT @impxml=I
FROM OPENROWSET (BULK 'C:\Users\ondre\Desktop\Gajos_project_automat\catalog_sk.xml', SINGLE_BLOB) as ImportFile(I)

--SELECT @impxml

DECLARE @hdoc int

EXEC sp_xml_preparedocument @hdoc OUTPUT, @impxml

INSERT INTO dbo.catalog_sk(code, title, description, category_path, packaging, size_code, size_title, colour_code,
colour_title, standard_code, standard_title, season_code, season_title, brand, property_code, property_title,
image_type_1, image_title_1, image_path_1, image_type_2, image_title_2, image_path_2, image_type_3, image_title_3,
image_path_3, image_type_4, image_title_4, image_path_4, image_type_5, image_title_5, image_path_5)

SELECT T.N.value('(code/text())[1]','nvarchar(15)') AS Code,
		T.N.value('(title/text())[1]','nvarchar(100)') AS Title,
		T.N.value('(description/text())[1]','nvarchar(1000)') AS Description,
		T.N.value('(categoryPath/text())[1]','nvarchar(20)') AS Category_path,
		T.N.value('(packaging/text())[1]','nvarchar(10)') AS Packaging,
		T2.N.value('(@code[1])','int') AS size_code,
		T2.N.value('(@title[1])','nvarchar(20)') AS size_title,
		T3.N.value('(@code)[1]','nvarchar(3)') AS colour_code,
		T3.N.value('(@title)[1]','nvarchar(20)') AS colour_title,
		T.N.value('(standars/standard/@code)[1]','nvarchar(10)') AS standard_code,
		T.N.value('(standars/standard/@title)[1]','nvarchar(10)') AS standard_title,
		T4.N.value('(@code[1])','char(4)') AS season_code,	   
		T4.N.value('(@title[1])','nvarchar(20)') AS season_title,
		T.N.value('(brand/text())[1]','nvarchar(30)') AS brand,
		T.N.value('(properties/property/@code)[1]','int') AS property_code,
		T.N.value('(properties/property/@title)[1]','nvarchar(20)') AS property_title,
		T.N.value('(images/image/type)[1]','char(3)') AS image_type_1,
		T.N.value('(images/image/title)[1]','nvarchar(40)') AS image_title_1,
		T.N.value('(images/image/path)[1]','nvarchar(200)') AS image_path_1,
		T.N.value('(images/image/type)[2]','char(3)') AS image_type_2,
		T.N.value('(images/image/title)[2]','nvarchar(40)') AS image_title_2,
		T.N.value('(images/image/path)[2]','nvarchar(200)') AS image_path_2,
		T.N.value('(images/image/type)[3]','char(3)') AS image_type_3,
		T.N.value('(images/image/title)[3]','nvarchar(40)') AS image_title_3,
		T.N.value('(images/image/path)[3]','nvarchar(200)') AS image_path_3,
		T.N.value('(images/image/type)[4]','char(3)') AS image_type_4,
		T.N.value('(images/image/title)[4]','nvarchar(40)') AS image_title_4,
		T.N.value('(images/image/path)[4]','nvarchar(200)') AS image_path_4,
		T.N.value('(images/image/type)[5]','char(3)') AS image_type_5,
		T.N.value('(images/image/title)[5]','nvarchar(40)') AS image_title_5,
		T.N.value('(images/image/path)[5]','nvarchar(200)') AS image_path_5

FROM @impxml.nodes('/catalog/products/product') as T(N)
outer apply T.N.nodes('sizes/size') as T2(N)
outer apply T.N.nodes('colors/color') as T3(N)
outer apply T.N.nodes('season') as T4(N)


--shredd xml catalog file cs version and insert it into the empty table 'catalog_cs'

IF OBJECT_ID('catalog_cs') IS NOT NULL
TRUNCATE TABLE catalog_cs

DECLARE @impxml2 xml

SELECT @impxml2=I
FROM OPENROWSET (BULK 'C:\Users\ondre\Desktop\Gajos_project_automat\catalog_cs.xml', SINGLE_BLOB) as ImportFile(I)

--SELECT @impxml

DECLARE @hdoc2 int

EXEC sp_xml_preparedocument @hdoc2 OUTPUT, @impxml2

INSERT INTO dbo.catalog_cs(code, title, description, category_path, packaging, size_code, size_title, colour_code,
colour_title, standard_code, standard_title, season_code, season_title, brand, property_code, property_title,
image_type_1, image_title_1, image_path_1, image_type_2, image_title_2, image_path_2, image_type_3, image_title_3,
image_path_3, image_type_4, image_title_4, image_path_4, image_type_5, image_title_5, image_path_5)

SELECT T.N.value('(code/text())[1]','nvarchar(15)') AS Code,
		T.N.value('(title/text())[1]','nvarchar(100)') AS Title,
		T.N.value('(description/text())[1]','nvarchar(1000)') AS Description,
		T.N.value('(categoryPath/text())[1]','nvarchar(20)') AS Category_path,
		T.N.value('(packaging/text())[1]','nvarchar(10)') AS Packaging,
		T2.N.value('(@code[1])','int') AS size_code,
		T2.N.value('(@title[1])','nvarchar(20)') AS size_title,
		T3.N.value('(@code)[1]','nvarchar(3)') AS colour_code,
		T3.N.value('(@title)[1]','nvarchar(20)') AS colour_title,
		T.N.value('(standars/standard/@code)[1]','nvarchar(10)') AS standard_code,
		T.N.value('(standars/standard/@title)[1]','nvarchar(10)') AS standard_title,
		T4.N.value('(@code[1])','char(4)') AS season_code,	   
		T4.N.value('(@title[1])','nvarchar(20)') AS season_title,
		T.N.value('(brand/text())[1]','nvarchar(30)') AS brand,
		T.N.value('(properties/property/@code)[1]','int') AS property_code,
		T.N.value('(properties/property/@title)[1]','nvarchar(20)') AS property_title,
		T.N.value('(images/image/type)[1]','char(3)') AS image_type_1,
		T.N.value('(images/image/title)[1]','nvarchar(40)') AS image_title_1,
		T.N.value('(images/image/path)[1]','nvarchar(200)') AS image_path_1,
		T.N.value('(images/image/type)[2]','char(3)') AS image_type_2,
		T.N.value('(images/image/title)[2]','nvarchar(40)') AS image_title_2,
		T.N.value('(images/image/path)[2]','nvarchar(200)') AS image_path_2,
		T.N.value('(images/image/type)[3]','char(3)') AS image_type_3,
		T.N.value('(images/image/title)[3]','nvarchar(40)') AS image_title_3,
		T.N.value('(images/image/path)[3]','nvarchar(200)') AS image_path_3,
		T.N.value('(images/image/type)[4]','char(3)') AS image_type_4,
		T.N.value('(images/image/title)[4]','nvarchar(40)') AS image_title_4,
		T.N.value('(images/image/path)[4]','nvarchar(200)') AS image_path_4,
		T.N.value('(images/image/type)[5]','char(3)') AS image_type_5,
		T.N.value('(images/image/title)[5]','nvarchar(40)') AS image_title_5,
		T.N.value('(images/image/path)[5]','nvarchar(200)') AS image_path_5

FROM @impxml2.nodes('/catalog/products/product') as T(N)
outer apply T.N.nodes('sizes/size') as T2(N)
outer apply T.N.nodes('colors/color') as T3(N)
outer apply T.N.nodes('season') as T4(N)




-- STEP3:
-- sk catalog
-- add nulls into 2-digit values in 'size_code'
-- crate a variant_code based on 'code' and 'colour_code' and 'size_code' (including the null from the prev step)


SELECT*,
CONCAT(COALESCE(code, ''), COALESCE(colour_code, ''), COALESCE(mod_size_code, '')) AS comb_mod_size_code
INTO #mod_size_code_col
FROM 
(
SELECT *,
    CASE 
		WHEN len(size_code) < 1 THEN '000'+cast(size_code as VARCHAR(20))
		WHEN len(size_code) < 2 THEN '00'+cast(size_code as VARCHAR(20))
		WHEN len(size_code) < 3 THEN '0'+cast(size_code as VARCHAR(20))
    ELSE cast(size_code as varchar(20)) END as mod_size_code
FROM GAJOStest..catalog_sk
) AS modified_size_code


SELECT *,
	CASE 
		WHEN comb_mod_size_code LIKE '%VAM%' THEN 
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('VAM', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('VAM'), REVERSE(comb_mod_size_code))-1),'VAM')
		WHEN comb_mod_size_code LIKE '%BN%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('BN', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('BN'), REVERSE(comb_mod_size_code))-1),'BN')
		WHEN comb_mod_size_code LIKE '%HG%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('HG', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('HG'), REVERSE(comb_mod_size_code))-1),'HG')
    ELSE comb_mod_size_code END AS variant_code
INTO GAJOStest..catalog_variant_sk
FROM #mod_size_code_col

ALTER TABLE GAJOStest..catalog_variant_sk
DROP COLUMN comb_mod_size_code

ALTER TABLE GAJOStest..catalog_variant_sk
DROP COLUMN mod_size_code


-- cs catalog
-- add nulls into 2-digit values in 'size_code'
-- crate a variant_code based on 'code' and 'colour_code' and 'size_code' (including the null from the prev step)
SELECT*,
CONCAT(COALESCE(code, ''), COALESCE(colour_code, ''), COALESCE(mod_size_code, '')) AS comb_mod_size_code
INTO #mod_size_code_col
FROM 
(
SELECT 
	*,
    CASE 
		WHEN len(size_code) < 1 THEN '000'+cast(size_code as NVARCHAR(20))
		WHEN len(size_code) < 2 THEN '00'+cast(size_code as NVARCHAR(20))
		WHEN len(size_code) < 3 THEN '0'+cast(size_code as NVARCHAR(20))
    ELSE cast(size_code as varchar(20)) END as mod_size_code
FROM GAJOStest..catalog_cs
) AS modified_size_code

SELECT *,
	CASE 
		WHEN comb_mod_size_code LIKE '%VAM%' THEN 
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('VAM', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('VAM'), REVERSE(comb_mod_size_code))-1),'VAM')
		WHEN comb_mod_size_code LIKE '%BN%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('BN', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('BN'), REVERSE(comb_mod_size_code))-1),'BN')
		WHEN comb_mod_size_code LIKE '%HG%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('HG', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('HG'), REVERSE(comb_mod_size_code))-1),'HG')
    ELSE comb_mod_size_code END AS variant_code
INTO GAJOStest..catalog_variant_cs
FROM #mod_size_code_col

ALTER TABLE GAJOStest..catalog_variant_cs
DROP COLUMN comb_mod_size_code

ALTER TABLE GAJOStest..catalog_variant_cs
DROP COLUMN mod_size_code




-- STEP4:
-- replace values with 'null' descriptions in catalog_cs from mkt_catalog
-- add columns determininig sk vs. cs description


UPDATE GAJOStest..catalog_variant_sk
SET title = MAKTX
FROM GAJOStest..catalog_prim_key_sk cat
LEFT JOIN GAJOStest..MKT_nazvy_produktov AS mkt
	ON mkt.MATNR = cat.code
WHERE mkt.MATNR = cat.code

ALTER TABLE GAJOStest..catalog_prim_key_sk
ADD description_lan VARCHAR (5)

UPDATE GAJOStest..catalog_variant_sk
SET description_lan = (
	CASE 
		WHEN sk.description IS NOT NULL THEN 'sk'
		WHEN cs.description IS NOT NULL THEN 'cs'
	ELSE NULL END
	)
FROM GAJOStest..catalog_variant_sk AS sk
LEFT JOIN GAJOStest..catalog_variant_cs AS cs
	ON sk.variant_code = cs.variant_code




-- STEP5:
-- replace brand abbreviations by brand names from our eshop


ALTER TABLE GAJOStest..catalog_variant_sk
ALTER COLUMN brand VARCHAR(50)

UPDATE GAJOStest..catalog_prim_key_sk
   SET brand = CASE brand
                      WHEN 'ANSE' THEN 'ANSELL'
                      WHEN 'ASNT' THEN 'ASSENT' 
					  WHEN 'AUST' THEN 'Australian Line' 
					  WHEN 'BATM' THEN 'BATMETALL' 
					  WHEN 'BEKI' THEN 'BEKINA' 
					  WHEN 'BOLE' THEN 'BOLLE' 
					  WHEN 'BOOT' THEN 'BOOTS' 
					  WHEN 'CERV' THEN 'CERVA' 
					  WHEN 'KNOX' THEN 'CERVA-KNOXFIELD' 
					  WHEN 'PROF' THEN 'CERVA-PROFESIONAL' 
					  WHEN 'CLSP' THEN 'CLEANSPACE' 
					  WHEN 'DERM' THEN 'DERMIK' 
					  WHEN 'DUPO' THEN 'DUPONT' 
					  WHEN 'ED' THEN 'EAR DEFENDER' 
					  WHEN 'FALL' THEN 'FALLSAFE' 
					  WHEN 'FENT' THEN 'FENTO' 
					  WHEN 'FH' THEN 'FREE HAND' 
					  WHEN 'FF' THEN 'FRIEDRICH & FRIEDRICH' 
					  WHEN 'LANE' THEN 'LANEX' 
					  WHEN 'LASO' THEN 'LASOGARD' 
					  WHEN 'MOLE' THEN 'MOLEDA' 
					  WHEN 'OKUL' THEN 'OKULA' 
					  WHEN 'PAND' THEN 'PANDA' 
					  WHEN 'PETZ' THEN 'PETZL' 
					  WHEN 'REFI' THEN 'REFIL' 
					  WHEN 'SECU' THEN 'SECURA' 
					  WHEN 'SEVE' THEN 'SEVEROSKLO' 
					  WHEN 'SIOE' THEN 'SIOEN' 
					  WHEN 'SKYL' THEN 'SKYLOTEC' 
					  WHEN 'SPIR' THEN 'SPIROTEK' 
					  WHEN 'SUND' THEN 'SUNDSTROM' 
					  WHEN 'TACH' THEN 'TACHOV - Dipped Gloves' 
					  WHEN 'TWF' THEN 'TO WORK FOR' 
					  WHEN 'TB' THEN 'TOMAS BODERO' 
					  WHEN 'VEKT' THEN 'VEKTOR'
					  WHEN 'VOCH' THEN 'VOCHOC' 
					  WHEN 'HEXA' THEN 'HEX ARMOR' 
					  WHEN 'HYGT' THEN 'HYGOTRENDY'
					  WHEN 'ARTI' THEN 'ARTILUX'
                      ELSE brand
                      END
 WHERE brand IN('ANSE','ASNT','AUST','BATM','BEKI','BOLE','BOOT','CERV','KNOX','PROF','CLSP','DERM','DUPO',
 'ED','FALL','FENT','FH','FF','LANE','LASO','MOLE','OKUL','PAND','PETZ','REFI','SECU','SEVE','SIOE','SKYL',
 'SPIR','SUND','TACH','TWF','TB','VEKT','VOCH','HEXA','HYGT','ARTI')




-- STEP6:
-- move images OH 'main image' to image_type1, image_title1 and image_path1


 UPDATE GAJOStest..catalog_variant_sk
SET image_type_1 = image_type_2, image_title_1 = image_title_2, image_path_1 = image_path_2, 
	image_type_2 = image_type_1, image_title_2 = image_title_1, image_path_2 = image_path_1
WHERE image_type_1 != 'OH0' AND image_type_2 = 'OH0'

UPDATE GAJOStest..catalog_variant_sk
SET image_type_1 = image_type_3, image_title_1 = image_title_3, image_path_1 = image_path_3, 
	image_type_3 = image_type_1, image_title_3 = image_title_1, image_path_3 = image_path_1
WHERE image_type_1 != 'OH0' AND image_type_3 = 'OH0'

UPDATE GAJOStest..catalog_variant_sk
SET image_type_1 = image_type_4, image_title_1 = image_title_4, image_path_1 = image_path_4, 
	image_type_4 = image_type_1, image_title_4 = image_title_1, image_path_4 = image_path_1
WHERE image_type_1 != 'OH0' AND image_type_4 = 'OH0'

UPDATE GAJOStest..catalog_variant_sk
SET image_type_1 = image_type_5, image_title_1 = image_title_5, image_path_1 = image_path_5, 
	image_type_5 = image_type_1, image_title_5 = image_title_1, image_path_5 = image_path_1
WHERE image_type_1 != 'OH0' AND image_type_5 = 'OH0'




-- STEP7:
-- create short description from long descriptions by extracting first sentences before '.' 
-- or 2nd occurences of '•'


ALTER TABLE GAJOStest..catalog_variant_sk
ADD short_decription AS (
	CASE 
		WHEN description LIKE '%.%' THEN LEFT(description, CHARINDEX('.', description))
		WHEN description LIKE '%•%' AND CHARINDEX('•', description, CHARINDEX('•', description)+1)-1 >= 0
		THEN LEFT(description, CHARINDEX('•', description, CHARINDEX('•', description)+1)-1)
	ELSE description END)



-- STEP8:
-- add printing column for products within category path "clothes"


ALTER TABLE GAJOStest..catalog_variant_sk
ADD printing AS (
	CASE 
		WHEN category_path LIKE 'A01%' 
		THEN 'Áno' ELSE null 
	END)




-- STEP9:
-- add rows so that each variant has a 'parent'


ALTER TABLE GAJOStest..catalog_variant_sk 
ADD product_type VARCHAR (20);

INSERT INTO GAJOStest..catalog_variant_sk (code, title, description, category_path, packaging, standard_code, standard_title, season_code, season_title, brand, 
property_code, property_title, image_type_1, image_title_1, image_path_1, image_type_2, image_title_2, image_path_2,
image_type_3, image_title_3, image_path_3, image_type_4, image_title_4, image_path_4, image_type_5, image_title_5, 
image_path_5, product_type)
SELECT DISTINCT code, title, description, category_path, packaging, standard_code, standard_title, season_code, season_title, brand, 
property_code, property_title, image_type_1, image_title_1, image_path_1, image_type_2, image_title_2, image_path_2,
image_type_3, image_title_3, image_path_3, image_type_4, image_title_4, image_path_4, image_type_5, image_title_5, 
image_path_5, 'parent'
FROM GAJOStest..catalog_variant_sk 

UPDATE GAJOStest..catalog_variant_sk 
SET product_type = 'variable'
WHERE product_type is null




-- STEP10:
-- compare catalog with our eshop to find missing values in our eshop


CREATE VIEW catalog_eshop AS 
SELECT catalog_prim_key_sk.* 
FROM GAJOStest..catalog_prim_key_sk
WHERE NOT EXISTS
(
	SELECT 1 
    FROM GAJOStest..GAJOS_eshop
    WHERE GAJOS_eshop.SKU = catalog_prim_key_sk.variant_code
			OR (GAJOS_eshop.SKU = catalog_prim_key_sk.code AND catalog_prim_key_sk.product_type is null))




-- STEP11:
-- compare catalog with our eshop and omega to find missing values in our eshop and omega


CREATE VIEW catalog_eshop_omega AS 
WITH cte_catalog_eshop_omega AS 
(
SELECT catalog_prim_key_sk.* 
FROM GAJOStest..catalog_prim_key_sk
WHERE NOT EXISTS
(
	SELECT 1 
    FROM GAJOStest..GAJOS_eshop
    WHERE GAJOS_eshop.SKU = catalog_prim_key_sk.variant_code)
	AND NOT EXISTS (
					SELECT 1
					FROM GAJOStest..export_OMEGA
					WHERE export_OMEGA.[Èíslo karty] = catalog_prim_key_sk.variant_code)
)
SELECT * FROM cte_catalog_eshop_omega
WHERE code in
(
	SELECT code FROM cte_catalog_eshop_omega
	GROUP BY code 
	HAVING count(code) > 
)




-- STEP12:
-- order the results from view so that each product has a variant on top 


SELECT * FROM catalog_eshop_omega
ORDER BY code, size_code




