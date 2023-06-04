-- Cleaning data in SQL

SELECT *
FROM PortfolioProject..NashvilleHousing


-- Standardize Date
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

-- Populate property address
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.ParcelID)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.ParcelID)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking down Property Address into Address, City, State
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 0, CHARINDEX(',',PropertyAddress)) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Addres
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 0, CHARINDEX(',',PropertyAddress))

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

SELECT *
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
	                    ELSE SoldAsVacant
	               END

-----------------------------------------------------------------------------------

--Remove Duplicates

SELECT *
FROM PortfolioProject..NashvilleHousing


;WITH RowNumCTE AS
(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                SalePrice,
				LegalReference,
				SaleDateConverted
				ORDER BY 
				UniqueID
				) row_num

FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-- A CTE only functions in the same query


-----------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Delete is practically done on Views and not the raw database. Seek persistion before deleting columns on a real database


SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate