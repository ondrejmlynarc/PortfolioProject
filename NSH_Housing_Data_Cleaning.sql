

-- Standardise Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject2.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject2.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
Add SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


-- Populate Property Address Data

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing
WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a 
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
-- Property Address

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PopertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PopertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing


-- OwnerAddress
SELECT 
	OwnerAddress,
	RIGHT(OwnerAddress, 2) AS state,
	LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1) as address,
	SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, 
	CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress)+1) -  CHARINDEX(',', OwnerAddress) -1 ) as city
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress  = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1)

ALTER TABLE NashvilleHousing
Add OwnerSplitState VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = RIGHT(OwnerAddress, 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, 
	CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress)+1) -  CHARINDEX(',', OwnerAddress) -1 )


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM PortfolioProject2.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS SoldAsVacantRenamed
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SoldAsVacantRenamed VARCHAR(2)

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH CTE AS
(
SELECT *,ROW_NUMBER() OVER (
		PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		LegalReference 
		ORDER BY 
		UniqueID) AS RN
FROM PortfolioProject2.dbo.NashvilleHousing
)
Select *
From CTE
Where RN > 1
Order by PropertyAddress



DELETE FROM CTE WHERE RN<>1



-- Delete Unused Columns

ALTER TABLE FROM PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress
