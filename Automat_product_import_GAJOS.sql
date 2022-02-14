-- * EN translation followed by '/' throughout the comments


--USE GAJOStest
--TRUNCATE TABLE dbo.Catalog;

DECLARE @impxml xml

SELECT @impxml=I
FROM OPENROWSET (BULK 'C:\Users\ondre\Desktop\Gajos_project_automat\catalog_sk.xml', SINGLE_BLOB) as ImportFile(I)

-- SELECT @impxml

DECLARE @hdoc int

EXEC sp_xml_preparedocument @hdoc OUTPUT, @impxml

USE GAJOStest

/*INSERT INTO dbo.catalog(code, title, description, category_path, packaging, size_code, size_title, colour_code,
colour_title, standard_code, standard_title, season_code, season_title, brand, property_code, property_title,
image_type_1, image_title_1, image_path_1, image_type_2, image_title_2, image_path_2, image_type_3, image_title_3,
image_path_3, image_type_4, image_title_4, image_path_4, image_type_5, image_title_5, image_path_5)*/

select T.N.value('(code/text())[1]','NVARCHAR(15)') AS Code,
       T.N.value('(title/text())[1]','NVARCHAR(100)') AS Title,
       T.N.value('(description/text())[1]','NVARCHAR(700)') AS Description,
       T.N.value('(categoryPath/text())[1]','NVARCHAR(20)') AS Category_path,
       T.N.value('(packaging/text())[1]','NVARCHAR(10)') AS Packaging,
	   T2.N.value('(@code[1])','INT') AS size_code,
	   T2.N.value('(@title[1])','NVARCHAR(20)') AS size_title,
	   T3.N.value('(@code)[1]','NVARCHAR(5)') AS colour_code,
	   T3.N.value('(@title)[1]','NVARCHAR(20)') AS colour_title,
	   T.N.value('(standars/standard/@code)[1]','NVARCHAR(10)') AS standard_code,
	   T.N.value('(standars/standard/@title)[1]','NVARCHAR(10)') AS standard_title,
	   T4.N.value('(@code[1])','NVARCHAR(4)') AS season_code,	   
	   T4.N.value('(@title[1])','NVARCHAR(20)') AS season_title,
	   T.N.value('(brand/text())[1]','NVARCHAR(10)') AS brand,
	   T.N.value('(properties/property/@code)[1]','NVARCHAR(10)') AS property_code,
	   T.N.value('(properties/property/@title)[1]','NVARCHAR(20)') AS property_title,
	   T.N.value('(images/image/type)[1]','NVARCHAR(3)') AS image_type_1,
	   T.N.value('(images/image/title)[1]','NVARCHAR(40)') AS image_title_1,
	   T.N.value('(images/image/path)[1]','NVARCHAR(200)') AS image_path_1,
	   T.N.value('(images/image/type)[2]','NVARCHAR(3)') AS image_type_2,
	   T.N.value('(images/image/title)[2]','NVARCHAR(40)') AS image_title_2,
	   T.N.value('(images/image/path)[2]','NVARCHAR(200)') AS image_path_2,
	   T.N.value('(images/image/type)[3]','NVARCHAR(3)') AS image_type_3,
	   T.N.value('(images/image/title)[3]','NVARCHAR(40)') AS image_title_3,
	   T.N.value('(images/image/path)[3]','NVARCHAR(200)') AS image_path_3,
	   T.N.value('(images/image/type)[4]','NVARCHAR(3)') AS image_type_4,
	   T.N.value('(images/image/title)[4]','NVARCHAR(40)') AS image_title_4,
	   T.N.value('(images/image/path)[4]','NVARCHAR(200)') AS image_path_4,
	   T.N.value('(images/image/type)[5]','NVARCHAR(3)') AS image_type_5,
	   T.N.value('(images/image/title)[5]','NVARCHAR(40)') AS image_title_5,
	   T.N.value('(images/image/path)[5]','NVARCHAR(200)') AS image_path_5
	   --T5.N.value('(title/text())[1]','NVARCHAR(40)') AS image_title_1


from @impxml.nodes('/catalog/products/product') as T(N)
outer apply T.N.nodes('sizes/size') as T2(N)
outer apply T.N.nodes('colors/color') as T3(N)
outer apply T.N.nodes('season') as T4(N)
-- cross apply T.N.nodes('images/image') as T5(N)
-- outer apply T.N.nodes('standars/standard') as T3(N)
;


