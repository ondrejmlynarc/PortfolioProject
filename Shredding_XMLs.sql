
-- importing and shredding our supplier's catalog in XML into a plain sql format
-- the shredded file will be used for comparison analysis with products on our eshop on a quarterly basis
-- 2 methods were used: (1) using Xquery (2) using Xquery with cross/outer apply


-- (2) USING XQUERY WITH CROSS/OUTER APPLY 
	-- the method proved to have significantly better performance 
	/* in addition to using OUTER APPLY, text instead of VARCHAR datatype was used where applicable - 
	   in light of complex dataset and many undesirable data attributes used in the native XML file*/

--USE GAJOStest
--TRUNCATE TABLE dbo.Catalog;

DECLARE @impxml xml

-- import file using OPENROWSET

SELECT @impxml=I
FROM OPENROWSET (BULK 'C:\Users\ondre\Desktop\Gajos project\catalog_sk.xml', SINGLE_BLOB) as ImportFile(I)

-- SELECT @impxml

DECLARE @hdoc int

EXEC sp_xml_preparedocument @hdoc OUTPUT, @impxml

USE GAJOStest

/*INSERT INTO dbo.catalog(code, title, description, category_path, packaging, size_code, size_title, colour_code,
colour_title, standard_code, standard_title, season_code, season_title, brand, property_code, property_title,
image_type_1, image_title_1, image_path_1, image_type_2, image_title_2, image_path_2, image_type_3, image_title_3,
image_path_3, image_type_4, image_title_4, image_path_4, image_type_5, image_title_5, image_path_5)*/

SELECT 
	T.N.value('(code/text())[1]','VARCHAR(15)') AS Code,
    T.N.value('(title/text())[1]','VARCHAR(100)') AS Title,
    T.N.value('(description/text())[1]','VARCHAR(1000)') AS Description,
    T.N.value('(categoryPath/text())[1]','VARCHAR(20)') AS Category_path,
    T.N.value('(packaging/text())[1]','VARCHAR(10)') AS Packaging,
	T2.N.value('(@code[1])','INT') AS size_code,
	T2.N.value('(@title[1])','VARCHAR(20)') AS size_title,
	T3.N.value('(@code)[1]','VARCHAR(3)') AS colour_code,
	T3.N.value('(@title)[1]','VARCHAR(20)') AS colour_title,
	T.N.value('(standars/standard/@code)[1]','VARCHAR(10)') AS standard_code,
	T.N.value('(standars/standard/@title)[1]','VARCHAR(10)') AS standard_title,
	T4.N.value('(@code[1])','VARCHAR(4)') AS season_code,	   
	T4.N.value('(@title[1])','VARCHAR(20)') AS season_title,
	T.N.value('(brand/text())[1]','VARCHAR(10)') AS brand,
	T.N.value('(properties/property/@code)[1]','INT') AS property_code,
	T.N.value('(properties/property/@title)[1]','VARCHAR(20)') AS property_title,
	T.N.value('(images/image/type)[1]','VARCHAR(3)') AS image_type_1,
	T.N.value('(images/image/title)[1]','VARCHAR(40)') AS image_title_1,
	T.N.value('(images/image/path)[1]','VARCHAR(200)') AS image_path_1,
	T.N.value('(images/image/type)[2]','VARCHAR(3)') AS image_type_2,
	T.N.value('(images/image/title)[2]','VARCHAR(40)') AS image_title_2,
	T.N.value('(images/image/path)[2]','VARCHAR(200)') AS image_path_2,
	T.N.value('(images/image/type)[3]','VARCHAR(3)') AS image_type_3,
	T.N.value('(images/image/title)[3]','VARCHAR(40)') AS image_title_3,
	T.N.value('(images/image/path)[3]','VARCHAR(200)') AS image_path_3,
	T.N.value('(images/image/type)[4]','VARCHAR(3)') AS image_type_4,
	T.N.value('(images/image/title)[4]','VARCHAR(40)') AS image_title_4,
	T.N.value('(images/image/path)[4]','VARCHAR(200)') AS image_path_4,
	T.N.value('(images/image/type)[5]','VARCHAR(3)') AS image_type_5,
	T.N.value('(images/image/title)[5]','VARCHAR(40)') AS image_title_5,
	T.N.value('(images/image/path)[5]','VARCHAR(200)') AS image_path_5


from @impxml.nodes('/catalog/products/product') as T(N)
outer apply T.N.nodes('sizes/size') as T2(N)
outer apply T.N.nodes('colors/color') as T3(N)
outer apply T.N.nodes('season') as T4(N)
-- cross apply T.N.nodes('images/image') as T5(N)
-- outer apply T.N.nodes('standars/standard') as T3(N)
;

 
-- (1) USING XQUERY
-- inefficient query due to complex datasets and the file containing many attributes at different levels

--USE GAJOStest
--TRUNCATE TABLE dbo.Catalog;

DECLARE @impxml xml

-- import file using OPENROWSET

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


SELECT
	x.value('(../../code)[1]','VARCHAR(20)') AS Code,
	x.value('(../../title)[1]','VARCHAR(30)') AS Title,
	x.value('(../../description)[1]','VARCHAR(300)') AS Description,
	x.value('(../../categoryPath)[1]','VARCHAR(20)') AS Category_path,
	x.value('(../../packaging)[1]','VARCHAR(10)') AS Packaging,
	x.value('(@code)[1]','INT') AS size_code,
	x.value('(@title)[1]','VARCHAR(10)') AS size_title,
	x.value('(../../colors/color/@code)[1]','INT') AS colour_code,
	x.value('(../../colors/color/@title)[1]','VARCHAR(max)') AS colour_title,
	x.value('(../../standars/standard/@code)[1]','VARCHAR(20)') AS standard_code,
	x.value('(../../standars/standard/@title)[1]','VARCHAR(20)') AS standard_title,
	x.value('(../../season/@code)[1]','VARCHAR(20)') AS season_code,
	x.value('(../../season/@title)[1]','VARCHAR(20)') AS season_title,
	x.value('(../../brand)[1]','VARCHAR(5)') AS brand,
	x.value('(../../images/image/type)[1]','VARCHAR(40)') AS image_type_1,
	x.value('(../../images/image/title)[1]','VARCHAR(40)') AS image_title_1,
	x.value('(../../images/image/path)[1]','VARCHAR(40)') AS image_path_1,
	x.value('(../../images/image/type)[2]','VARCHAR(40)') AS image_type_2,
	x.value('(../../images/image/title)[2]','VARCHAR(40)') AS image_title_2,
	x.value('(../../images/image/path)[2]','VARCHAR(40)') AS image_path_2,
	x.value('(../../images/image/type)[3]','VARCHAR(40)') AS image_type_3,
	x.value('(../../images/image/title)[3]','VARCHAR(40)') AS image_title_3,
	x.value('(../../images/image/path)[3]','VARCHAR(40)') AS image_path_3,
	x.value('(../../images/image/type)[4]','VARCHAR(40)') AS image_type_4,
	x.value('(../../images/image/title)[4]','VARCHAR(40)') AS image_title_4,
	x.value('(../../images/image/path)[4]','VARCHAR(40)') AS image_path_4,
	x.value('(../../images/image/type)[5]','VARCHAR(40)') AS image_type_5,
	x.value('(../../images/image/title)[5]','VARCHAR(40)') AS image_title_5,
	x.value('(../../images/image/path)[5]','VARCHAR(40)') AS image_path_5,
	x.value('(../../unit)[1]','VARCHAR(5)') AS unit

FROM @impxml.nodes('/catalog/products/product/sizes/size') as XMLtbl(x); 