/*1. pridanie nuly do 2-miestnych 'size_code' / add nulls into 2-digit values in 'size_code'
  2. vytvorenie variantu na zaklade 'code' a 'colour_code' a 'size_code' (s nulou z bodu jedna) / 
     crate a variant_code based on 'code' and 'colour_code' and 'size_code' (including the null from 1.) */

USE gajostest;

SELECT
	*,
    CONCAT(COALESCE(code, ''), COALESCE(colour_code, ''), COALESCE(mod_size_code, '')) AS comb_mod_size_code
INTO #mod_size_code_colr
FROM 
(
SELECT 
	*,
    CASE WHEN len(size_code) < 3 THEN concat(0, size_code) 
    ELSE size_code END as mod_size_code
FROM GAJOStest..catalog
) AS modified_size_code


SELECT * FROM GAJOStest..catalog



/*	4.vyhladaj kody, ktore obsahuju pismena a skontroluj ich spravne umiestnenie/
	  search for codes that contain letters and verify their correct position from our GAJOS' database*/

SELECT code
FROM catalog
WHERE code LIKE '%[A-Z]%'




/* 5.variant_codes, ktore obsahuju pismena v strede 'code' a nutnost modifikacie/
	 variants containing letters in the middle to be moved to the end of variant_code: 
	 BN (m-end), VAM (m-end), HG (m-end)*

    * size_code a color_code obsahujuce cisla A, C1, R4 nepotrebuju modifikaciu/
	  variants containing size_code and color_code with letters A, C1, R4 do not need modification*/

SELECT
	code,
    comb_mod_size_code,
    CASE WHEN comb_mod_size_code LIKE '%VAM%' THEN 
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('VAM', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('VAM'), REVERSE(comb_mod_size_code))-1),'VAM')
		WHEN comb_mod_size_code LIKE '%BN%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('BN', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('BN'), REVERSE(comb_mod_size_code))-1),'BN')
		WHEN comb_mod_size_code LIKE '%HG%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('HG', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('HG'), REVERSE(comb_mod_size_code))-1),'HG')
    ELSE comb_mod_size_code END AS comb_mod_size_rever
FROM #mod_size_code_colr
-- WHERE code LIKE '%[A-Z]%'



/* 6. vytvor novu tabulku po vykonanych upravach (pozn: update nepouzit kvoli novemu prim. klucu)/
	  create a new table following the column addition */

SELECT *,
	CASE WHEN comb_mod_size_code LIKE '%VAM%' THEN 
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('VAM', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('VAM'), REVERSE(comb_mod_size_code))-1),'VAM')
		WHEN comb_mod_size_code LIKE '%BN%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('BN', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('BN'), REVERSE(comb_mod_size_code))-1),'BN')
		WHEN comb_mod_size_code LIKE '%HG%' THEN
		CONCAT(LEFT(comb_mod_size_code, CHARINDEX('HG', comb_mod_size_code)-1),
		RIGHT(comb_mod_size_code, CHARINDEX(REVERSE('HG'), REVERSE(comb_mod_size_code))-1),'HG')
    ELSE comb_mod_size_code END AS vairant_code -- comb_mod_size_rever
INTO catalogue_w_prim_key
FROM #mod_size_code_colr

SELECT * FROM catalogue_w_prim_key

USE gajostest;

 -- cast variant code in Gajos's eshop dataset
ALTER TABLE wc_product_export
ALTER COLUMN [Katalógové èíslo] NVARCHAR(50);



-- 7. variants eshop porovnat s catalogom / compare variants from our eshop with the catalog data
-- 8. variants omega porovnat s eshopom / compare variants from omega with eshop 

SELECT GAJOStest..catalogue_w_prim_key.* 
FROM catalogue_w_prim_key
WHERE NOT EXISTS
(
	SELECT 1 
    FROM wc_product_export
    WHERE wc_product_export.[Katalógové èíslo] = catalogue_w_prim_key.comb_mod_size_rever
	AND wc_product_export.[Katalógové èíslo] = omega_data_export_01_12_2021.SKU
)
ORDER BY title

-- create index to optimise the querying speed 
CREATE INDEX variant_code_eshop
ON wc_product_export ([Katalógové èíslo]);

CREATE INDEX variant_code_catalogue
ON catalogue_w_prim_key (comb_mod_size_rever);

-- DROP INDEX variant_code_eshop ON wc_product_export;
-- DROP INDEX variant_code_catalogue ON catalogue_w_prim_key;